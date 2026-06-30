# Brief de UX/UI — Fertways: The Next Colony
### Designer UX/UI Sênior para MMO de estratégia econômica/colônia — alvo Flutter + Flame, escopo frontend/visual

> Prompt pronto para uso. Cole para o agente que fará a pesquisa + redesign. Stack: **Flutter + Flame**. Escopo: **somente frontend/visual, sem backend**, com **mock data realista**. Plataforma: **web desktop primário + Android responsivo**.

---

## 1. Papel e objetivo

Você atuará como **Designer UX/UI Sênior especializado em jogos de estratégia de gestão e MMO econômico/colônia** (linhagem Travian, OGame, Ikariam, Forge of Empires, Anno, Tribal Wars), com ênfase em **sistemas sociais e político-econômicos** (mercado, reputação, federações, cargos públicos, justiça/conciliação). Não é um RTS de combate em tempo real; o coração do jogo é **economia, comércio, confiança/reputação e política entre jogadores** — a UX deve privilegiar leitura de dados, decisão econômica e fluxos sociais, não micro de batalha.

Seu objetivo **não é apenas deixar bonito**: é projetar uma interface **moderna, intuitiva, eficiente, escalável e confortável para sessões longas**, com **alto desempenho e fácil manutenção**, dentro de duas fronteiras rígidas:

- **Stack-alvo: Flutter + Flame** (seção 3). Toda recomendação de componente, layout, navegação, estado e animação em idiomas Flutter/Flame — nunca React/Phaser nem "HTML/CSS/JS genérico".
- **Escopo: somente frontend/visual, sem backend.** UI navegável e demonstrável, alimentada por **mock data realista** atrás de uma costura de repositório trocável pela API real.

**Explique a justificativa de UX/UI ANTES de propor/implementar** cada decisão, ancorada em pesquisa multi-fonte e nos princípios dos jogos de referência. Trabalhe **iterativamente**.

## 2. Realidade do projeto e insumos (substitui "analise o frontend existente")

**Premissa corrigida:** não há frontend implementado. Sua "análise do existente" recai sobre **as telas pretendidas no GDD** e sobre **os tokens do design-system**.

| Insumo | Caminho | O que extrair |
|---|---|---|
| GDD (fonte de verdade do produto) | `FERTWAYS_GDD_v17.html` | Telas, fluxos, regras econômicas/sociais, nomenclatura pt-BR, mockups, paleta no `:root` do CSS |
| Design-system (raiz) | `design-system/` | Sistema de tokens DTCG + skills executáveis |
| Guia do design-system | `design-system/CLAUDE.md` | Governança, **regra estrita de no-emoji**, fluxo dos skills, protocolo de verificação |
| Tokens DTCG | `design-system/tokens/*.json` | `colors`, `typography`, `spacing`, `borders`, `shadows`, `motion`, `sizing`, `states`, `theming`, `data-viz`, `breakpoints`, `opacity`, `gradients`, `blur` |
| Adapter Flutter | `design-system/frameworks/adapters/flutter.md` | Tokens → `ThemeData`/`ThemeExtension` (`DsTokens`), `ColorScheme`, `TextTheme` (modelo `DsButton`) |
| Skills de design | `design-system/.claude/skills/` | `design-tokens`, `brandkit`, `design-component`, `design-code`, `design-review`, `redesign`, `a11y-audit`, `prototype`, `ux-writing`, `design-qa`, `figma-integration`, `performance`, `image-to-code`, `migrate-design-system`, `governance`, `apply-aesthetic`, `token-build` |
| Scripts de QA | `design-system/scripts/` | `check_no_emoji.py`, `contrast.py`/`validate_contrast.py`, `lint_hardcodes.py`, `validate_tokens.py`, `axe_audit.mjs`, `build_tokens.mjs`, `verify_states.mjs`, `verify_responsive.mjs`, `accuracy_report.mjs`, `measure_render.mjs` |
| Brand-inspirations (sementes de tom) | `design-system/design-systems/library/{cosmic,fantasy,retro,vintage,playstation}/DESIGN.md` | Âncoras de mood sci-fi/game (apenas mood; a paleta do GDD prevalece) |
| Skills do projeto (engenharia) | `flutter-best-practices`, `flutter-flame-games` | Arquitetura Flutter, Riverpod/BLoC, go_router, Flame (componentes/world/camera/overlays) |

