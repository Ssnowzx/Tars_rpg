#!/usr/bin/env bash
# Converte os relatórios HTML de docs/reports/ em PDF (Chrome headless).
# Uso:
#   ./gen-pdf.sh                # converte todos os *.html da pasta
#   ./gen-pdf.sh 05-b3-...html  # converte só o(s) arquivo(s) passado(s)
#
# Regra do projeto: cada etapa concluída ganha um relatório PDF completo aqui
# (ver README.md). Chrome é usado em instância isolada (user-data-dir único por
# arquivo) para evitar travas de profile.
set -euo pipefail

DIR="$(cd "$(dirname "$0")" && pwd)"
CHROME="/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"
TMP="${TMPDIR:-/tmp}/fw-chrome-pdf"

[ -x "$CHROME" ] || { echo "Google Chrome não encontrado em $CHROME"; exit 1; }

if [ "$#" -gt 0 ]; then
  files=("$@")
else
  files=("$DIR"/*.html)
fi

for html in "${files[@]}"; do
  [ -f "$html" ] || { echo "pulando (não existe): $html"; continue; }
  base="$(basename "${html%.html}")"
  pdf="$DIR/$base.pdf"
  rm -f "$pdf"
  "$CHROME" --headless=new --disable-gpu --no-sandbox \
    --user-data-dir="$TMP-$base" --no-pdf-header-footer \
    --print-to-pdf="$pdf" "file://$DIR/$base.html" >/dev/null 2>&1 &
  cpid=$!
  for _ in $(seq 1 20); do [ -f "$pdf" ] && sleep 0.4 && break; sleep 0.5; done
  kill "$cpid" 2>/dev/null || true
  wait "$cpid" 2>/dev/null || true
  echo "→ $base.pdf : $([ -f "$pdf" ] && echo OK || echo FALHOU)"
done

pkill -f "Google Chrome.*headless" 2>/dev/null || true
