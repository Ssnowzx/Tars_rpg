# Fertways — Backend

Servidor autoritativo do jogo (GDD v33): economia (Fert$), combate, missões,
reputação e permissões vivem aqui. **NestJS + TypeScript (strict) + Prisma +
MariaDB.** Frontend Flutter web consome via HTTP (troca os mocks do seam de
repositório por implementações de API).

> Estado: **fundação** — schema completo de todos os domínios + migração +
> health check. Endpoints por domínio (auth, colônia, mercado, combate…) entram
> incrementais.

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
pnpm start:dev                  # NestJS em watch (http://localhost:3000/api)
```

Verificação:
```bash
curl http://localhost:3000/api/health   # { "status":"ok", "db":"up", ... }
curl http://localhost:3000/api          # { "name":"Fertways API", ... }
```

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
  src/
    main.ts                # bootstrap (prefixo /api, CORS, shutdown hooks)
    app.module.ts          # ConfigModule (global) + PrismaModule
    prisma/                # PrismaService (@Global) — acesso único ao banco
    health/                # GET /api/health (ping no banco)
```

## Próximos passos
1. **Auth** (email/senha, JWT + refresh token) e `ValidationPipe` global.
2. Módulos por domínio expondo REST: `player`, `colony`, `resources`,
   `build-queue` (espelha o C4 do frontend), `market` (escrow + ledger), etc.
3. **Seed** (`prisma/seed.ts`): preços-base do Mercado (§22), 8 luas + boletins,
   planetas NPC, indicadores de terraformação, missões iniciais.
4. Trocar os mocks do frontend (`app/lib/data/mock/*`) por implementações `Api…`
   apontando para este backend (o seam de repositório já isola isso).
