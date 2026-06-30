# spaceport

## Purpose
Espaçoporto (`/spaceport`, GDD §3): comércio com os 5 planetas NPC + frota de Cargueiros
Interplanetários. Frontend/mock.

## Requirements

### Requirement: Planetas NPC
O sistema SHALL listar os 5 planetas NPC (Kalidor, Veyra, Auryn, Solène, Drakmoor) com
distância, risco da rota (chip por nível: nenhum/baixo/alto), exporta e importa, lidos via
`SpaceportRepository.loadSpaceport` (mock: `assets/fixtures/spaceport.json`).

#### Scenario: Carregamento
- **WHEN** o Espaçoporto é aberto
- **THEN** mostra os 5 planetas com distância, risco, exporta/importa

### Requirement: Risco da rota
O sistema SHALL codificar o risco por cor/ícone (Nenhum = sucesso, Baixo = aviso, Alto =
perigo) no card do planeta.

#### Scenario: Rota perigosa
- **WHEN** o planeta tem risco "Alto — escolta opcional" (Drakmoor)
- **THEN** o chip de risco aparece em vermelho

### Requirement: Frota e envio
O sistema SHALL exibir a frota disponível (Cargueiros x/total) e oferecer "Enviar carga"
por planeta (mock).

#### Scenario: Enviar carga
- **WHEN** o jogador toca "Enviar carga" num planeta
- **THEN** dá feedback "Enviar Cargueiro a <planeta> (<distância>) — em breve"
