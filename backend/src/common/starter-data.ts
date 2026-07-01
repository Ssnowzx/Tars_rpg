import type { BuildingCategory, ResourceKey, ResourceTier } from '@prisma/client';

/// Estoques iniciais do colono (§18/§onboarding). Cria produção mínima.
export const STARTER_STOCKS: {
  key: ResourceKey;
  tier: ResourceTier;
  amount: number;
  capacity: number;
  perHour: number;
}[] = [
  { key: 'oxygen', tier: 'primary', amount: 6420, capacity: 9000, perHour: 54 },
  { key: 'water', tier: 'primary', amount: 7820, capacity: 12000, perHour: 88 },
  { key: 'biomass', tier: 'primary', amount: 4880, capacity: 7500, perHour: 22 },
  { key: 'energy', tier: 'primary', amount: 5000, capacity: 8000, perHour: 40 },
  { key: 'metalore', tier: 'industrial', amount: 1200, capacity: 5000, perHour: 15 },
  { key: 'alloys', tier: 'industrial', amount: 800, capacity: 4000, perHour: 8 },
  { key: 'chemicals', tier: 'industrial', amount: 400, capacity: 3000, perHour: 6 },
  { key: 'biofuel', tier: 'industrial', amount: 200, capacity: 2000, perHour: 4 },
];

/// Construções iniciais do slot (§17.1 essenciais + Oficina) e 2 slots livres.
export const STARTER_BUILDINGS: {
  kind: string;
  name: string;
  category: BuildingCategory;
  level: number;
  perHour: number;
  dx: number;
  dy: number;
  built: boolean;
}[] = [
  { kind: 'habitat', name: 'Estrutura de Sobrevivência', category: 'habitat', level: 1, perHour: 0, dx: 0, dy: 0, built: true },
  { kind: 'atmosphere', name: 'Gerador de Atmosfera', category: 'oxygen', level: 3, perHour: 54, dx: -160, dy: -110, built: true },
  { kind: 'water', name: 'Captação de Água', category: 'water', level: 3, perHour: 88, dx: 150, dy: -120, built: true },
  { kind: 'farm', name: 'Fazenda', category: 'biomass', level: 4, perHour: 202, dx: 190, dy: 130, built: true },
  { kind: 'reactor', name: 'Reator de Energia', category: 'energy', level: 3, perHour: 40, dx: -170, dy: 120, built: true },
  { kind: 'workshop', name: 'Oficina', category: 'components', level: 1, perHour: 0, dx: 40, dy: -190, built: true },
  { kind: 'empty', name: 'Slot livre', category: 'empty', level: 0, perHour: 0, dx: -60, dy: 200, built: false },
  { kind: 'empty', name: 'Slot livre', category: 'empty', level: 0, perHour: 0, dx: 120, dy: 210, built: false },
];
