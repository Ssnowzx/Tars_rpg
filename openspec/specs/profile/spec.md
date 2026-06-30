# profile

## Purpose
Perfil público do jogador (`/profile`, GDD §5 progressão + §8/§9 reputação): identidade,
reputação 0–5★, nível/XP, escada de progressão de títulos, estatísticas e avaliações
recebidas. Frontend/mock.

## Requirements

### Requirement: Cabeçalho e reputação
O sistema SHALL exibir avatar, nome, título, setor, federação e a reputação (★ 0–5 + número
de avaliações), lidos via `ProfileRepository.loadProfile` (mock: `assets/fixtures/profile.json`),
além de nível e barra de XP.

#### Scenario: Carregamento
- **WHEN** o Perfil é aberto
- **THEN** mostra avatar/nome/título + ★média + avaliações + nível/XP

### Requirement: Escada de progressão (§5)
O sistema SHALL listar os títulos por nível (1 Sobrevivente … 100 Lenda de Fertways),
marcando os desbloqueados (nível atual ≥ requisito) e o título atual.

#### Scenario: Título atual
- **WHEN** o jogador é nível 14
- **THEN** títulos até Nv 10 aparecem desbloqueados; Pioneiro é marcado "ATUAL"; acima ficam travados

### Requirement: Estatísticas e avaliações (§8.4)
O sistema SHALL mostrar estatísticas (produção, trocas, zonas, vitórias) e a lista de
avaliações recebidas (★ + autor/setor + texto).

#### Scenario: Avaliação recebida
- **WHEN** existe uma avaliação no mock
- **THEN** ela é exibida com estrelas, autor·setor e o comentário
