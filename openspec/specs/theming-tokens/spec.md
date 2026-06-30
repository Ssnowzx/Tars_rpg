# theming-tokens

## Purpose
O sistema de tema do app, derivado dos tokens DTCG (direção "Solar Frontier"),
garantindo identidade consistente e acessível em toda a UI.

## Requirements

### Requirement: Tema a partir de tokens
O sistema SHALL construir os `ThemeData` (claro padrão e escuro) a partir dos tokens
em `design-system/tokens/*`, espelhados no Flutter como `ColorScheme` + `DsTokens`
(ThemeExtension para espaçamento/raios/motion/cores semânticas extra). A UI SHALL ler
cores/medidas via `Theme`/`DsTokens`, sem valores hard-coded.

#### Scenario: Tema padrão
- **WHEN** o app inicia
- **THEN** usa o tema claro "Solar Frontier" (rust como marca; areia/ink como neutros)

### Requirement: Contraste acessível
O sistema SHALL manter as duplas de cor obrigatórias em conformidade WCAG 2.2 AA
(4.5:1 texto, 3:1 UI) nos temas claro e escuro, verificável por
`design-system/scripts/validate_contrast.py`.

#### Scenario: Verificação na fonte
- **WHEN** os tokens de cor mudam
- **THEN** `validate_contrast.py` passa em todas as duplas obrigatórias (light e dark)

### Requirement: Sem emoji
O sistema SHALL NOT usar emoji em nenhuma saída (UI, código, copy); ícones vêm de um
set vetorial (lucide/Material) ou de palavras, conforme a regra do design-system.

#### Scenario: Ícones
- **WHEN** um glifo de ícone é necessário
- **THEN** usa-se um ícone vetorial coerente, nunca um emoji
