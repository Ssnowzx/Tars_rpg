# Fertways — Estado do Projeto (handoff para nova sessão)

> **Leia este arquivo primeiro.** É o ponto único de entrada para retomar o trabalho.
> Atualizado: 2026-06-30.

## 1. O que é
**Fertways: The Next Colony** — MMO de **estratégia/gestão de colônia** (NÃO RPG; §24.1),
Marte 2387. **Fonte de verdade: `FERTWAYS_GDD_v29.html`** (raiz; supera v24 — §1–§22 mantêm os
números, v29 adiciona §24–§27). Escopo atual: **frontend/visual only**, tudo com **mock data** atrás
de interfaces de repositório (backend ADIADO; ignorar §23 Docker/Laravel).

## 2. Stack
- **Cliente:** Flutter (web + Android), código em `app/`.
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
| `/market` | Mercado Central (§13/§8) | `MarketRepository` / `market.json` | ✅ |
| `/market/informal` | Comércio Informal + antifraude (§8) | `MarketRepository.loadInformalBoard` / `informal.json` | ✅ |
| `/map/messages` | Mensagens (§10, 5 canais) | `ChatRepository` / `chat.json` | ✅ |
| `/map/missions` | Missões/Conquistas/Eventos (§6) | `MissionRepository` / `missions.json` | ✅ |
| `/profile/federation` | Federação (§4, tesouro/cargos/membros) | `FederationRepository` / `federation.json` | ✅ |
| `/spaceport` | Espaçoporto (§3, 5 planetas NPC) | `SpaceportRepository` / `spaceport.json` | ✅ |
| `/profile` | Perfil (§5/§8) | `ProfileRepository` / `profile.json` | ✅ |
| HUD (shell) | Barra de recursos | `colonyProvider` (header) + `resourcesProvider` (`player.json`) | ✅ |

Sub-rotas (`/map/colony`, `/map/zone`, `/map/messages`, `/map/missions`, `/capital/ministry`,
`/capital/rankings`, `/market/informal`, `/profile/federation`) são **drill-ins** dentro do shell → mantêm
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

## 8. GDD v29 — novidades (NÃO inventar; reconciliar)
v29 mantém §1–§22 (números do v24) e ADICIONA 4 capítulos que afetam o que já existe:
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
§27.8, novatos §27.11, manutenção §27.12 — tela de Zona, E2). **v29 COMPLETA.** Retomando Bloco B (B3
Mensagens §10 →). (Título sem corpo = bloqueio, não inventar.)

## 9. Próximos passos (Bloco B — profundidade)
~~B1 Ministérios da Capital~~ ✅ (slots do `/capital` viram telas — `MinistryRepository`/`ministries.json`;
Reputações é stub→B5). ~~B2 Comércio Informal + antifraude~~ ✅ (`/market/informal`;
`MarketRepository.loadInformalBoard`/`informal.json`). ~~B3 Mensagens~~ ✅ (`/map/messages`,
`ChatRepository`/`chat.json`). ~~B4 Federações~~ ✅ (`/profile/federation`,
`FederationRepository`/`federation.json`; entrada = chip da federação no Perfil). ~~B5 Reputações/justiça~~ ✅
(slot Reputações do `/capital/ministry`; `ReputationRepository`/`disputes.json`; `reputation_panel.dart`).
~~B6 Progressão/Missões~~ ✅ (`/map/missions`; `MissionRepository`/`missions.json`; ação "Missões" da barra).
**Próximo: B7.** · B7 Frota/Transportes (§16/§21) ·
B8 Cargos Públicos (§14) · B9 Leilões (§13) · B10 Centro de Notificações.
Dívidas: i18n (telas em pt hard-coded → ARB); produção/consumo dinâmicos; ações mock
(SnackBar) → fluxos reais. Ver `docs/fertways-roadmap.md`.

## 10. Mapa de documentos
- `docs/fertways-roadmap.md` — roadmap detalhado (Blocos A/B/C, status por item).
- `docs/fertways-changelog.md` — evolução/decisões (versões do GDD, correções de modelo).
- `docs/fertways-design-system.md` — design system Solar Frontier.
- `docs/image-generation.md` — prompts de arte (terreno full-bleed §22 etc.).
- `docs/visual-history/` — evolução visual (mapas antigos arquivados + README).
- `docs/t2-shelf/` — código desativado p/ Temporada 2 (vista de "lotes" antiga).
- `openspec/specs/` — specs por capacidade. `FERTWAYS_GDD_v24.html` — GDD atual.
