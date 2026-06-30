# Fertways — Geração de imagens (prompts + workflow)

Receita reutilizável para gerar os assets do jogo numa IA de imagem externa (Midjourney /
DALL·E·GPT image / Flux·SDXL) no estilo **Solar Frontier** (Marte ao amanhecer, claro,
futurista). Não há IA de imagem nativa no projeto — gere fora, remova o fundo, e plugue.

## Workflow
1. Gerar na IA com os prompts abaixo (mesma ferramenta p/ consistência).
2. Se não houver fundo transparente real: gerar com **fundo branco `#FFFFFF` liso** e
   remover com `tools/chroma_key.py` → PNG com alfa.
3. Salvar em `app/assets/images/` com **exatamente** os nomes da tabela.
4. Mapear/plugar no código (já há fallback) e verificar:
   `cd app && flutter analyze && flutter build web --pwa-strategy=none --no-tree-shake-icons`.

> **Consistência (crucial):** mesma ferramenta, **mesma luz (cima-esquerda)**, mesmo
> ângulo iso ~45°, escala/área parecidas (só a Capital maior). Use a Fábrica v1 como
> *style reference* (Midjourney `--sref <url>`; DALL·E/GPT: anexe a imagem). Sempre `--no text`.

## Tabela de assets
| Arquivo | Conteúdo | Usado em |
|---|---|---|
| `mars-colony-map-dawn-v1.png` | Terreno (fundo do mapa) | Flame `SpriteComponent` (priority -10) |
| `plot-factory-v1.png` | Fábrica Olympus | `plotKindSpriteAsset(PlotKind.factory)` |
| `plot-water-v1.png` | Aquífero Tharsis | `PlotKind.water` |
| `plot-metals-v1.png` | Mina Borealis | `PlotKind.metals` |
| `plot-biomass-v1.png` | Estufa Elysium | `PlotKind.biomass` |
| `plot-energy-v1.png` | Campo Solar | `PlotKind.energy` |
| `capital-v1.png` | Capital (herói) | `_BaseLayer` |
| `avatar-vale-v1.png` | Retrato Cmdt. Vale | HUD (`TopResourceBar`) |
| `crest-v1.png` | Brasão Fertways | HUD (brasão) |

---

## BLOCO DE ESTILO (cole no FIM de TODO prompt de edifício)
```
Isometric 45-degree high-angle orthographic view, painterly semi-realistic stylized
game-building asset matching a warm "Mars at dawn" strategy world map (Forge of Empires /
SimCity BuildIt style). Single structure centered, full building visible, clean readable
silhouette. Warm dawn key light from the upper-left, soft contact shadow directly beneath
only, small integrated foundation pad. Cohesive warm palette: rust-painted weathered metal
#C1440E, sand-beige trim #E6DECF, solar-gold accents #F2A33C / #E8941E, teal tech glow
#2C7E78. Isolated on a fully transparent background, no terrain, no scenery, no sky, no
text or signage, no people, no UI. High resolution, crisp.
```

## NEGATIVE (igual em todos — Flux/SDXL no campo negativo; Midjourney `--no ...`)
```
background, terrain, ground plane, scenery, sky, landscape, text, signage, lettering,
watermark, logo, UI, people, characters, multiple separate buildings, cropped, cut off,
blurry, photoreal gritty, dark, night, lens flare, Earth-like forest, drop shadow on background
```

## Settings
- Proporção ideal **1:1** (a v1 saiu 1536×1024 — uniforme, mas não quadrado).
- Alta resolução (≥1536). Fundo transparente; senão branco `#FFFFFF` liso (→ chroma key).
- Midjourney: `--ar 1:1 --style raw --sref <fábrica> --no text`.

---

## Terreno (mapa base) → `mars-colony-map-dawn-v1.png`
```
Top-down aerial view of a terraformed Mars colony region, clean stylized game-map
illustration in the style of browser strategy MMO world maps (Travian, Anno, Ikariam) —
warm, bright "Mars at dawn" mood, optimistic sci-fi, NOT dark or grim.

Natural uninhabited terrain only (no buildings, no settlements): rust-orange and ochre
martian rock with fine warm sand dunes (rust #C1440E, #D2611F, sand #E6DECF / #F7F6F3),
patches of terraformed green farmland and mossy plains (#3DDB84, #2E9466), small teal-blue
water reservoirs and ice pockets (#2C7E78, #4FACDE), a few low crater rims and rocky ridges
toward the edges, faint winding dirt tracks. A large gently flat open plain in the center.
Low dawn sun with soft solar-gold rim light (#F2A33C), long soft shadows, diffuse lighting.

Painterly but crisp, semi-realistic stylized, cohesive limited warm palette, light overall
tone, low-to-medium contrast so a game UI can sit on top, seamless full-frame composition,
high detail. 16:9.
```
Negative: `text, watermark, UI, people, buildings, city, structures, dark, night, vignette, gritty photoreal, lens flare, dense Earth forest`.

---

## Edifícios (descrição = parte que muda; some + BLOCO DE ESTILO)

**Fábrica Olympus → `plot-factory-v1.png`**
```
Isometric game building asset of a Mars colony manufacturing / refinery factory: a domed
fabrication hall plus a rectangular hangar, two refinery silos/towers, vents and short
chimneys with faint steam, rooftop solar panels, exposed pipes, small comms antenna.
```

