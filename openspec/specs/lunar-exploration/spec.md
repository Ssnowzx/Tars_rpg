# lunar-exploration

## Purpose
Exploração Lunar / Telescópio Gagarin (`/spaceport/lunar`, GDD v33 §12 + §28.1–28.2): fundação
narrativa da Temporada 2. Mostra o status do satélite Gagarin, seus boletins, o catálogo das 8 luas
(homenagem ↔ atmosfera ↔ recurso raro) e os gatilhos da T2 (ativação do Gagarin e marco de 75% de
terraformação). Drill-in do Espaçoporto (botão dedicado) + atalho na Central de Pesquisas e Notícias.
Frontend/mock (`LunarRepository` → `lunar.json`). Bases/mineração/guerra lunares ficam FORA de escopo
(só na T2, por GDD complementar — §12.4).

## Requirements

### Requirement: Telescópio Gagarin — status e gatilho de ativação (§12.1 / §28.1)
O sistema SHALL exibir o Telescópio Orbital Gagarin como satélite do Governo (não vendável) em órbita
baixa — NÃO no casco da Endurance (§28.1) — com status Ativo/Inativo, canal (Central de Pesquisas e
Notícias), frequência (2–4 dias) e a barra de progresso do gatilho "50 jogadores OU 45 dias".

#### Scenario: Progresso do gatilho
- **WHEN** a tela carrega com jogadores cadastrados e dias de servidor
- **THEN** a barra usa a maior das duas frações (jogadores OU dias) e mostra os dois contadores

### Requirement: Boletins do Gagarin (§12.1)
O sistema SHALL listar os boletins publicados pelo Gagarin, cada um com categoria (lua/atmosfera/
recurso/anomalia), ciclo, horário, título e corpo.

#### Scenario: Boletim de anomalia
- **WHEN** um boletim é da lua Laika
- **THEN** aparece como "Anomalia" (sinal de origem desconhecida)

### Requirement: Catálogo das 8 luas (§12.2 / §28.2)
O sistema SHALL exibir as 8 luas (Armstrong, Tereshkova, Sagan, Aldrin, Ride, Leonov, Hawking, Laika)
com homenageado, atmosfera (similar/sem/tóxica), recurso raro associado e a leitura da Temporada 2.

#### Scenario: Lua ↔ recurso raro
- **WHEN** uma lua é exibida (ex.: Hawking)
- **THEN** mostra seu recurso raro associado (Plasma Fossilizado) com ícone/cor do recurso

### Requirement: Gatilhos da Temporada 2 e prévia bloqueada (§12.3 / §12.4)
O sistema SHALL mostrar o progresso da terraformação global rumo ao marco de 75% (gatilho oficial da
T2) e o evento "Janela de Órbita Lunar"; as bases lunares aparecem como prévia BLOQUEADA até a T2.

#### Scenario: Bases lunares bloqueadas
- **WHEN** a terraformação está abaixo de 75%
- **THEN** o cartão de bases lunares fica "Bloqueado" com a nota de que dependem de GDD complementar
