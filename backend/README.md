# Fertways — Backend

Servidor autoritativo do jogo (GDD v33): economia (Fert$), combate, missões,
reputação e permissões vivem aqui. **NestJS + TypeScript (strict) + Prisma +
MariaDB.** Frontend Flutter web consome via HTTP (troca os mocks do seam de
repositório por implementações de API).

> Estado: **loop core funcional** — schema completo (47 modelos) + auth JWT +
> colônia/recursos/fila de construção + Mercado com escrow e livro-razão Fert$ +
> dados de referência semeados. Demais domínios (federações, combate, justiça,
> leilões…) têm schema pronto; endpoints entram incrementais.

## Stack
- **NestJS 11** (Node 20, TS strict) — módulos, DI, guards.
- **Prisma 6** (`provider = "mysql"`, cobre MySQL/MariaDB).
- **MariaDB 11.4** via Docker (`docker-compose.yml`, host **3308**).
- Fert$ = `Decimal(18,4)`; livro-razão append-only (`LedgerEntry`).

## Pré-requisitos
- Node 20+ (via fnm/nvm), pnpm 10+.
- Docker Desktop rodando.

## Como rodar
```bash
cd backend
cp .env.example .env            # DATABASE_URL aponta pro MariaDB do Docker (3308)
pnpm install                    # já aprova os build scripts do Prisma
pnpm db:up                      # sobe o MariaDB (docker compose up -d)
pnpm prisma:migrate             # aplica migrações (prisma migrate dev)
pnpm seed                       # popula preços, luas, planetas, terraformação, missões
pnpm start:dev                  # NestJS em watch (http://localhost:3000/api)
```

Verificação:
```bash
curl http://localhost:3000/api/health   # { "status":"ok", "db":"up", ... }
curl http://localhost:3000/api          # { "name":"Fertways API", ... }
```

## Endpoints (loop core)
Auth por Bearer JWT (obtido em register/login). `*` = exige token.

| Método | Rota | O quê |
|---|---|---|
| POST | `/api/auth/register` | cria conta + colônia inicial + 50 Fert$ (§onboarding); devolve tokens |
| POST | `/api/auth/login` | autentica; devolve access + refresh |
| POST | `/api/auth/refresh` | renova o access token |
| GET | `/api/me` * | perfil do jogador + reputação (4 índices) |
| GET | `/api/colony` * | colônia + construções |
| POST | `/api/colony/buildings/:id/upgrade` * | evolui construção → enfileira obra |
| POST | `/api/colony/build` * | constrói no slot livre → enfileira obra |
| GET | `/api/resources` * | estoques + saldo Fert$ |
| GET | `/api/build-queue` * | fila (contagem regressiva, fila dupla §20.2) |
| POST | `/api/build-queue/:id/cancel` * | cancela obra |
| POST | `/api/build-queue/:id/complete` * | conclui obra na hora (mock) |
| GET | `/api/market/prices` | preços-base (§22) |
| GET | `/api/market/board` * | board do Mercado (tickers + ordens reais com ids reais) |
| GET | `/api/market/listings` * | anúncios abertos |
| POST | `/api/market/listings` * | cria anúncio (escrow reserva o recurso) |
| POST | `/api/market/listings/:id/buy` * | compra (Fert$ via ledger + taxa 3% + transfere recurso) |
| POST | `/api/market/listings/:id/cancel` * | cancela e devolve o escrow |
| GET | `/api/fleet` * | frota do jogador (registros `Vehicle` + vagas de hangar) |
| POST | `/api/fleet/:id/maintain` * | manutenção (cobra Fert$, restaura condição) |
| POST | `/api/fleet/:id/scrap` * | sucateia o veículo |
| GET | `/api/missions/board` * | board de missões/conquistas/eventos por jogador |
| POST | `/api/missions/:id/claim` * | resgata a recompensa de uma missão concluída |
| GET | `/api/federation` * | federação do jogador (`inFederation:false` se não filiado) |
| GET | `/api/auctions` * | casa de leilões (nível real do jogador) |
| GET | `/api/lunar` · `/api/terraform` · `/api/spaceport` · `/api/missions` | dados de referência semeados |
| GET | `/api/notifications` * | notificações do jogador |
| GET | `/api/config/:key` | config canônica compartilhada (capital, ministérios, mapa, boards etc.) |

Scripts úteis: `pnpm db:down` (derruba o banco), `pnpm prisma:studio`
(explorador visual), `pnpm build`, `pnpm test`.

## Banco de dados
- **MariaDB no Docker**, host `3308` (o `3306` local é um MySQL de outro projeto;
  o `3307` é de outro container). O usuário `fertways` recebe privilégios globais
  (`docker/init.sql`) só para o Prisma criar o *shadow database* de `migrate dev`.
- **47 modelos** cobrindo todos os domínios do GDD v33: identidade/auth,
  reputação (4 índices) + diário, colônia + construções + recursos + **fila de
  construção**, **livro-razão Fert$** (append-only), mercado (escrow) + comércio
  informal (Acordo de Troca) + leilões, federações + tratados, justiça/denúncias,
  missões/conquistas/eventos, frota/veículos, cargos públicos, território/zonas +
  unidades + combate + ranking, espaçoporto/NPC, notificações + chat,
  terraformação, exploração lunar (luas + boletins Gagarin) e config do servidor.
- Schema: `prisma/schema.prisma`. Migrações: `prisma/migrations/`.

## Estrutura
```
backend/
  docker-compose.yml       # MariaDB 11.4 (host 3308)
  docker/init.sql          # grant p/ shadow DB do Prisma
  prisma/schema.prisma     # schema completo (47 modelos)
  prisma/migrations/       # migração init
  prisma/seed.ts           # seed: preços, luas, planetas, terraformação, missões
  src/
    main.ts                # bootstrap (prefixo /api, CORS, ValidationPipe, shutdown)
    app.module.ts          # ConfigModule + Prisma + Ledger + módulos de domínio
    prisma/, common/       # PrismaService (@Global), LedgerService, decorators, utils
    auth/                  # register/login/refresh (JWT + refresh), JwtStrategy/Guard
    player/ colony/ resources/ build-queue/   # loop core
    market/                # escrow + ledger + taxa
    content/ notifications/ health/           # leitura de referência + health
```

## Próximos passos
1. Endpoints dos demais domínios (schema já pronto): federações, justiça/denúncias,
   território/combate (§27), leilões, cargos públicos, frota, chat.
2. **Produção por hora** (job/cron aplicando `perHour` aos estoques) e conclusão de
   obras por agendador (hoje é preguiçosa, ao ler/enfileirar).
3. Testes e2e (supertest) e `ReputationEvent`/auditoria nas ações sensíveis.
4. Trocar os mocks do frontend (`app/lib/data/mock/*`) por implementações `Api…`
   apontando para este backend (o seam de repositório já isola isso).