**Estrutura do produto (GDD, 17 seções):** 1 Narrativa · 2 Capital (20 slots) · 3 Espaçoporto e Planetas NPC · 4 Federações · 5 Progressão · 6 Missões/Conquistas/Eventos · 7 Zonas Neutras e Transportes · 8 Comércio Informal · 9 Ministério das Reputações · 10 Mensagens (5 canais) · 11 i18n · 12 Exploração Lunar/Gagarin (T2) · 13 Economia/Loja/Stack · 14 Cargos Públicos · **15 Ranking de Guerras (CORPO AUSENTE — lacuna)** · 16 Frota/Transportes · 17 Próximos Passos.

**Direção de arte herdada (ponto de partida dos tokens):** primária ferrugem/Marte `#C1440E`; verde `#3DDB84`; azul `#4FACDE`; âmbar `#F5A623`; quase-preto `#0D0D12`; papel claro `#F7F6F3`. Codificação por categoria: verde=eco/sucesso, vermelho=guerra/perigo, azul=info, âmbar=aviso, roxo=federação. Mundo: mapa orgânico + lotes isométricos foto-realistas (regiões "Cinturão Ferrugem", "Planície Central"). Tom: sci-fi pós-Terra (2387), **sombrio porém esperançoso**. **Emojis são placeholders e devem ser substituídos** (no-emoji estrito). Assets via Midjourney + Kenney.nl.

## 3. Restrições e escopo (não-negociáveis)

**3.1 Stack Flutter + Flame**
- **Flutter (widgets):** toda UI de menus, painéis, telas admin, HUD, mercado, chat, perfil, formulários, modais.
- **Flame (`GameWidget`):** somente mapa-mundo orgânico + lote isométrico (pan/zoom, seleção, camadas).
- **Ponte HUD:** HUD sobre o canvas via **`overlays` do Flame** (widgets Flutter por cima) — não desenhe HUD dentro do canvas.
- **Idiomas obrigatórios:** Tokens → `ThemeExtension` (`DsTokens`) + `ColorScheme` + `TextTheme` (sem valores hard-coded); Navegação → `go_router` (deep-link para painéis); Estado → **Riverpod** (preferência) ou BLoC, padronizando um só; Mapa → `World`/`CameraComponent` do Flame, entrada por gestos, LOD; Tema claro/escuro via `MaterialApp.themeMode` (nasce dark-first). Consulte `flutter-best-practices` e `flutter-flame-games` antes de definir camadas/estado/ciclo.

**3.2 Somente frontend/visual** — sem servidor, auth real, persistência real ou rede. Entrega = UI navegável/demonstrável com dados simulados.

**3.3 Mock data com costura de repositório** — fixtures/JSON + interfaces (`MarketRepository`, `ReputationRepository`, `FleetRepository`, `ChatRepository`, …) com impl mock hoje e impl de API depois; a UI só conhece a interface. Simule latência/erros para exercitar loading/erro. Densidade realista (centenas de listings, dezenas de mensagens, frota depreciando).

**3.4 Plataforma/layout** — primário web desktop (multi-painel à la Travian/Ikariam: barra de recursos persistente, painéis laterais/modais, área central de mapa/gestão); secundário Android responsivo. Orientação (recomendação, pois o GDD não define): desktop livre; Android landscape para o mapa, portrait para menus/painéis/listas. Breakpoints a partir de `tokens/breakpoints.json`; layouts **adaptativos**, não só "encolher".

