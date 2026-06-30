# colony-slot

## Purpose
A Colônia = **Slot do colono** (`/map/colony`, GDD v24 §17): a base do jogador renderizada
em Flame, com **construções** (produção, estrutura, militar, transporte) + slots livres +
especialização. NÃO são "lotes de recurso". Drill-in a partir do mapa-planeta; a Capital
(governo) é separada, alcançada por botão. Frontend/visual com mock data.

## Requirements

### Requirement: Construções do Slot
O sistema SHALL renderizar a estrutura central + as construções do §17 (Captação de Água,
Oficina, Fazenda, Reator de Energia, Refinaria Química, Gerador de Atmosfera, Quartel,
Central de Transportes, Plataforma de Pouso) + slots livres, cada construção com sprite ou
ícone de fallback, badge de nível e (produção) rótulo `±x/h`.

#### Scenario: Carregamento com mock
- **WHEN** a Colônia é aberta
- **THEN** lê via `WorldRepository.loadColonyBase` (mock: `assets/fixtures/colony.json`)
- **AND** desenha terreno + estrutura central + construções + slots livres

### Requirement: Produção conforme o GDD
O sistema SHALL exibir produção por hora coerente com a fórmula §19 (`Base×1.5^(N-1)`,
níveis comuns ≤5); especializações aplicam o modificador (§19.7, ex.: Aquífero Profundo
+90% de água).

#### Scenario: Construção de especialização
- **WHEN** a colônia tem especialização Hídrica
- **THEN** a água é produzida pelo Aquífero Profundo (variante potencializada), não pela Captação comum

### Requirement: Especialização e Capital
O sistema SHALL mostrar a especialização do Slot no cabeçalho e oferecer acesso à Capital
(governo) por botão "Capital"; a estrutura central também abre a Capital.

#### Scenario: Abrir Capital
- **WHEN** o jogador usa o botão "Capital" (ou a ação da estrutura central)
- **THEN** navega para `/capital` (os 20 slots de instituição de governo)

### Requirement: Fluxo de construir em slot livre
O sistema SHALL, ao acionar um slot livre, abrir um seletor (bottom-sheet) com as
estruturas construíveis do §17; a ação é mock (feedback).

#### Scenario: Construir
- **WHEN** o jogador toca "Construir" num slot livre
- **THEN** abre o seletor de estruturas; escolher uma dá feedback "em breve"
