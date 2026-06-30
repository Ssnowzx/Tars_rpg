#!/usr/bin/env python3
"""Remove a flat background (white by default) from a generated image -> PNG with alpha.

Usado no fluxo de arte do Fertways (ver docs/image-generation.md): a IA de imagem gera
o asset com fundo branco liso, este script transforma o branco em transparência.

Requer Pillow:  pip install pillow

Uso:
  python3 tools/chroma_key.py entrada.png saida.png
  python3 tools/chroma_key.py entrada.png saida.png --threshold 238 --color FFFFFF
  python3 tools/chroma_key.py entrada.png saida.png --color 00FF00   # fundo verde-chroma

Notas:
- --threshold (0-255): quão perto da cor-alvo conta como fundo (maior = remove mais).
- Faz um leve "despill"/anti-serrilhado nas bordas via alpha proporcional à distância.
- Só mexe no fundo conectado às bordas NÃO é feito aqui (remoção é por cor global);
  para chroma uniforme isso costuma bastar. Revise o resultado.
"""
import argparse
import sys


def parse_hex(h: str):
    h = h.strip().lstrip("#")
    if len(h) == 3:
        h = "".join(c * 2 for c in h)
    if len(h) != 6:
        raise ValueError(f"cor inválida: {h!r}")
    return tuple(int(h[i:i + 2], 16) for i in (0, 2, 4))


def main(argv):
    ap = argparse.ArgumentParser(description="Chroma key: cor de fundo -> alfa")
    ap.add_argument("input")
    ap.add_argument("output")
    ap.add_argument("--color", default="FFFFFF", help="cor de fundo (hex), padrão branco")
    ap.add_argument("--threshold", type=int, default=238,
                    help="0-255: distância máx. da cor-alvo p/ virar fundo (padrão 238)")
    ap.add_argument("--soft", type=int, default=18,
                    help="largura da faixa de transição (anti-serrilhado), padrão 18")
    args = ap.parse_args(argv)

    try:
        from PIL import Image
    except ImportError:
        print("ERRO: Pillow não instalado. Rode: pip install pillow", file=sys.stderr)
        return 2

    tr, tg, tb = parse_hex(args.color)
    img = Image.open(args.input).convert("RGBA")
    px = img.load()
    w, h = img.size
    cut, soft = args.threshold, max(1, args.soft)

    removed = 0
    for y in range(h):
        for x in range(w):
            r, g, b, a = px[x, y]
            # distância de Chebyshev até a cor-alvo
            dist = max(abs(r - tr), abs(g - tg), abs(b - tb))
            near = 255 - cut  # quão "perto" precisa estar
            if dist <= near:
                px[x, y] = (r, g, b, 0)
                removed += 1
            elif dist <= near + soft:
                # faixa de transição: alfa proporcional
                t = (dist - near) / soft
                px[x, y] = (r, g, b, int(a * t))

    img.save(args.output)
    print(f"OK: {args.input} -> {args.output}  ({w}x{h}, {removed} px de fundo removidos)")
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