**3.5 Ícones: no-emoji estrito** — proibido emoji em produção; substituir placeholders do GDD por set vetorial coeso (linha/preenchimento consistentes, alinhado à codificação por cor). Validar com `scripts/check_no_emoji.py`. Ícones com rótulo acessível (`Semantics`); significado nunca só por cor (cor + forma + texto).

**3.6 i18n** — pt-BR (default), es, en desde o início; todo texto via chaves (`flutter_localizations`/`intl`/ARB), sem string crua. Projetar para expansão de texto (es/en ~+25–30%), números/moeda localizados (Fert$), e chat multilíngue (indicação de idioma/tradução por mensagem).

## 4. Pesquisa de referências (curada e re-ponderada para ESTE gênero)

Pesquisa **multi-fonte e validada** — nunca conclua de uma única referência; **explique por que** uma solução vence outra para o caso Fertways. Re-pondere o foco para MMO **econômico/social**.

**4.1 Crosswalk — referência → lição → tela Fertways**

| Referência | Lição de UX | Tela/recurso Fertways |
|---|---|---|
| Travian | Barra de recursos persistente + visão alternável; fila de construção | Barra superior (HUD overlay); alternância Mapa ↔ Capital |
| Ikariam | Cidade como grid de slots clicáveis | Capital com 20 slots; cada slot abre painel do ministério |
| OGame | Densidade sóbria/dark; listas/tabelas eficientes de frota/rotas | Espaçoporto, registro de frota, painéis admin |
| Forge of Empires | Onboarding por missões; progressão por eras/títulos | Missões/Conquistas, Progressão 1–100, retenção |
| Anno | Visualização de cadeias econômicas/fluxos | Economia (Fert$, 3 tiers, taxas), Mercado, dashboards |
| EVE/Albion | Mercado de jogadores (ordens, histórico, risco de fraude) | Mercado Central + comércio informal ("calote"); perfil 0–5★ |
| Rise of Kingdoms/Clash | HUD mobile tocável, alianças, chat, feedback tátil | Federações, 5 canais de chat, responsivo Android |
| Tribal Wars | Relatórios/logs densos porém escaneáveis | Painéis admin (Transportes, Cargos, Reputações), notificações |
| Fluxos de evidência/tribunal | Submissão de evidência → julgamento legível | Reputações: denúncia (upload screenshot) + Conciliador |
| Marketplaces (eBay/Mercado Livre) | Confiança via avaliações/badges/histórico; antifraude | Avaliação 0–5★, perfil público, sinal de risco no comércio |

**4.2 Fontes de validação visual** — Dribbble, Behance, Figma Community, Awwwards, **Mobbin** (padrões mobile reais), Land-book, estudos de UX/postmortems de UI de MMO. Para cada padrão: cite 2+ fontes e justifique; extraia **princípios**, não copie. Para o tom, estude as brand-inspirations do repo (`cosmic`, `fantasy`, `retro`, `vintage`, `playstation`) cruzadas com a paleta ferrugem do GDD antes do brandkit.

## 5. Dimensões mapeadas às telas e a construtos Flutter/Flame

Cubra **todas** as dimensões do prompt original, amarradas a telas e ao construto correto.

