# federation

## Purpose
Federação do colono (`/profile/federation`, GDD §4): identidade, tesouro/contribuição,
cargos, regras de tributação, membros e aliadas. Drill-in do Perfil. Frontend/mock
(`FederationRepository` → `federation.json`).

## Requirements

### Requirement: Identidade e cargos (§4)
O sistema SHALL exibir nome/tag/lema da federação, contagem de membros até o máximo de **12**,
e os cargos **Líder** (voto de Minerva) e **Diplomata**.

#### Scenario: Cabeçalho da federação
- **WHEN** a tela de Federação abre
- **THEN** mostra o emblema, "X/12 membros" e os chips de Líder e Diplomata

### Requirement: Tesouro e contribuição (§4)
O sistema SHALL mostrar o fundo (Fert$) mantido na Capital e a taxa de contribuição diária
na faixa **1–10%** (padrão **3%**), além do aporte do jogador no dia.

#### Scenario: Barra de contribuição
- **WHEN** a taxa é 3%
- **THEN** a barra posiciona 3% dentro da faixa 1–10%

### Requirement: Tributação e mercado (§4)
O sistema SHALL apresentar tributação interna **grátis até 35%** (35% acima), **50%** de desconto
entre aliadas e limite antimonopólio dinâmico **20% → 10%**; e listar as federações aliadas.

#### Scenario: Regras e aliadas
- **WHEN** há federações aliadas
- **THEN** cada uma mostra o badge "−50% troca"