**Aquífero Tharsis → `plot-water-v1.png`**
```
Isometric game building asset of a Mars colony WATER EXTRACTION / AQUIFER PUMP STATION:
a drilling derrick over a borehole, cylindrical cisterns and tanks holding teal-tinted
water, tall atmospheric water-collector mesh towers, a rust-panel pump house, pipes and a
small teal reservoir basin, faint mist. Teal accents prominent.
```

**Mina Borealis → `plot-metals-v1.png`**
```
Isometric game building asset of a Mars colony FERROUS ORE MINE: an open-pit excavation
head with a mining rig and gantry crane, an ore conveyor leading to a crusher tower, heaps
of rust-red ore, heavy machinery and support struts, faint dust haze. Rust-red ore tones
with warm metal grays and small teal machine lights.
```

**Estufa Elysium → `plot-biomass-v1.png`**
```
Isometric game building asset of a Mars colony BIODOME GREENHOUSE: a large translucent
geodesic glass dome with lush green crops and hydroponic racks visible inside, one or two
smaller domes and a service module, rust-and-sand metal frame, teal-tinted glass. Vivid
green foliage inside (#3DDB84) contained within the warm-toned structure.
```

**Campo Solar → `plot-energy-v1.png`**
```
Isometric game building asset of a Mars colony SOLAR ENERGY PLANT: a neat array of tilted
photovoltaic panels with gold/teal sheen arranged around a central energy-collector tower
(soft glowing fusion core), capacitor and battery units, thick cabling. Solar-gold
dominant with a subtle teal energy glow.
```

**Capital · Ares Prime → `capital-v1.png`** (herói — maior/mais imponente; `--no text, vehicles, spaceship`)
```
Isometric game building asset of a Mars colony CAPITAL / COMMAND HUB, the main base —
grander and larger than other buildings: a prominent central dome with a command tower, a
comms dish and antenna mast, surrounded by modular habitat pods and a small landing pad,
premium rust + solar-gold palette with subtle teal lights, a few colony banners (no text).
Imposing hero structure.
```

---

## Retrato e marca (estilo próprio, não isométrico)

**Avatar Cmdt. Vale → `avatar-vale-v1.png`**
```
Character portrait of "Commander Vale", governor of a Mars colony, year 2387 — confident
woman in a practical rust-and-sand sci-fi colony uniform with subtle teal tech trim,
shoulders-up, three-quarter view, warm soft lighting, painterly semi-realistic stylized
game-portrait art (clean, friendly, heroic). Transparent or flat neutral background.
Square 1:1. No text, no UI, no watermark.
```

**Brasão Fertways → `crest-v1.png`**
```
Emblem / crest for a Mars colony game "Fertways" — a clean minimal heraldic badge: a
stylized rust-orange hexagon/planet motif with a small solar sunrise arc and a subtle leaf
or terraform spark, flat vector-style game logo mark, warm palette (rust #C1440E, solar
gold #F2A33C, sand). Centered, isolated on transparent background, no text, no lettering.
```

---

## Ícones de recurso/UI
Feitos **em código (SVG vetorial)**, não por image-gen — nítidos em qualquer tamanho,
coloríveis por token, alinhados à regra no-emoji. Não use IA de imagem para eles.

## Histórico de issues (v1)
- Fábrica v1 tem letreiro "MARS FABRICATION" (regerar com `--no text` se incomodar).
- Capital v1 tem uma nave pequena no pad (`--no vehicles, spaceship`).
- Todos saíram 1536×1024 (uniformes; para 1:1 estrito, regerar com `--ar 1:1`).

---

## PROMPT — Terreno do mapa-PLANETA (full-bleed, v6+)
Arquivo em uso: `mars-solar-frontier-map-v6.png` (3072×2048, 3:2). **Full-bleed obrigatório**:
o terreno preenche a moldura inteira, sem borda/faixa/vinheta. Aspecto **3:2**, resolução
máxima (a IA entrega ~1536×1024; upscale 2× Lanczos p/ zoom). **Sem prédios/texto/veículos/UI.**

```
Stylized top-down high-oblique game world map of a single Martian continent at dawn —
FULL-BLEED: the terrain fills the ENTIRE frame edge to edge and extends past all four
edges. NO border, no frame, no margin, no vignette, no letterbox, no black or white bars,
no passe-partout, no background showing anywhere. Cohesive warm "Solar Frontier" palette
(warm sand base #F7F6F3, rust #C1440E, solar gold #F2A33C, teal #2C7E78 accents), soft
dawn light. Distinct biome regions by compass, separated by WIDE deserts:
- CENTER: flat warm-sand fertile plain (open capital basin);
- NORTH: pale blue-white polar ice cap with teal frozen lakes;
- EAST: deep rust-red iron mountains and eroded canyons (rust belt);
- SOUTH: bright ochre cracked solar plateau;
- WEST: teal-green terraformed greenbelt patches (no domes);
- NORTHEAST: darker industrial badlands.
Faint dirt trails connect the regions toward the center. Leave open flat clearings for
building placement. Painterly, clean, readable strategy-game map (Travian/Anno feel),
high-oblique flat angle (NOT a globe/orbital view). No buildings, no characters, no
vehicles, no text, no icons, no UI, no border. 3:2 aspect ratio, terrain bleeds to every
edge, high resolution.
```
- Midjourney: `--ar 3:2 --no text, buildings, vehicles, ui, border, frame, vignette`.
- Nota: a v6 atual **já não tem borda embutida** (medido: 0px). A "borda preta" no app era
  do enquadramento — resolvido no código com zoom-mínimo *cover* (terreno preenche a tela
  em qualquer proporção). Este prompt é p/ manter futuras regerações full-bleed.
