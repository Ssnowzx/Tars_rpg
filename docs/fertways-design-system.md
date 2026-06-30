# Fertways — Design System ("Solar Frontier")

Documentação do sistema visual do **Fertways: The Next Colony** (cliente Flutter + Flame).
Direção escolhida: **Solar Frontier** — claro, quente, futurista (Marte ao amanhecer),
no formato de um HUD de estratégia denso (linhagem Travian/Ikariam).

> Escopo atual: **frontend/visual**, com **mock data**. Sem backend.

---

## 1. Fonte de verdade e fluxo

```
design-system/tokens/*.json   (DTCG — fonte única, agnóstica de framework)
        │  espelhado/gerado
        ▼
app/lib/app/theme/
  ├── ds_colors.dart   → FwPalette (constantes) + FwColorScheme (light/dark)
  ├── ds_tokens.dart   → DsTokens (ThemeExtension: espaçamento, raios, motion, cores extra)
  └── ds_theme.dart    → FwTheme.light / FwTheme.dark (ThemeData)
```

- **Nada de valores hard-coded** na UI: ler cor/medida via `Theme.of(context)` /
  `Theme.of(context).extension<DsTokens>()!`.
- Se mudar os tokens no JSON, atualizar o espelho Dart (ou regerar via token-build).
- O tema **claro** é o padrão (`themeMode: ThemeMode.light`); o escuro existe e também
  passa nos gates de contraste.

---

## 2. Cor

Arquitetura 3-tier (Primitive → Semantic → Component), DTCG, em
`design-system/tokens/colors.json`.

### Primitivas (chave)
| Rampa | Papel | Âncoras |
|---|---|---|
| `gray` | Neutros quentes areia→ink | 50 `#FBFAF7` · 100 `#F7F6F3` (página) · 600 `#6E6151` (texto 2º) · 900 `#2A2118` (texto) |
| `rust` | **Marca** (Marte) | 600 `#C1440E` (primária) · 700 `#A53909` |
| `solar` | Acento solar/ouro | 400 `#F2A33C` · 500 `#E8941E` |
| `teal` | Acento frio/tech | 500 `#2C7E78` · 700 `#1E534F` (link) |
| `green` | Eco / sucesso / delta + | 500 `#2E9466` |
| `red` | Guerra / perigo / delta − | 500 `#CE3B2E` |
| `purple` | Federação | 600 `#7538C4` |

