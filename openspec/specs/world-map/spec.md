# world-map

## Purpose
A tela principal (`/map`): o **mapa-PLANETA** macro (MMO), renderizado com Flame —
terreno ilustrado (biomas por bússola) com a colônia do jogador, colônias vizinhas,
zonas neutras, espaçoporto e marcos. Painéis flutuantes em widgets Flutter por cima.
Frontend/visual com mock data. (NÃO é mais "colônia radial com lotes" — ver
`docs/fertways-changelog.md`.)

## Requirements

### Requirement: Renderização do planeta
O sistema SHALL renderizar o planeta numa única camada Flame (`GameWidget`): terreno
3:2 de fundo + nós posicionados por coordenada (sua colônia, vizinhos, zonas neutras,
espaçoporto, marcos), com estradas suaves da colônia às zonas/espaçoporto e rótulos de
região (bioma).

#### Scenario: Carregamento com mock
- **WHEN** a tela do mapa é aberta
- **THEN** o estado é lido via `WorldRepository.loadPlanet` (mock: `assets/fixtures/planet.json`)
- **AND** enquanto carrega exibe indicador; em erro, ação de tentar de novo
- **AND** ao concluir, desenha terreno + nós + estradas + rótulos de região

### Requirement: Nós por tipo e relação
O sistema SHALL exibir cada nó conforme seu tipo (sua colônia, colônia vizinha, zona
neutra, espaçoporto, marco, slot livre) com cor/ícone próprios; vizinhos são coloridos
pela relação (aliado/neutro/hostil) e zonas pela cor do recurso, com badge de nível e
rótulo. Uma legenda explica as cores.

#### Scenario: Vizinho hostil
- **WHEN** um nó é uma colônia vizinha com relação hostil
- **THEN** é desenhado em vermelho com ícone de colônia e nível

### Requirement: Câmera sem borda
O sistema SHALL usar zoom-mínimo "cover" (o terreno preenche o frame inteiro em
qualquer proporção, sem faixa preta/branca) e travar o pan nas bordas do terreno;
botões de aproximar/afastar/centralizar e pinça/roda do mouse ajustam o zoom.

#### Scenario: Zoom mínimo
- **WHEN** o jogador afasta ao máximo
- **THEN** o terreno preenche a tela sem mostrar fundo além das bordas

### Requirement: Toque em nó roteia por tipo
O sistema SHALL abrir um painel ao tocar num nó e rotear a ação principal: sua colônia
→ `/map/colony`; espaçoporto → `/spaceport`; zona neutra → `/map/zone`; vizinho/slot
livre/marco → feedback mock (SnackBar) ou nota de lore.

#### Scenario: Toque na própria colônia
- **WHEN** o jogador toca na sua colônia e confirma a ação
- **THEN** navega para `/map/colony` (a Colônia/Slot)
