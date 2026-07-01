# Fertways — Estado do Projeto (handoff para nova sessão)

> **Leia este arquivo primeiro.** É o ponto único de entrada para retomar o trabalho.
> Atualizado: 2026-07-01.

## 1. O que é
**Fertways: The Next Colony** — MMO de **estratégia/gestão de colônia** (NÃO RPG; §24.1),
Marte 2387. **Fonte de verdade: `FERTWAYS_GDD_v33_MESTRE_INTEGRAL_SEM_SUPRESSOES.html`** (raiz;
edição mestre integral — supera v29: §1–§27 herdados + §0 tabela de precedência de 12 conflitos +
§28 correções). Escopo atual: **frontend/visual only**, tudo com **mock data** atrás de interfaces
de repositório. **Backend (a partir de 2026-07-01): `backend/` = NestJS+TS(strict)+Prisma+MariaDB** — schema
completo (47 modelos), auth JWT, loop core + Mercado (escrow + livro-razão Fert$), e **o FRONTEND FOI
TOTALMENTE DES-MOCKADO**: `providers.dart` binda todos os repos a implementações `Api…`. Dados dinâmicos vêm
de endpoints próprios; a config estática do jogo (Capital, ministérios, mapa, boards) vem de `/config/:key`
(seed lê os 14 fixtures → ServerConfig). **Tudo em `origin/main`.** Ver `backend/README.md` e [[fertways-backend]].
**Etapa 22 (01/07): DE-MOCK POR JOGADOR + MERCADO REAL.** Frota/Missões/Federação agora são **por jogador**
(registros Prisma) — colono novo começa limpo, Vale mantém o conteúdo de demonstração. **Mercado Central
transacional** (comprar de anúncios reais via `/market/listings/:id/buy` + vender via `/market/listings`,
escrow + taxa 3% + livro-razão). Ações reais: resgate de missão, manutenção/sucateamento de veículo.
Leilões/Perfil por jogador (nível real, chip de federação). Mocks (`app/lib/data/mock/*`) removidos.
Verificação clique-a-clique de TODAS as telas OK (sem erro de fromJson). Novos módulos NestJS: fleet/missions/
federation/auctions. Relatório: `docs/reports/22-backend-per-player.{html,pdf}`. GDD §14/§23 superados.
**Etapa 23 (01/07): ECONOMIA VIVA + DÍVIDAS FECHADAS.** Produção por hora real (acúmulo compute-on-read em
`/resources`, teto na capacidade). **Comércio Informal transacional** (modelo `InformalOffer` + `POST
/informal/:id/accept` swap atômico; botão Negociar ligado) e **Leilões transacionais** (`Auction`/`Bid` reais +
`POST /auctions/:id/bid` com gate Nível 100/incremento/saldo; botão Dar lance ligado). Novos módulos `informal/`;
migrações `production_accrual`+`informal_offers`. jest 11/11 · analyze/build limpos · verificado no Chrome.
Relatório: `docs/reports/23-economia-viva.{html,pdf}`. Tudo em `origin/main`.
**Etapa 24 (01/07): ECONOMIA COMPLETA + E2E + I18N.** Obra autoritativa com **custo em recursos** (§20) e
**produção que reage ao nível** (§19 — evoluir prédio → mais perHour → mais acúmulo; visto no HUD 88→132/h);
frontend mostra a mensagem real do servidor. **Fechamento de leilão** (§13 — encerra, cobra o vencedor,
histórico). **Testes e2e** dos fluxos (isolamento/mercado/informal/leilão) — acharam e corrigiram um bug real de
colisão de placa na frota inicial; suite 17 unit + 8 e2e verdes. **i18n**: idioma **persiste** (SharedPreferences)
+ tela de login trilíngue com seletor. Relatório: `docs/reports/24-economia-completa-i18n.{html,pdf}`.
Backlog: extração i18n do corpo das demais telas (incremental); receitas §24.5 completas. Tudo em `origin/main`.
**Como abrir do zero:** `cd backend && pnpm db:up && pnpm prisma:migrate && pnpm seed && pnpm start:dev` (usar
node v20 do fnm, NÃO o /opt/homebrew node quebrado) · `cd app && flutter run -d chrome` · login vale@fertways.test / colonia123.

