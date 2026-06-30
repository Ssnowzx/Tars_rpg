# Relatórios de Entrega — Fertways

> **Regra do projeto:** **toda etapa concluída gera um relatório PDF completo** nesta pasta,
> antes de pedir a validação do usuário. Vale para cada bloco/item do roadmap
> (`docs/fertways-roadmap.md`).

## O que é uma "etapa"
Um item entregável do roadmap — por bloco (ex.: Marco A, B0, B1, B2…) ou por item quando combinado
com o usuário. Cada relatório cobre: objetivo, escopo entregue, referências do GDD, rotas + seam de
repositório, arquivos, Definition of Done validada e dívidas/futuro.

## Como gerar
1. Crie o HTML do relatório nesta pasta, no padrão `NN-slug.html` (ex.: `05-b3-mensagens.html`),
   usando `<link rel="stylesheet" href="report.css">` e a estrutura dos relatórios existentes
   (cover + cards + tabelas + `ul.dod` + `.note`).
2. Rode o conversor:
   ```bash
   cd docs/reports
   ./gen-pdf.sh                 # todos os HTML
   ./gen-pdf.sh 05-b3-mensagens.html   # só um
   ```
   Gera o `.pdf` ao lado do `.html` (Chrome headless, instância isolada).

## Arquivos
- `report.css` — estilo compartilhado (print A4, paleta Solar Frontier).
- `gen-pdf.sh` — conversor HTML→PDF (Chrome `--headless --print-to-pdf`).
- `NN-slug.html` / `NN-slug.pdf` — um par por etapa.

## Índice de relatórios
| # | Etapa | PDF |
|---|-------|-----|
| 01 | Marco A — Navegação principal (F1–F7 + A1–A4 + §15) | `01-marco-a.pdf` |
| 02 | B0 — Zonas Neutras | `02-b0-zonas-neutras.pdf` |
| 03 | B1 — Ministérios da Capital | `03-b1-ministerios.pdf` |
| 04 | B2 — Comércio Informal + Antifraude | `04-b2-comercio-informal.pdf` |
| 05 | R1 — B2 reconciliado à v29 (§25 logística + §26.5 Acordo) | `05-r1-comercio-informal-v29.pdf` |
| 06 | R2 — Perfil reconciliado à v29 (§26 4 índices + §24.3 Diário) | `06-r2-perfil-v29.pdf` |
| 07 | R3 — Rankings reconciliado à v29 (§27.13 percentil) | `07-r3-rankings-v29.pdf` |
| 08 | E1 — Economia §24 (Metal Bruto, Mina, Destilaria, subsídio, preços) | `08-e1-economia-v29.pdf` |
| 09 | E2 — Combate Territorial §27 (Sentinela, rodadas, saque) | `09-e2-combate-v29.pdf` |
| 10 | B3 — Sistema de Mensagens (§10, 5 canais) | `10-b3-mensagens.pdf` |

> Requisito: Google Chrome instalado (`/Applications/Google Chrome.app`). Sem dependência de
> pandoc/wkhtmltopdf.
