# missions

## Purpose
Central de Missões, Conquistas e Eventos (`/map/missions`, GDD §6). A escada de progressão
1–100 (§5) vive no Perfil. Frontend/mock (`MissionRepository` → `missions.json`).

## Requirements

### Requirement: Sete tipos de missão (§6)
O sistema SHALL agrupar as missões pelos 7 tipos (Tutoria, Diária, Semanal, Narrativa, Federação,
Guerra, Evento), cada uma com progresso, recompensa, janela de tempo e estado
(Disponível/Em progresso/Pronta/Resgatada/Bloqueada). Diárias têm 1 rejeição.

#### Scenario: Aba Missões
- **WHEN** a aba Missões está ativa
- **THEN** as missões aparecem agrupadas por tipo com barra de progresso e recompensa

### Requirement: Conquistas por medalha (§6)
O sistema SHALL listar conquistas com medalha Bronze/Prata/Ouro/Platina; obtidas mostram
"Conquistada", as demais mostram cadeado + barra de progresso.

#### Scenario: Conquista bloqueada
- **WHEN** uma conquista não foi obtida
- **THEN** mostra o cadeado e o progresso atual/alvo

### Requirement: Eventos ativos
O sistema SHALL listar eventos ativos (Gagarin §12.1, tempestade, guerra §27, mercado) com
ícone/cor por tipo e tempo restante.

#### Scenario: Aba Eventos
- **WHEN** a aba Eventos está ativa
- **THEN** cada evento mostra tipo, descrição e tempo restante