## 2. Stack
- **Cliente:** Flutter **web-only**, código em `app/` (a pasta `android/` foi removida —
  empacotamento mobile será feito depois via **WebView** apontando pro web build; assim a VPS
  não precisa de Android SDK/JDK e evita sobrecarga).
- **Motor 2D:** Flame (mapas de Planeta e Colônia). HUD/painéis = widgets Flutter por cima.
- **Estado:** Riverpod. **Navegação:** go_router (`StatefulShellRoute.indexedStack`).
- **Tema:** "Solar Frontier" (claro/quente), tokens DTCG espelhados em `app/lib/app/theme/`.
- **i18n:** pt-BR (UI atual em pt hard-coded em várias telas — dívida; ARB só na base).
- Regras duras: sem emoji (ícones Material), sem valores hard-coded de cor/spacing (ler `DsTokens`).

## 3. Modelo do jogo (3 lugares — definido com o usuário + GDD v24)
- **Planeta** (`/map`) — mapa macro MMO: sua Colônia ★ + colônias vizinhas (relação) +
  zonas neutras (recurso) + espaçoporto + marcos. Bússola de biomas (N gelo/água, L
  cinturão ferrugem/metais, S platô solar/energia, O cinturão verde/biomassa, NE forjas).
- **Colônia = Slot do colono** (`/map/colony`) — base com **CONSTRUÇÕES** (v24 §17), NÃO
  "lotes". Produção dos recursos (Captação de Água, Oficina, Fazenda, Reator, Refinaria,
  Gerador de Atmosfera) + estrutural/militar/transporte + slots livres + **especialização**
  (1 de 15). A "Capital" é alcançada por botão daqui.
- **Capital** (`/capital`) — os **20 slots de instituição de GOVERNO** (§2.1), públicos.
- **Recurso extra** vem das **zonas neutras** (`/map/zone`): ocupar (Robô Minerador) →
  extrair (depósito 10 níveis) → transportar (Caminhão/Nave, 4 destinos). GDD §7/§16/§17.4.

> ⚠️ Erros já corrigidos (não repetir): (1) "Colônia com lotes de recurso" é convenção
> Travian/Ikariam, **NÃO** é Fertways → revertido, arquivos em `docs/t2-shelf/colony-view/`
> (reuso p/ bases lunares T2). (2) Colônia ≠ Capital: Colônia=Slot do colono (produção),
> Capital=governo (20 instituições). Ver `docs/fertways-changelog.md`.

## 4. Recursos (GDD v24 §18) — modelo expandido
- **Primários:** Oxigênio, Água, Biomassa, Energia.
- **Secundários:** Ligas Metálicas (era "Metais Ferrosos"), Compostos Químicos,
  Componentes Eletrônicos, Biocombustível.
- **8 minerais** (governo, comprados no Mercado) · **8 raros** (luas, T2) · **Fert$** = moeda.
- **Números reais:** produção/custo = `Base × 1.5^(N-1)` (§19/§20); preços-base do Mercado §22.

