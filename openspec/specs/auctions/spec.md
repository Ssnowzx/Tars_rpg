# auctions

## Purpose
Casa de Leilões de peças únicas (`/market/auctions`, GDD §13): desbloqueia no Nível 100 (Lenda),
por isso a tela é uma prévia com lances bloqueados. Drill-in do Mercado (botão "Leilões").
Frontend/mock (`AuctionRepository` → `auctions.json`). A loja AbacatePay (dinheiro real) está
FORA de escopo (backend adiado).

## Requirements

### Requirement: Gate de Nível 100 (§13)
O sistema SHALL bloquear os lances até o Nível 100 (Lenda de Fertways), mostrando banner com a
barra de progresso do jogador; o botão de lance fica desabilitado ("Nível 100").

#### Scenario: Jogador abaixo do nível
- **WHEN** o jogador está abaixo do Nível 100
- **THEN** o banner explica o desbloqueio e os lances ficam travados

### Requirement: Bloqueio de acesso (§9.4 / §26.2)
O sistema SHALL indicar que Persona Non Grata (§9.4) ou Confiança Comercial baixa (§26.2) também
bloqueiam o acesso aos leilões.

#### Scenario: Nota de bloqueio
- **WHEN** o banner de bloqueio é exibido
- **THEN** cita Persona Non Grata e Confiança Comercial

### Requirement: Lotes ativos e histórico
O sistema SHALL listar lotes com raridade (única/lendária/rara), cronômetro, lance atual (Fert$),
nº de lances e líder (destacando "Você lidera"); e um histórico de encerrados (vencedor/preço/dia).

#### Scenario: Lote liderado pelo jogador
- **WHEN** o lance líder é do jogador
- **THEN** o lote mostra "Você lidera"

### Requirement: Lances e fechamento reais (backend, §13)
O sistema SHALL registrar lances (`Bid`) validando gate Nível 100, incremento mínimo e saldo, elevando o
lance atual do lote (`Auction`). Ao vencer o prazo, o lote SHALL encerrar, cobrar o vencedor no livro-razão
e entregar o prêmio via notificação; o histórico reflete os encerrados reais. Lotes/nível vêm por jogador
(`GET /auctions`, `POST /auctions/:id/bid`).

#### Scenario: Lance vence e é entregue
- **WHEN** um jogador Nível 100 lidera um lote e o prazo vence
- **THEN** o lote encerra, o vencedor é cobrado e recebe a notificação de entrega do item