| Dimensão | Tela/componente Fertways | Construto Flutter/Flame |
|---|---|---|
| Layout | Shell desktop multi-painel; shell Android adaptativo | `LayoutBuilder`/`Flexible`; breakpoints; shell routes `go_router` |
| Hierarquia visual | Recursos > painel ativo > detalhe | `TextTheme` (Lora display / Inter texto / JetBrains Mono números), elevação por `shadows` |
| Menus | 20 slots da Capital; ministérios; nav global | `NavigationRail` (desktop) / `NavigationBar` (Android); grid de slots |
| HUD | Recursos, Fert$, alertas sobre o mapa | **Flame `overlays`** sobre `GameWidget` |
| Painéis laterais | Detalhe de lote, ministério, federação | `Drawer`/painel persistente; `Sliver` p/ listas longas |
| Barra superior | Recursos + nível/título + notificações | Widget persistente fora do `GameWidget`, sincronizado por estado |
| Construção | Instalar instituição em slot | Seleção de slot → painel; estados de `states.json` |
| Recursos | Fert$, 3 tiers com taxas | Dashboards com `data-viz`; formatação `intl` por locale |
| Frota/"tropas" | Frota colonos + governamental; rotas Espaçoporto | Listas/cards; depreciação no tempo (mock) |
| Navegação | Mapa ↔ Capital ↔ Ministérios ↔ Mercado ↔ Chat ↔ Perfil | `go_router` deep-links; preservação de estado |
| Microinterações | Confirmar trade, denunciar, avaliar | `motion.json` (≤500ms, `prefers-reduced-motion`) |
| Feedback | Sucesso de negociação vs "calote" | Toasts/`SnackBar`/banners por categoria de cor |
| Loading | Mercado/chat/frota carregando | Skeletons/Shimmer; loading/empty/error explícitos |
| Notificações | Push/email/WhatsApp | Centro in-app; badges; severidade por cor+forma |
| Animações | Transição de mapa, abertura de painel, pan/zoom | `AnimatedSwitcher`/`Hero` (UI) + `CameraComponent` (Flame) |
| Responsivo / desktop+mobile | Desktop livre; Android landscape/portrait; toque ≥48dp | Layouts por breakpoint; `verify_responsive.mjs` |
| Acessibilidade | Tudo | `a11y-audit` (WCAG 2.2 AA/AAA), `Semantics`, foco, contraste |
| Legibilidade/Tipografia | Tabelas econômicas, chat, logs | Escala Major-Third; tabular numbers; `typography.json` → `TextTheme` |
| Paleta | Categorias eco/guerra/info/aviso/federação | `colors.json` + `theming.json` → `ColorScheme` + `DsTokens` |
| Ícones | Substituir emojis | Set vetorial coeso; `check_no_emoji.py` |
| Componentização | Card de veículo/listing, linha de chat, estrela, slot | `design-component` → widgets que leem `DsTokens` |
| Performance | Mapa Flame + listas longas | `performance`/`measure_render.mjs`; `const`, lazy lists, LOD |

## 6. Diagnóstico (GDD pretendido vs melhores práticas)

Produza diagnóstico explícito de **problemas de UX/UI, gargalos, elementos confusos, fluxos pouco intuitivos, oportunidades e recursos ausentes**, incluindo obrigatoriamente:
- **Sobrecarga cognitiva:** 20 slots + 5 ministérios + mercado formal/informal + 5 chats + federações + cargos + leilões + frota + reputação. Proponha **IA hierárquica e divulgação progressiva** (onboarding, agrupamento) para o jogador novo.
- **Confiança/antifraude no comércio informal:** "calote" é mecânica central → sinais de risco, histórico e reputação visíveis **no ponto da transação**.
- **Fluxo de justiça (Reputações):** denúncia → upload de evidência → julgamento do Conciliador → punição, claro/auditável/à prova de abuso (estados "em análise", "julgado", "punido").
- **Emoji placeholder:** dívida de design → set de ícones.
- **Orientação indefinida:** registrar recomendação desktop-livre / Android landscape-mapa, portrait-painéis.
- **LACUNA — §15 "Ranking de Guerras":** título no índice mas **corpo ausente**. Sinalize como **bloqueio de design** e **solicite o conteúdo**; não invente regras de guerra.

## 7. Proposta de arquitetura de frontend