## 5. Telas vivas (rotas) e seus arquivos
| Rota | Tela | Repo / fixture | Status |
|---|---|---|---|
| `/map` | Mapa-Planeta (Flame) | `WorldRepository.loadPlanet` / `planet.json` | ✅ |
| `/map/colony` | Colônia/Slot (Flame, construções) | `loadColonyBase` / `colony.json` | ✅ |
| `/map/zone` | Zona Neutra (ocupar/extrair/transportar) | usa `MapNode` via `state.extra` | ✅ |
| `/capital` | Capital — 20 slots de governo | `CapitalRepository` / `capital.json` | ✅ |
| `/capital/ministry` | Ministério (10 painéis, §2.1) | `MinistryRepository` / `ministries.json` (`state.extra`=slot) | ✅ |
| `/capital/ministry` (slot Reputações) | Justiça §9 (denúncias/conciliação/punições) | `ReputationRepository` / `disputes.json` | ✅ |
| `/capital/rankings` | Ranking de Guerras (§15) | `RankingRepository` / `rankings.json` | ✅ |
| `/capital/offices` | Cargos Públicos Neutros (§14) | `PublicOfficeRepository` / `offices.json` | ✅ |
| `/market` | Mercado Central (§13/§8) | `MarketRepository` / `market.json` | ✅ |
| `/market/informal` | Comércio Informal + antifraude (§8) | `MarketRepository.loadInformalBoard` / `informal.json` | ✅ |
| `/market/auctions` | Leilões (§13, gate Nível 100) | `AuctionRepository` / `auctions.json` | ✅ |
| `/map/messages` | Mensagens (§10, 5 canais) | `ChatRepository` / `chat.json` | ✅ |
| `/map/missions` | Missões/Conquistas/Eventos (§6) | `MissionRepository` / `missions.json` | ✅ |
| `/map/fleet` | Frota do colono (§21/§16.4) | `FleetRepository` / `fleet.json` | ✅ |
| `/profile/federation` | Federação (§4, tesouro/cargos/membros) | `FederationRepository` / `federation.json` | ✅ |
| `/spaceport` | Espaçoporto (§3, 5 planetas NPC) | `SpaceportRepository` / `spaceport.json` | ✅ |
| `/spaceport/lunar` | Exploração Lunar / Telescópio Gagarin (§12) | `LunarRepository` / `lunar.json` | ✅ |
| `/map/terraform` | Terraformação Global (§04/§12.3) | `TerraformRepository` / `terraform.json` | ✅ |
| `/profile` | Perfil (§5/§8) | `ProfileRepository` / `profile.json` | ✅ |
| `/map/notifications` | Centro de Notificações (transversal) | `NotificationRepository` / `notifications.json` | ✅ |
| HUD (shell) | Barra de recursos + sino (badge não-lidas) | `colonyProvider` + `resourcesProvider` + `notificationsProvider` | ✅ |

Sub-rotas (`/map/colony`, `/map/zone`, `/map/messages`, `/map/missions`, `/map/fleet`, `/map/notifications`,
`/capital/ministry`, `/capital/rankings`, `/capital/offices`, `/market/informal`, `/market/auctions`,
`/spaceport/lunar`, `/map/terraform`, `/profile/federation`) são **drill-ins** dentro do shell → mantêm
HUD + nav rail. Providers em `app/lib/data/providers.dart`.

## 6. Arquitetura / convenções
- **Seam de repositório:** `domain/repositories/*` (interface) → `data/mock/mock_*` (impl,
  lê `assets/fixtures/*.json`, simula latência) → `data/providers.dart` (binding Riverpod).
  Trocar mock por API real = mudar só o binding no providers.
- **Modelos:** `domain/models/*` (com `fromJson`).
- **Telas Flame:** `features/*/game/*_game.dart` — câmera **cover** (terreno preenche o
  frame, sem borda preta) + `_clamp()` (pan travado nas bordas) + `zoomBy`/`resetView`.
- **Tema:** `Theme.of(context).extension<DsTokens>()!` para spacing/raios/cores semânticas;
  `FwPalette.*` para cores diretas.

