# backend-integration

## Purpose
Servidor autoritativo (`backend/` = NestJS + TS strict + Prisma + MariaDB) e integração do cliente Flutter
via HTTP. Substitui os mocks client-side: `providers.dart` binda todos os repositórios a implementações
`Api…`. Dados dinâmicos vêm de endpoints próprios; a config canônica do jogo vem de `/config/:key`. GDD §14
(Laravel/MySQL) e §23 ficam superados. Ver `backend/README.md` e a memória [[fertways-backend]].

## Requirements

### Requirement: Autenticação JWT com gate no cliente
O sistema SHALL autenticar por e-mail/senha (JWT access + refresh token hasheado); o registro cria, em
transação, jogador + colônia inicial + reputação (4 índices) + estoques + 50 Fert$ no livro-razão. O cliente
SHALL redirecionar para /login sem sessão válida.

#### Scenario: Login
- **WHEN** o jogador faz login com credenciais válidas
- **THEN** recebe tokens, o token é persistido e o app libera o shell (dados reais)

### Requirement: Livro-razão Fert$ append-only (§6)
O sistema SHALL registrar todo movimento de Fert$ em `LedgerEntry` (imutável) com saldo recomputado; a compra
no Mercado transfere recurso + Fert$ (taxa 3%) numa transação (escrow reserva o recurso do vendedor).

#### Scenario: Compra no Mercado
- **WHEN** um comprador adquire um lote anunciado
- **THEN** paga em Fert$ (débito no ledger), o vendedor recebe o líquido e o comprador recebe o recurso

### Requirement: Fila de construção autoritativa com custo e produção (§17/§19/§20)
O sistema SHALL manter a fila de construção no servidor; enfileirar (construir/evoluir) SHALL debitar o custo
em recursos (Metal Bruto + Energia, curva 1.5×) e devolvê-lo ao cancelar; concluir SHALL incrementar o nível
e o `perHour` da construção (curva 1.5×) e recalcular o `ResourceStock.perHour` daquela categoria. Obras
vencidas concluem também na leitura da colônia. A fila dupla (2 vagas) vale nos primeiros 5 dias (§20.2).

#### Scenario: Evoluir construção
- **WHEN** o jogador evolui uma construção na Colônia
- **THEN** o backend debita o custo, cria a obra e, ao concluir, sobe o nível e a produção do recurso

#### Scenario: Recurso insuficiente para a obra
- **WHEN** o jogador não tem o custo da obra
- **THEN** o backend rejeita e o cliente exibe a mensagem real do servidor (não "fila cheia")

### Requirement: Economia viva — produção por hora e receitas (§19/§24.5)
O sistema SHALL acumular produção "compute-on-read" em `GET /resources`: cada recurso ganha `perHour × horas`
desde `Player.producedAt`, limitado à capacidade. Recursos com **receita** (Biocombustível = 2 Biomassa +
3 Energia por unidade) SHALL consumir os insumos disponíveis, limitados pela oferta.

#### Scenario: Acúmulo com receita
- **WHEN** o jogador lê os recursos após um tempo
- **THEN** os primários acumulam por hora e o Biocombustível é produzido consumindo Biomassa + Energia

### Requirement: Domínios por jogador (registros Prisma)
O sistema SHALL servir Frota (`Vehicle`), Missões (`Player.missionState`) e Federação (`FederationMember`) por
jogador — um colono recém-registrado começa vazio/inicial (frota inicial, sem federação, board fresco), nunca
vendo os dados do jogador de demonstração. Perfil e Leilões refletem o nível/federação reais do jogador.

#### Scenario: Novo jogador isolado
- **WHEN** um jogador acaba de se registrar
- **THEN** `/fleet` traz a frota inicial, `/federation` retorna vazio e `/missions/board` vem fresco

### Requirement: Comércio transacional (§8/§13)
O sistema SHALL fechar transações reais: Mercado Central (comprar de anúncio com escrow + taxa 3% + livro-razão;
vender cria anúncio), Comércio Informal (aceitar oferta faz troca atômica de recursos, sem escrow) e Leilões
(dar lance valida gate Nível 100 + incremento mínimo + saldo; ao vencer o prazo, encerra, cobra o vencedor e
entrega o prêmio via notificação).

#### Scenario: Lance e entrega de leilão
- **WHEN** um jogador Nível 100 dá um lance válido e o prazo vence
- **THEN** o lote encerra, o vencedor é cobrado no livro-razão e recebe a notificação de entrega do item

### Requirement: Config canônica servida do servidor (`/config/:key`)
O sistema SHALL servir a config **compartilhada** do jogo (Capital, ministérios, mapa-planeta, justiça,
rankings, cargos, chat, combate) a partir de `ServerConfig`, no shape que o frontend consome (`Model.fromJson`).
Frota, missões, federação, leilões e comércio informal deixaram de ser config e passaram a endpoints por jogador.

#### Scenario: Tela de config compartilhada
- **WHEN** uma tela de dados de mundo compartilhados carrega
- **THEN** o repositório `Api…` busca `/config/:key` e desserializa direto no modelo (sem mock)
