# fleet

## Purpose
Frota do colono (`/map/fleet`, GDD §21 + §16.4): veículos com capacidade, condição/depreciação,
situação operacional e ações. Drill-in da Colônia (botão "Frota"). O registro de placas civis
(§16.3) permanece no Ministério dos Transportes. Frontend/mock (`FleetRepository` → `fleet.json`).

## Requirements

### Requirement: Veículos e situação (§21)
O sistema SHALL listar os veículos (Furgão, Caminhão, Drone, Robô Minerador, Nave Longa Distância,
Nave Transporte Planetária, Tanque de Combustível, Cargueiro) com placa, capacidade (m³), horas de
uso e situação (Ocioso/Em trânsito/Carregando/Manutenção/Bloqueado), ordenados por urgência.

#### Scenario: Resumo da frota
- **WHEN** a tela de Frota abre
- **THEN** mostra hangar X/Y, nº em trânsito, nº para manutenção e capacidade total

### Requirement: Depreciação e limite crítico (§16.4)
O sistema SHALL depreciar por horas de uso apenas Furgão e Caminhão; abaixo do limite crítico o
veículo fica **Bloqueado** até manutenção. Os demais não depreciam.

#### Scenario: Veículo abaixo do limite
- **WHEN** um Caminhão está com condição abaixo do limite crítico
- **THEN** exibe status "Bloqueado" e a tarefa "abaixo do limite crítico"

### Requirement: Ações da frota
O sistema SHALL oferecer Manutenção (custo Fert$), Despachar (se ocioso) e Sucatear (mock).

#### Scenario: Veículo ocioso
- **WHEN** um veículo está Ocioso
- **THEN** mostra o botão "Despachar"