## 7. Como rodar / verificar
```bash
cd app && export PATH="/opt/homebrew/bin:$PATH"
flutter analyze                                              # deve dar "No issues found"
flutter build web --pwa-strategy=none --no-tree-shake-icons  # deve dar "✓ Built"
flutter run -d chrome --web-port=8080                        # dev (hot restart = R)
```
- **DoD por tela:** analyze limpo + build web ✓ + seam de repo + estados loading/empty/error.
- **Gotcha de preview:** servir `build/web` via `python3 -m http.server <porta>` e abrir no
  Chrome **CACHEIA assets** (JSON/sprites) — o hard-reload não basta. Para verificação use
  **uma porta nova** por mudança de fixture (e mate a anterior — só uma viva). No `flutter
  run` (8080) o `R` pega tudo, sem esse problema.

## 8. GDD v33 — Mestre Integral (fonte de verdade atual)
v33 é **aditiva**: v3.0 integral (Parte II §2.1–§28.10) + v3.2 sanitizada (Parte I §01–§17) + **§0 tabela
de precedência** que resolve 12 conflitos. Ler as decisões vigentes do §0, NÃO o registro antigo:
- **Gagarin** = satélite orbital do Governo em órbita baixa (NÃO no casco da Endurance). Endurance em solo.
- **Central de Transportes** (§0 vs §28.5): upgrade libera vagas de frota; veículo é fabricado/comprado à parte.
- **Predador** = apreende **Módulos Operacionais** (NÃO captura pessoas) — §0 supera §28.7/§28.10.
- Reputação = 4 índices isolados · Tributação = 1 incidência por fato · Ranking = percentil empírico.

**Reconciliação v33 (feita):** ✅ **Central de Transportes** = "vagas de frota" (não caminhões grátis;
veículo fabricado/adquirido à parte — §0 supera §19.5/§28.5): painel `CentralTransportPanel` + modelo
`TransportLevel.slots` + `ministries.json`. ✅ **Proteção de novato = 8 dias** (§28.4 supera §27.11 "20
dias"): `combat.dart` + `zone_screen.dart`. **N/A:** §28.8 Mercado Local (tabela de custo não é exibida
na UI) · Predador (unidade não modelada — combate só tem Sentinela/Robô). Telas herdam v29 (§24–§27).

### v29 (herdado) — 4 capítulos que afetam o que já existe:
- **§24 Sanitização Econômica:** Metal Bruto (novo recurso), Mina Local/Governamental, receitas de
  Componentes (3), Biocombustível (Destilaria), subsídio (50 Fert$ + essenciais até nv3), nova fórmula
  de preço; **Identidade do Colono** (nickname/avatar) + **Diário do Colono**.
- **§25 Logística Unificada:** tributo único na **entrega física**; toda movimentação exige **veículo**
  (Furgão 6m³/6k · Caminhão 30m³/30k); **distância importa**; Mercado sensível à distância.
- **§26 Reputação = 4 índices** (Confiança Comercial/Conduta Social/Status Cívico/Honra Militar, 0–1000);
  Acordo de Troca; avaliação ≥500 Fert$; elegibilidade de cargo por índice.
- **§27 Combate Territorial:** unidade **Sentinela** (Quartel), combate por rodadas, saque 50%, proteção
  de novatos, manutenção; **§27.13 ranking por percentil** (corrige §15).

**Reconciliação (status):** ✅ B2 (§25+§26.5, R1) · ✅ Perfil (§26 4 índices + §24.3 Diário, R2) · ✅ Rankings
(§27.13, R3) · ✅ **Economia §24** (Metal Bruto, Mina Local, Destilaria, receitas §24.5, subsídio §24.7, preços
§24.8 — HUD/Colônia/Mercado, E1) · ✅ **Combate §27** (Sentinela §27.1, forças §27.3, previsão §27.5, saque
§27.8, novatos §27.11, manutenção §27.12 — tela de Zona, E2). **v29 COMPLETA.** Bloco B (B0–B10) também
concluído sobre essa base. (Título sem corpo no GDD = bloqueio, não inventar.)

