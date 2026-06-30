# capital

## Purpose
A tela da Capital: grid das 20 instituições da colônia (GDD §2.1), no estilo
Solar Frontier, alimentada por mock data.

## Requirements

### Requirement: Grid de 20 slots
O sistema SHALL exibir os 20 slots da Capital em um grid responsivo, com um cabeçalho
que resume quantas instituições estão instaladas, lendo os dados via `CapitalRepository`
(mock: `assets/fixtures/capital.json`).

#### Scenario: Estados de carregamento
- **WHEN** a tela é aberta
- **THEN** mostra carregando; em erro, oferece tentar de novo; com dados, renderiza o grid

### Requirement: Slot instalado vs livre
O sistema SHALL distinguir visualmente slots instalados de livres: instalados mostram
faixa de cor da categoria, ícone, nome e badge de nível; livres mostram borda tracejada
com afordância de "Instalar".

#### Scenario: Categoria por cor + ícone + rótulo
- **WHEN** um slot instalado é exibido
- **THEN** a categoria é indicada por cor + ícone + rótulo textual (nunca só cor)

#### Scenario: Slot livre
- **WHEN** o slot não está instalado
- **THEN** exibe estado vazio tracejado com chamada para construir
