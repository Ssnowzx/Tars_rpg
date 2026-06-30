# app-shell-hud

## Purpose
O invólucro persistente do jogo: barra superior de recursos (HUD), navegação
adaptativa (rail no desktop / barra inferior no Android) e barra de ações. Direção
visual "Solar Frontier".

## Requirements

### Requirement: Barra de recursos persistente
O sistema SHALL exibir, no topo e em todas as telas, o brasão + nome da colônia +
nível/XP, os contadores de recurso (Fert$ e os estoques com valor, capacidade e
produção por hora) e o cluster do jogador (notificações, ajuda, config, avatar).

#### Scenario: Produção negativa
- **WHEN** um recurso tem produção por hora negativa (ex.: Energia)
- **THEN** o delta é exibido em vermelho com seta para baixo
- **AND** produção positiva aparece em verde com seta para cima

#### Scenario: Cor + rótulo (acessibilidade)
- **WHEN** um recurso é exibido
- **THEN** a informação é dada por ícone + rótulo + valor, nunca só por cor

### Requirement: Navegação adaptativa
O sistema SHALL apresentar `NavigationRail` à esquerda em telas largas (web desktop)
e `NavigationBar` inferior em telas estreitas (Android), preservando o estado de cada
aba ao alternar.

#### Scenario: Quebra de layout
- **WHEN** a largura disponível cruza o breakpoint
- **THEN** a navegação alterna entre rail e barra inferior sem perder o estado das abas

### Requirement: Barra de ações (desktop)
O sistema SHALL exibir, em telas largas, uma barra inferior de ações secundárias
(Construir, Recrutar, Pesquisar, Relatórios, Missões, Mensagens) e um indicador de status.

#### Scenario: Tela larga
- **WHEN** a largura disponível está acima do breakpoint (desktop)
- **THEN** a barra inferior de ações secundárias é exibida (separada da navegação principal no rail)
- **AND** em telas estreitas a barra inferior é a navegação principal (NavigationBar), sem a barra de ações
