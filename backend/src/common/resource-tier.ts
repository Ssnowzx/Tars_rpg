import { ResourceKey, ResourceTier } from '@prisma/client';

const PRIMARY: ResourceKey[] = [ResourceKey.oxygen, ResourceKey.water, ResourceKey.biomass, ResourceKey.energy];
const INDUSTRIAL: ResourceKey[] = [ResourceKey.metalore, ResourceKey.alloys, ResourceKey.chemicals, ResourceKey.biofuel];
const MINERAL: ResourceKey[] = [
  ResourceKey.aluminum, ResourceKey.tin, ResourceKey.copper, ResourceKey.silicon,
  ResourceKey.lithium, ResourceKey.tungsten, ResourceKey.tantalum, ResourceKey.gold,
];
const COMPONENT: ResourceKey[] = [ResourceKey.componentBasic, ResourceKey.componentIntermediate, ResourceKey.componentAdvanced];

/// Classe de um recurso (§18) — usada ao criar estoques sob demanda.
export function resourceTier(key: ResourceKey): ResourceTier {
  if (PRIMARY.includes(key)) return ResourceTier.primary;
  if (INDUSTRIAL.includes(key)) return ResourceTier.industrial;
  if (MINERAL.includes(key)) return ResourceTier.mineral;
  if (COMPONENT.includes(key)) return ResourceTier.component;
  return ResourceTier.rare;
}
