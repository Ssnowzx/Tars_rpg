# Backend Fertways / Tars_rpg — imagem isolada (NestJS 11 + Prisma 6).
# Contexto de build: ../backend
FROM node:22-slim

# openssl e ca-certificates são exigidos pelos engines do Prisma.
RUN apt-get update \
 && apt-get install -y --no-install-recommends openssl ca-certificates \
 && rm -rf /var/lib/apt/lists/*

# pnpm 9 (lockfileVersion 9.0) via corepack.
RUN corepack enable && corepack prepare pnpm@9 --activate

WORKDIR /app

# Instala dependências primeiro para aproveitar cache de camada
# (só reinstala quando o manifesto/lock mudar).
COPY package.json pnpm-lock.yaml ./
RUN pnpm install --frozen-lockfile

# Código-fonte + geração do client Prisma + build Nest.
COPY . .
RUN pnpm prisma generate && pnpm run build

ENV NODE_ENV=production
EXPOSE 3000

# Aplica migrations pendentes e sobe a API.
CMD ["sh", "-c", "pnpm prisma migrate deploy && node dist/main"]
