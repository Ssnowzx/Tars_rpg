# Fertways — Histórico Visual (evolução da arte)

Registro documentado da evolução visual do jogo. Imagens aqui **não** entram no
bundle do app (ficam fora de `app/assets/images/`), mas são preservadas como
memória da evolução. Cada vez que uma arte for substituída no jogo, a versão
anterior vem para cá com nota do que mudou e por quê.

> Convenção: o arquivo **em uso** no runtime fica em `app/assets/images/`.
> Ao trocar, mova o antigo para `docs/visual-history/maps/` e registre abaixo.

---

## Mapa-mundo / Planeta — linha do tempo

Todos 3:2 (alta oblíqua plana, estilo Travian/Anno). Direção de arte "Solar Frontier"
(claro/quente: areia, rust, solar/ouro, teal).

| Versão | Arquivo | Resolução | Data | O que era / por que mudou |
|---|---|---|---|---|
| **dawn-v1** | `maps/mars-colony-map-dawn-v1.png` | 1536×1024 | 30/06 | 1ª arte: colônia de Marte ao amanhecer, centro aberto. Servia ao mapa **radial de colônia**. Aposentada quando o mapa virou **planeta** (macro MMO). |
| sf-v1 | `maps/mars-solar-frontier-map-v1.png` | — | 30/06 | 1ª tentativa "Solar Frontier" de planeta. Iterada. |
| sf-v4 | `maps/mars-solar-frontier-map-v4.png` | ~1536×1024 | 30/06 | Tentativa v4. Problemas: vista de globo/orbital, névoa nas bordas, biomas colados. |
| sf-v4-4k | `maps/mars-solar-frontier-map-v4-4k.png` | upscale 4K | 30/06 | Upscale da v4. Mesmos problemas de composição. |
| sf-v6-native | `maps/mars-solar-frontier-map-v6-native.png` | 1536×1024 | 30/06 | Original IA da v6 (fonte). |
| **sf-v6 ★ EM USO** | `app/assets/images/mars-solar-frontier-map-v6.png` | 3072×2048 (2× Lanczos) | 30/06 | **Atual.** Alta oblíqua plana, terreno preenche o frame (sem névoa), biomas separados por desertos amplos e **alinhados à bússola**: centro=planície / N=gelo+lagos teal / L=cordilheiras rust / S=platô ochre / O=manchas verdes / NE=badlands industriais. |

**Por que v6 venceu:** ângulo/feel batem com a dawn-v1 (não-orbital), biomas legíveis
e posicionados na direção certa, casando com os nós do mapa (zona de água no gelo ao N,
metais nas montanhas a L, etc.). Carregada em `app/lib/features/world_map/game/fertways_world_game.dart`
via `loadSprite('mars-solar-frontier-map-v6.png')`.

---

## Assets em uso hoje (runtime, em `app/assets/images/`)

| Arquivo | Uso |
|---|---|
| `mars-solar-frontier-map-v6.png` | Terreno do mapa-planeta (Flame `SpriteComponent`) |
| `capital-v1.png` | Sprite herói da sua colônia (nó central do mapa) |
| `avatar-vale-v1.png` | Avatar do jogador (HUD) |
| `crest-v1.png` | Brasão (HUD) |
| `plot-{water,metals,biomass,energy,factory}-v1.png` | Sprites de lote de recurso (reservados p/ o nível Colônia — roadmap B0) |

> Geração de arte: IA externa (prompts versionados em `docs/image-generation.md`).
> A IA entrega no máx. ~1536×1024; upscale 2× (Lanczos) melhora o zoom mas não
> substitui arte nativa 4K (p/ 4K real: Midjourney/Flux em alta ou tile painting).
