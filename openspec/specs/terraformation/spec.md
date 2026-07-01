# terraformation

## Purpose
Terraformação Global (`/map/terraform`, GDD §04 + §12.3): objetivo coletivo da temporada. Três
indicadores públicos (atmosfera, ciclo hídrico, biosfera) avançam por contribuição; ao alcançarem
**75%**, inicia-se a campanha lunar (gatilho da Temporada 2). Contribuir concede **apenas Status
Cívico** e cosméticos — nunca vantagem econômica/competitiva. Drill-in do Mapa (chip "Terraformação"
no mapa + botão na tela lunar). Frontend/mock (`TerraformRepository` → `terraform.json`).

## Requirements

### Requirement: Três indicadores rumo a 75% (§04 / §12.3)
O sistema SHALL exibir os três indicadores públicos (atmosfera, ciclo hídrico, biosfera) com barra de
progresso rumo ao marco de 75%, e indicar que o gatilho exige os TRÊS em 75% — o menor determina o
progresso coletivo.

#### Scenario: Menor indicador determina o gatilho
- **WHEN** os indicadores estão em percentuais diferentes
- **THEN** a nota do gatilho usa o menor deles e mostra quantos pontos faltam para 75%

### Requirement: Contribuição com limite anti-farming (§04)
O sistema SHALL mostrar a contribuição diária do jogador contra um teto anti-farming, o total
acumulado e a recompensa em Status Cívico; ao atingir o teto, a ação de contribuir é bloqueada.

#### Scenario: Teto diário atingido
- **WHEN** a contribuição de hoje iguala o teto diário
- **THEN** o botão "Contribuir" fica desabilitado ("Limite diário atingido")

### Requirement: Recompensa não-competitiva (§04)
O sistema SHALL deixar explícito que contribuir concede apenas Status Cívico e cosméticos/contratos —
nunca vantagem econômica ou competitiva.

#### Scenario: Nota de recompensa
- **WHEN** o cartão de contribuição é exibido
- **THEN** a nota cita "apenas Status Cívico e recompensas cosméticas/contratuais (§04)"

### Requirement: Gatilho da Temporada 2 (§12.3)
O sistema SHALL mostrar que 75% nos três indicadores dispara a campanha "Janela de Órbita Lunar" e o
gatilho da Temporada 2 (não automático), com atalho para a tela de Exploração Lunar.

#### Scenario: Progresso incompleto
- **WHEN** algum indicador está abaixo de 75%
- **THEN** o gatilho aparece como "Em progresso" e explica a dependência de GDD complementar