### Semânticas (uso na UI)
- `action.primary` → rust.600 (texto branco = **5.12:1**, AA).
- `text.primary` → ink; `text.secondary` → gray.600; `text.link` → teal.700.
- `surface.page` → areia (#F7F6F3); `surface.card` → #FBFAF7.
- `border.strong` → gray.600 (≥3:1, bordas essenciais); `border.default` → decorativa.
- `category.*` (gameplay): brand=rust, eco=green, info=teal, warning=solar, war=red, federation=purple.

### Regras de cor
1. **Nunca cor sozinha** — sempre cor + ícone + rótulo (recursos, categorias, deltas).
2. **Token por intenção** — destrutivo usa `red`, primário usa `rust`; consistente em todo lugar.
3. Paleta limitada e quente; teal/solar como acentos, não como base.

---

## 3. Tipografia
- **Inter** — toda a UI (corpo, labels).
- **Rajdhani** — display/numérico (nome da colônia, valores de recurso, badges, timers).
- **JetBrains Mono** — números tabulares (uso pontual; `FontFeature.tabularFigures`).
- Escala Major Third (1.25): 12 / 14 / 16 / 18 / 20 / 24 / 30 / 36 / 48…

## 4. Espaçamento, raios e motion (`DsTokens`)
- **Espaçamento** base 4px: `space1..space8` = 4/8/12/16/24/32.
- **Raios**: `radiusSm` 4 · `radiusMd` 6 · `radiusLg` 8 · `radiusButton` 6 · `radiusCard` 12.
- **Controles**: `controlMd` 40 · `controlLg` 48 · `touchTarget` 48 (WCAG 2.5.8).
- **Motion**: `durationFast` 100 · `base` 200 · `moderate` 300 (≤500ms); curvas `easeOut`/`easeInOut`.
- **Cores extra** no DsTokens: `surfacePage`, `surfaceSunken`, `borderDefault`, `borderStrong`,
  `textSecondary`, `success`, `warning`, `info`, `federation`, `focusRing`, `solar`, `teal`,
  `deltaUp`, `deltaDown`.

---

## 5. Componentes (Flutter)
- **TopResourceBar** (`features/hud/resource_hud.dart`) — brasão + colônia/nível/XP +
  chips de recurso (valor/capacidade + produção/h colorida) + cluster do jogador (avatar).
- **AppShell** (`features/shell/app_shell.dart`) — `NavigationRail` (desktop) /
  `NavigationBar` (Android) + barra de ações inferior; topo = TopResourceBar.
- **ConstructionPanel** (`features/world_map/view/construction_panel.dart`) — fila de obras
  com barra de progresso + tempo + "Concluir agora".
- **PlotDetailPanel** (`features/world_map/view/plot_detail_panel.dart`) — detalhe do lote
  ao tocar (nome, categoria, nível, stats, Melhorar/Detalhes).
- **Capital slot cards** (`features/capital/capital_screen.dart`) — faixa de cor por
  categoria + ícone + nome + badge "Nv"; slots livres tracejados.

## 6. Mapa (Flame) — sistema de lotes
`features/world_map/game/fertways_world_game.dart`:
- **Terreno**: `SpriteComponent` de `mars-colony-map-dawn-v1.png` (fundo, priority -10).
- **`_BaseLayer`** (priority -5): estradas Capital→lote + **Capital** (sprite `capital-v1.png`
  ~160px ≈1.35× dos lotes; fallback vetorial).
- **`_PlotComponent`** (tocável): sprite isométrico do edifício + badge de nível + nome;
  fallback para círculo + ícone se a arte faltar.
- Helpers compartilhados: `plotKindColor`, `plotKindIcon`, `plotKindSpriteAsset`.

Assets em `app/assets/images/` (todos 1536×1024, fundo transparente): terreno + 5 edifícios
(`plot-{factory,water,metals,biomass,energy}-v1.png`) + `capital-v1.png` + `avatar-vale-v1.png`
+ `crest-v1.png`. Prompts e workflow de arte: `docs/image-generation.md`.

---

## 7. Acessibilidade
- Contraste **WCAG 2.2 AA** garantido na fonte (light + dark) — gate
  `design-system/scripts/validate_contrast.py`.
- **Sem emoji** em qualquer saída (gate `check_no_emoji.py`); ícones vetoriais ou palavras.
- Informação nunca só por cor (cor + ícone + rótulo).
- Alvos de toque ≥48dp; `Semantics` nos elementos interativos/HUD.
- i18n pt-BR/es/en via ARB; layouts toleram expansão de texto.

## 8. Dados (mock)
Costura de repositório: a UI conhece só interfaces (`domain/repositories/*`); hoje
implementações mock (`data/mock/*` lendo `assets/fixtures/*.json`) com latência simulada;
troca por API em `data/providers.dart` (Riverpod), sem mexer na UI.

---

## 9. Verificação / gates
Token (rodam na fonte):
```
python3 design-system/scripts/validate_tokens.py
python3 design-system/scripts/validate_contrast.py
python3 design-system/scripts/check_no_emoji.py
```
Flutter:
```
cd app
flutter analyze
flutter build web --pwa-strategy=none --no-tree-shake-icons   # ver nota do service worker
flutter test
```
> **Service worker (web):** builds antigos ficam em cache e mascaram mudanças. Para
> verificação, build com `--pwa-strategy=none` e sirva `build/web` num porto novo
> (`python3 -m http.server <porta>`). `--no-tree-shake-icons` preserva os glifos de
> ícone desenhados no canvas do Flame.

## 10. Como estender
- **Novo tipo de lote**: adicionar valor em `PlotKind` + mapear cor/ícone/sprite em
  `plotKindColor/Icon/SpriteAsset` + entrada no `world.json`.
- **Nova tela**: criar feature em `lib/features/`, rota no `app/router.dart`, ler dados
  por repositório/provider, estilizar só com tokens/DsTokens.
- **Nova cor/marca**: editar `design-system/tokens/colors.json`, rodar `validate_contrast.py`,
  atualizar o espelho em `ds_colors.dart`.
- **Nova arte**: seguir `docs/image-generation.md` (prompts) + `tools/chroma_key.py` (alfa).