## 9. Próximos passos (Bloco B — profundidade)
~~B1 Ministérios da Capital~~ ✅ (slots do `/capital` viram telas — `MinistryRepository`/`ministries.json`;
Reputações é stub→B5). ~~B2 Comércio Informal + antifraude~~ ✅ (`/market/informal`;
`MarketRepository.loadInformalBoard`/`informal.json`). ~~B3 Mensagens~~ ✅ (`/map/messages`,
`ChatRepository`/`chat.json`). ~~B4 Federações~~ ✅ (`/profile/federation`,
`FederationRepository`/`federation.json`; entrada = chip da federação no Perfil). ~~B5 Reputações/justiça~~ ✅
(slot Reputações do `/capital/ministry`; `ReputationRepository`/`disputes.json`; `reputation_panel.dart`).
~~B6 Progressão/Missões~~ ✅ (`/map/missions`; `MissionRepository`/`missions.json`; ação "Missões" da barra).
~~B7 Frota~~ ✅ (`/map/fleet`; `FleetRepository`/`fleet.json`; botão "Frota" na Colônia).
~~B8 Cargos Públicos~~ ✅ (`/capital/offices`; `PublicOfficeRepository`/`offices.json`; botão "Gerir" da
Administração Pública). ~~B9 Leilões~~ ✅ (`/market/auctions`; `AuctionRepository`/`auctions.json`; botão
"Leilões" no Mercado; gate Nível 100). ~~B10 Centro de Notificações~~ ✅ (`/map/notifications`;
`NotificationRepository`/`notifications.json`; sino do HUD com badge). **BLOCO B CONCLUÍDO (B0–B10).**

**Bloco C:** ~~C1 Exploração Lunar / Telescópio Gagarin~~ ✅ (`/spaceport/lunar`; `LunarRepository`/`lunar.json`;
§12 + §28.1–28.2). ~~C2 Ranking de Guerras~~ ✅ (feito no Bloco A4, §15). ~~C3 Terraformação Global~~ ✅
(`/map/terraform`; `TerraformRepository`/`terraform.json`; §04/§12.3). ~~C4 Fluxos reais de construção/upgrade~~
✅ (**1º estado mutável**: `build_queue.dart` + `data/build_queue_controller.dart` `NotifierProvider`+Timer;
painel de fila ao vivo na Colônia; enfileiram Colônia+Zona; fila dupla §20.2). ~~C5 i18n PT-BR/ES/EN~~ ✅
(`data/locale_controller.dart` `NotifierProvider<Locale?>` → `MaterialApp.locale`; seletor de idioma no HUD;
chrome traduzido nos 3 idiomas via ARB). **Reconciliação v33 feita** (§8). **BLOCO C (C1–C5) COMPLETO.**
Próximo: backlog i18n (extrair strings do corpo das telas) · dívidas C4 (dedução de recursos, nível persistente,
upgrades de ministério) · ou nova prioridade do produto.
Dívidas: i18n (telas em pt hard-coded → ARB); produção/consumo dinâmicos; ações mock
(SnackBar) → fluxos reais. Ver `docs/fertways-roadmap.md`.

## 10. Mapa de documentos
- `docs/fertways-roadmap.md` — roadmap detalhado (Blocos A/B/C, status por item).
- `docs/fertways-changelog.md` — evolução/decisões (versões do GDD, correções de modelo).
- `docs/fertways-design-system.md` — design system Solar Frontier.
- `docs/image-generation.md` — prompts de arte (terreno full-bleed §22 etc.).
- `docs/visual-history/` — evolução visual (mapas antigos arquivados + README).
- `docs/t2-shelf/` — código desativado p/ Temporada 2 (vista de "lotes" antiga).
- `docs/reports/` — relatório PDF por etapa concluída (01–17; `gen-pdf.sh`). Regra: cada etapa gera um.
- `openspec/specs/` — specs por capacidade (inclui B4–B10). **`FERTWAYS_GDD_v29.html`** — GDD atual
  (raiz; §1–§22 herdados do v24, +§24–§27).
