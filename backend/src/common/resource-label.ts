import { ResourceKey } from '@prisma/client';

/// Rótulo pt-BR canônico de cada recurso (§18/§22). É o texto exibido no cliente
/// (o frontend consome `resourceLabel` direto do backend nos boards de mercado).
const LABELS: Record<ResourceKey, string> = {
  oxygen: 'Oxigênio',
  water: 'Água',
  biomass: 'Biomassa',
  energy: 'Energia',
  metalore: 'Metal Bruto',
  alloys: 'Ligas Metálicas',
  chemicals: 'Compostos Químicos',
  biofuel: 'Biocombustível',
  aluminum: 'Alumínio',
  tin: 'Estanho',
  copper: 'Cobre',
  silicon: 'Silício',
  lithium: 'Lítio',
  tungsten: 'Tungstênio',
  tantalum: 'Tântalo',
  gold: 'Ouro',
  componentBasic: 'Componente Básico',
  componentIntermediate: 'Componente Intermediário',
  componentAdvanced: 'Componente Avançado',
  niobium: 'Nióbio Alienígena',
  helium3: 'Cristal de Hélio-3',
  quartz: 'Quartzo Piezoelétrico',
  redIron: 'Ferro Vermelho',
  organicResin: 'Resina Orgânica',
  methaneIce: 'Gelo de Metano',
  fossilPlasma: 'Plasma Fossilizado',
  bioFungus: 'Fungo Bioluminescente',
};

export function resourceLabel(key: ResourceKey): string {
  return LABELS[key] ?? key;
}