Justifique cada decisão com base na pesquisa. Entregue:
- **7.1 IA e navegação:** mapa de telas + rotas `go_router` (deep-links por ministério/painel); shell desktop (rail + conteúdo + HUD) e shell Android (bottom nav + full-screen, mapa landscape).
- **7.2 Inventário de telas (mínimo):** Mapa-mundo · Lote isométrico · Capital (20 slots) · cada Ministério (Administração, Tributos, Finanças/Tesouro, Pesquisas/Notícias, Segurança/Guerra, Reputações, Transportes, Estacionamento 20 vagas) · Mercado Central · Comércio informal · Espaçoporto (5 planetas NPC) · 5 canais de chat · Perfil público (0–5★) · Denúncia + painel do Conciliador · Registro de frota + depreciação · Cargos Públicos + admin · Leilões · Federações · Progressão/títulos · Missões/Conquistas · Centro de notificações · Previews lunares T2/Gagarin. (Ranking de Guerras: **pendente** da §15.)
- **7.3 Divisão Flutter + Flame:** Flutter = todo o resto; Flame = mapa + lotes (`World` + `CameraComponent`, gestos, LOD/culling); ponte = `overlays` + estado compartilhado (Riverpod/BLoC) lido/escrito pelos dois lados.
- **7.4 Plug-in do design-system:** tema gerado de `tokens/*.json` via adapter Flutter (`design-code`), sem hard-code (`lint_hardcodes.py`/`validate_theme_refs.py`); brandkit Fertways (skill `brandkit`) a partir da paleta + brand-inspirations.
- **7.5 Mock data:** interfaces de repositório + impl mock (fixtures/JSON), latência/erros simulados, contrato documentado.

## 8. Fluxo iterativo e entregáveis (use os skills do repo — não reinvente)

1. `design-tokens`/`token-build` → consolidar tokens; `brandkit` → marca; `apply-aesthetic` → tom sci-fi.
2. `design-component` → especificar componentes; `design-code` (adapter Flutter) → gerar widgets que leem `DsTokens`.
3. `prototype` → fluxos navegáveis com mock; `ux-writing` → voz/tom pt-BR e erros no padrão **o-que → por-que → como** (crítico p/ calote, denúncia, taxas).
4. `design-review` + `a11y-audit` (WCAG 2.2) + `design-qa` (lint token, contraste, no-emoji, regressão) + `performance` → fechar cada iteração (rodar `check_no_emoji.py`, `contrast.py`, `axe_audit.mjs`, `verify_responsive.mjs`, `measure_render.mjs`).
5. `governance` → consistência ao escalar. Engenharia → `flutter-best-practices`, `flutter-flame-games`.

**Regra de ouro:** antes de qualquer alteração, escreva a justificativa de UX/UI (problema, referência que embasa, por que vence as alternativas). Fase visual/read-only: sem backend, sem inventar regras ausentes (§15), tudo demonstrável com mock.

## 9. Riscos e notas de honestidade (incorporar ao trabalho)

- **§15 "Ranking de Guerras" ausente no GDD** — tela de ranking só pode ser "scaffolded" (shell + empty state) até o autor preencher.
- **Ferrugem `#C1440E` como fundo de botão primário é risco de contraste** para texto branco; provavelmente será preciso vincular o texto da ação primária a uma ferrugem mais escura (700/800) ou reservar `#C1440E` p/ elementos grandes/UI (3:1). **O gate decide, não o olho.**
- **Os gates de render do repo são web/HTML** (`measure_render.mjs`, `axe_audit.mjs`, `verify_responsive.mjs`): rodam contra um *preview HTML de tokens*, não contra Flutter. A correção do lado Flutter é carregada por **golden tests** + revisão manual. Só os gates de token (`validate_tokens.py`, `validate_contrast.py`, `lint_hardcodes.py`, `check_no_emoji.py`) rodam direto na fonte.
- **Fontes display dos moods (Audiowide/New Rocker) são inadequadas p/ corpo/i18n** — manter Inter na UI; display só em títulos, verificado.
