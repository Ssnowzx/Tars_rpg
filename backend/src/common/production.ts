import { BuildingCategory, ResourceKey } from '@prisma/client';

/// Recurso produzido por cada categoria de construção (§17/§19). Categorias sem
/// produção (habitat, militar, pesquisa, transporte, etc.) retornam null.
const CATEGORY_RESOURCE: Partial<Record<BuildingCategory, ResourceKey>> = {
  oxygen: ResourceKey.oxygen,
  water: ResourceKey.water,
  biomass: ResourceKey.biomass,
  energy: ResourceKey.energy,
  rawmetal: ResourceKey.metalore,
  metals: ResourceKey.alloys,
  components: ResourceKey.componentBasic,
  biofuel: ResourceKey.biofuel,
};

export function buildingResource(category: BuildingCategory): ResourceKey | null {
  return CATEGORY_RESOURCE[category] ?? null;
}

/// Produção-base (perHour) de um prédio recém-construído (nível 1) por categoria.
const BASE_PER_HOUR: Partial<Record<BuildingCategory, number>> = {
  oxygen: 20,
  water: 25,
  biomass: 30,
  energy: 18,
  rawmetal: 12,
  metals: 8,
  components: 5,
  biofuel: 4,
};

export function baseProduction(category: BuildingCategory): number {
  return BASE_PER_HOUR[category] ?? 0;
}

/// Receitas de conversão (§24.5): recurso → insumos por unidade produzida.
/// Só o **Biocombustível** tem receita fixa definitiva no GDD (a Destilaria
/// converte 2 Biomassa + 3 Energia em 1 Biocombustível). As demais secundárias
/// dependem de minerais/planilha não auto-produzíveis na T1 — ficam de fora até
/// terem razão explícita (o GDD proíbe inventar números).
export const PRODUCTION_RECIPES: Partial<Record<ResourceKey, Partial<Record<ResourceKey, number>>>> = {
  [ResourceKey.biofuel]: { [ResourceKey.biomass]: 2, [ResourceKey.energy]: 3 },
};

export function productionRecipe(key: ResourceKey): Partial<Record<ResourceKey, number>> | null {
  return PRODUCTION_RECIPES[key] ?? null;
}

/// Novo perHour ao evoluir uma construção (§19 — curva 1.5× por nível).
export function nextProduction(current: number): number {
  return Math.round(current * 1.5);
}

/// Custo em recursos para construir/evoluir até `toLevel` (§20 — curva 1.5×).
/// Cobrado em Metal Bruto + Energia. Habitat/slots vazios não custam.
export function buildCost(
  category: BuildingCategory,
  toLevel: number,
): Partial<Record<ResourceKey, number>> {
  if (category === 'habitat' || category === 'empty') return {};
  const mult = Math.pow(1.5, Math.max(0, toLevel - 1));
  return {
    [ResourceKey.metalore]: Math.round(25 * mult),
    [ResourceKey.energy]: Math.round(12 * mult),
  };
}
