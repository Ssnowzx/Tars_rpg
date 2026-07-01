# Deploy Docker — Fertways / Tars_rpg

Stack isolada (rede e volume próprios, prefixo `tars-rpg`) para rodar o projeto
sem colidir com outros na mesma máquina. Três serviços:

| Serviço | Imagem | O que faz | Porta no host |
|---------|--------|-----------|---------------|
| `web`     | Flutter web + nginx     | Frontend (build de `../app`) | `127.0.0.1:4104` |
| `api`     | NestJS + Prisma         | Backend (build de `../backend`) | `127.0.0.1:4103` |
| `mariadb` | mariadb:11.4            | Banco de dados | interno (sem porta) |

## Subir

```bash
cp .env.example .env      # e ajuste os segredos
docker compose up -d --build
docker compose exec api pnpm prisma migrate deploy   # aplica migrations (o entrypoint já faz)
docker compose exec api pnpm seed                     # popula config/dados de referência
```

O frontend é buildado com `--dart-define=API_BASE_URL` apontando para o domínio
público (ver `Dockerfile.web`). Ao mudar de domínio, rebuild: `docker compose build web`.

## Proxy reverso (exemplo Apache)

Publique atrás de um vhost HTTPS roteando `/api` → 4103 e `/` → 4104:

```apache
ProxyPass        /api  http://127.0.0.1:4103/api
ProxyPassReverse /api  http://127.0.0.1:4103/api
ProxyPass        /     http://127.0.0.1:4104/
ProxyPassReverse /     http://127.0.0.1:4104/
```

## Comandos úteis

```bash
docker compose ps                 # status
docker compose logs -f api        # logs
docker compose build web api      # rebuild após mudar código
docker compose down               # para tudo (mantém o volume/dados)
```
