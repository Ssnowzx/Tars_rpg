# war-rankings

## Purpose
Ranking de Guerras (`/capital/rankings`, GDD §15): Ranking Geral (combinação ponderada) +
6 sub-rankings independentes. Alcançado pelo Ministério da Segurança e Guerra (Capital).
Frontend/mock. (§15 era lacuna até o GDD v24 — não inventar além do definido.)

## Requirements

### Requirement: Ranking Geral com pesos
O sistema SHALL exibir o Ranking Geral com os pesos do §15.3 (Zonas Conquistadas 25%,
Vitórias Totais 20%, Tempo de Controle 20%, Recursos Saqueados 15%, Guerras por Federação
10%, Maior Sequência 10%) e a tabela de classificados.

#### Scenario: Aba Geral
- **WHEN** a tela abre (lida via `RankingRepository.loadWarRankings`, `rankings.json`)
- **THEN** mostra os 6 pesos + leaderboard geral

### Requirement: 6 sub-rankings (§15.2)
O sistema SHALL oferecer um seletor entre Geral e os 6 sub-rankings (Vitórias Totais, Zonas
Conquistadas, Tempo de Controle, Maior Sequência, Recursos Saqueados, Guerras por
Federação), cada um com o que mede, o escopo e sua classificação.

#### Scenario: Trocar de ranking
- **WHEN** o jogador seleciona um sub-ranking
- **THEN** o cabeçalho mostra o que mede + escopo, e a lista muda

### Requirement: Destaque do jogador e federações
O sistema SHALL marcar a linha do próprio jogador ("VOCÊ") e diferenciar federações de
jogadores (ícone), com medalhas para os 3 primeiros.

#### Scenario: Sua posição
- **WHEN** o jogador aparece na lista
- **THEN** sua linha é destacada com o selo "VOCÊ"
