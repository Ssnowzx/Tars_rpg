# Prateleira da Temporada 2 (código desativado, reaproveitável)

Arquivos **fora do build ativo** (não compilam no app de T1), guardados para reuso na
**Temporada 2**. Cada pasta documenta de onde veio e por que foi prateleirada.

---

## `colony-view/` — vista "Colônia com lotes de recurso" (B0, revertida em 30/06)

**Por que saiu:** foi construída assumindo o modelo Travian/Ikariam (anel de lotes de
recurso em volta da Capital). **Isso NÃO está no GDD de Fertways.** No GDD:
- A **colônia é um local único = a Capital**, cujos prédios são os **20 slots de
  instituição** (§2.1). Não há "lotes de recurso" (as palavras *lote/terreno/parcela/
  campo* não aparecem no GDD).
- Os **5 recursos vêm das ZONAS NEUTRAS** (ocupar com *Robô Minerador* → extrair →
  *Caminhão de Carga* leva aos 4 destinos), §7/§16 — não de prédios da colônia.
- "Slots de estrutura (silos/geradores) e slots de mineração" só existem nas
  **bases lunares da Temporada 2** (§12.4).

**Por que guardar:** a **base lunar de T2 É uma grade de slots** (estrutura + mineração) —
exatamente o padrão desta vista. Reaproveitar como ponto de partida da tela de base lunar.

**Como reativar (T2):** mover de volta para os caminhos originais e religar:
| Arquivo (shelf) | Caminho original |
|---|---|
| `colony_screen.dart` | `app/lib/features/colony/colony_screen.dart` |
| `colony_lot_panel.dart` | `app/lib/features/colony/colony_lot_panel.dart` |
| `colony_game.dart` | `app/lib/features/colony/game/colony_game.dart` |
| `colony_lots.dart` | `app/lib/domain/models/colony_lots.dart` |
| `colony.json` | `app/assets/fixtures/colony.json` |
| `colony-ground-dawn-v1.png` | `app/assets/images/` (backdrop; original tb em `docs/visual-history/maps/`) |
| `plot-{water,metals,biomass,energy,factory}-v1.png` | `app/assets/images/` (sprites de prédio; órfãos no modelo GDD de T1) |

Religar: rota em `router.dart`, `colonyLayoutProvider` em `data/providers.dart`,
`loadColonyLayout()` em `WorldRepository` + mock. (Para T2, adaptar nomes p/ "base lunar".)

**Atualização (GDD v21):** a vista de Colônia VOLTOU ao app de T1, porém **reescrita** com o
modelo correto da v21 §17 — Slot do colono com **construções** (Captação de Água, Oficina,
Fazenda, Reator, Refinaria, Quartel…) + especialização, NÃO "lotes de recurso". Arquivos
ativos novos: `app/lib/features/colony/*` + `domain/models/colony_buildings.dart`. Os
arquivos AQUI no shelf são a **versão antiga ("lotes")**, mantida só como referência
histórica / ponto de partida para as **bases lunares de T2** (slots de estrutura/mineração).
Modelo atual: Planeta → Colônia/Slot (construções) → Capital (governo, 20 slots). Recurso
extra das **zonas neutras**. Ver `docs/fertways-roadmap.md` e `FERTWAYS_GDD_v21.html`.
