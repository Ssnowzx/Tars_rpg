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

### Requirement: Fila de construção autoritativa (§17/§20)
O sistema SHALL manter a fila de construção no servidor; enfileirar (construir/evoluir) e concluir aplicam o
nível real da construção. A fila dupla (2 vagas) vale nos primeiros 5 dias (§20.2).

#### Scenario: Evoluir construção
- **WHEN** o jogador evolui uma construção na Colônia
- **THEN** o backend cria a obra e, ao concluir, incrementa o nível da construção

### Requirement: Config canônica servida do servidor (`/config/:key`)
O sistema SHALL servir a config estática do jogo (Capital, ministérios, mapa-planeta, boards de mercado/
leilões/frota/federação/justiça/rankings/cargos/chat/combate) a partir de `ServerConfig`, no shape que o
frontend consome (`Model.fromJson`), removendo os mocks client-side.

#### Scenario: Tela lê config do servidor
- **WHEN** uma tela de referência carrega
- **THEN** o repositório `Api…` busca `/config/:key` e desserializa direto no modelo (sem mock)
