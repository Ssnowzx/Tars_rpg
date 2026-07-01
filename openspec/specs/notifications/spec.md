# notifications

## Purpose
Centro de Notificações (`/map/notifications`, transversal): agrega eventos de todos os sistemas,
com severidade por cor + forma e badge no sino do HUD. Frontend/mock
(`NotificationRepository` → `notifications.json`).

## Requirements

### Requirement: Agregação e sino do HUD
O sistema SHALL agregar eventos de guerra (§27), Reputações (§9), Gagarin (§12.1), mercado, missões
(§6), federação (§4), cargos (§14), leilões (§13) e frota (§16); o sino do HUD SHALL ser clicável e
exibir o badge com a contagem de não-lidas (lido de `notificationsProvider`).

#### Scenario: Badge de não-lidas
- **WHEN** há N notificações não lidas
- **THEN** o sino do HUD mostra o badge "N" e abre o centro ao ser tocado

### Requirement: Severidade por cor + forma
O sistema SHALL distinguir a severidade por **cor E forma** (ícone diferente por nível:
info=círculo, sucesso=check, atenção=triângulo, crítico=octógono), nunca só por cor, com legenda.

#### Scenario: Legenda de severidade
- **WHEN** o centro abre
- **THEN** exibe a legenda "Severidade por cor + forma" com os 4 níveis

### Requirement: Filtros e ações com deep-link
O sistema SHALL filtrar por Todas/Não lidas/Importantes (com contagem) e cada notificação com rota
SHALL navegar direto à tela de origem (ex.: "Ver frota" → `/map/fleet`).

#### Scenario: Ação com rota
- **WHEN** uma notificação tem rota e sua ação é tocada
- **THEN** navega para a rota (ex.: /map/fleet)
