import {
  MissionCategory,
  MoonAtmosphere,
  PrismaClient,
  ResourceKey,
  RouteRisk,
} from '@prisma/client';

const prisma = new PrismaClient();

/// Preços-base do Mercado Central (§22).
const PRICES: Record<ResourceKey, number> = {
  oxygen: 0.005,
  energy: 0.0033,
  water: 0.0062,
  biomass: 0.0083,
  metalore: 0.183,
  alloys: 0.0125,
  chemicals: 0.0166,
  biofuel: 0.0345,
  aluminum: 0.0253,
  tin: 0.0316,
  copper: 0.0316,
  silicon: 0.0361,
  lithium: 0.0506,
  tungsten: 0.0562,
  tantalum: 0.1012,
  gold: 0.1265,
  componentBasic: 1.2778,
  componentIntermediate: 1.5473,
  componentAdvanced: 2.0877,
  niobium: 0.3163,
  helium3: 0.3163,
  quartz: 0.3163,
  redIron: 0.2108,
  organicResin: 0.3163,
  methaneIce: 0.253,
  fossilPlasma: 0.4217,
  bioFungus: 0.253,
};

const MOONS: {
  key: string;
  name: string;
  honoree: string;
  honoreeNote: string;
  atmosphere: MoonAtmosphere;
  rareResource: ResourceKey;
  profile: string;
  t2Reading: string;
  mystery?: boolean;
}[] = [
  { key: 'armstrong', name: 'Armstrong', honoree: 'Neil Armstrong', honoreeNote: '1930–2012 · Primeiro homem na Lua', atmosphere: 'similar', rareResource: 'niobium', profile: 'Atmosfera similar a Fertways. Potencial de colonização com terraformação.', t2Reading: 'Colonização e estruturas avançadas.' },
  { key: 'tereshkova', name: 'Tereshkova', honoree: 'Valentina Tereshkova', honoreeNote: 'n. 1937 · Primeira mulher no espaço', atmosphere: 'none', rareResource: 'helium3', profile: 'Sem atmosfera. Mineração com estruturas herméticas.', t2Reading: 'Energia e mineração hermética.' },
  { key: 'sagan', name: 'Sagan', honoree: 'Carl Sagan', honoreeNote: '1934–1996 · "Pálido Ponto Azul"', atmosphere: 'toxic', rareResource: 'quartz', profile: 'Atmosfera tóxica. Recursos raros de superfície.', t2Reading: 'Anomalias de superfície e pesquisa.' },
  { key: 'aldrin', name: 'Aldrin', honoree: 'Buzz Aldrin', honoreeNote: 'n. 1930 · Segundo homem na Lua', atmosphere: 'none', rareResource: 'redIron', profile: 'Sem atmosfera. Mineração pesada — Ferro Vermelho.', t2Reading: 'Construção pesada.' },
  { key: 'ride', name: 'Ride', honoree: 'Sally Ride', honoreeNote: '1951–2012 · Primeira americana no espaço', atmosphere: 'similar', rareResource: 'organicResin', profile: 'Atmosfera similar. Melhor candidata à colonização.', t2Reading: 'Biosfera e habitação.' },
  { key: 'leonov', name: 'Leonov', honoree: 'Alexei Leonov', honoreeNote: '1934–2019 · Primeira caminhada espacial', atmosphere: 'toxic', rareResource: 'methaneIce', profile: 'Atmosfera tóxica. Gelo de Metano abundante.', t2Reading: 'Propulsão e logística.' },
  { key: 'hawking', name: 'Hawking', honoree: 'Stephen Hawking', honoreeNote: '1942–2018 · Física teórica e cosmologia', atmosphere: 'none', rareResource: 'fossilPlasma', profile: 'Sem atmosfera. Plasma Fossilizado — lua mais disputada.', t2Reading: 'Pesquisa de alto risco.' },
  { key: 'laika', name: 'Laika', honoree: 'Laika', honoreeNote: '1954–1957 · Primeira terráquea em órbita', atmosphere: 'toxic', rareResource: 'bioFungus', profile: 'Atmosfera tóxica. Anomalia detectada pelo Gagarin.', t2Reading: 'Anomalia de origem desconhecida; mistério narrativo.', mystery: true },
];

const PLANETS: { key: string; name: string; distance: string; risk: RouteRisk; exports: string; imports: string }[] = [
  { key: 'kalidor', name: 'Kalidor', distance: '~4h', risk: 'none', exports: 'Metais pesados, compostos químicos', imports: 'Biomassa, água' },
  { key: 'veyra', name: 'Veyra', distance: '~6,5h', risk: 'none', exports: 'Sementes alienígenas, compostos orgânicos', imports: 'Energia, componentes' },
  { key: 'auryn', name: 'Auryn', distance: '~12h', risk: 'low', exports: 'Variedade enorme', imports: 'Qualquer recurso' },
  { key: 'solene', name: 'Solène', distance: '~18h', risk: 'none', exports: 'Tecnologia, dados de pesquisa', imports: 'Recursos raros' },
  { key: 'drakmoor', name: 'Drakmoor', distance: '~31h', risk: 'high', exports: 'Minerais raros exclusivos', imports: 'Biomassa, água, componentes' },
];

const MISSIONS: { key: string; title: string; description: string; category: MissionCategory; rewardFert: number; rewardXp: number }[] = [
  { key: 'tutorial-first-build', title: 'Primeira construção', description: 'Construa sua primeira estrutura de produção.', category: 'tutorial', rewardFert: 20, rewardXp: 50 },
  { key: 'tutorial-first-trade', title: 'Primeiro comércio', description: 'Venda um lote no Mercado Central.', category: 'production', rewardFert: 30, rewardXp: 80 },
  { key: 'civic-terraform', title: 'Contribuir à terraformação', description: 'Faça sua primeira contribuição à terraformação global.', category: 'civic', rewardFert: 0, rewardXp: 60 },
];

async function main(): Promise<void> {
  // Preços-base (§22)
  for (const [key, basePrice] of Object.entries(PRICES)) {
    await prisma.marketPrice.upsert({
      where: { key: key as ResourceKey },
      update: { basePrice },
      create: { key: key as ResourceKey, basePrice },
    });
  }

  // Luas (§12) + boletins do Gagarin
  const moonIdByKey = new Map<string, string>();
  for (const m of MOONS) {
    const moon = await prisma.moon.upsert({
      where: { key: m.key },
      update: { ...m, mystery: m.mystery ?? false },
      create: { ...m, mystery: m.mystery ?? false },
    });
    moonIdByKey.set(m.key, moon.id);
  }

  const bulletinCount = await prisma.gagarinBulletin.count();
  if (bulletinCount === 0) {
    await prisma.gagarinBulletin.createMany({
      data: [
        { cycle: 'Ciclo 14', kind: 'resource', moonId: moonIdByKey.get('hawking') ?? null, title: 'Plasma Fossilizado confirmado em Hawking', body: 'Camadas densas detectadas — compatível com bases de alto risco da T2.' },
        { cycle: 'Ciclo 13', kind: 'anomaly', moonId: moonIdByKey.get('laika') ?? null, title: 'Sinal de origem desconhecida em Laika', body: 'Padrão sem assinatura conhecida. Classificado como anomalia prioritária.' },
        { cycle: 'Ciclo 12', kind: 'atmosphere', moonId: moonIdByKey.get('ride') ?? null, title: 'Atmosfera de Ride estável', body: 'Composição similar a Fertways mantida — melhor candidata à colonização.' },
      ],
    });
  }

  // Planetas NPC (§3)
  for (const p of PLANETS) {
    await prisma.npcPlanet.upsert({ where: { key: p.key }, update: p, create: p });
  }

  // Indicadores de terraformação (§04)
  const indicators: { kind: 'atmosphere' | 'water' | 'biosphere'; percent: number; perDay: number }[] = [
    { kind: 'atmosphere', percent: 58, perDay: 1 },
    { kind: 'water', percent: 41, perDay: 1 },
    { kind: 'biosphere', percent: 66, perDay: 2 },
  ];
  for (const i of indicators) {
    await prisma.terraformIndicator.upsert({
      where: { kind: i.kind },
      update: { percent: i.percent, perDay: i.perDay },
      create: i,
    });
  }

  // Missões (§6)
  for (const m of MISSIONS) {
    await prisma.mission.upsert({ where: { key: m.key }, update: m, create: m });
  }

  // Estado do Telescópio Gagarin (§12.1)
  await prisma.serverConfig.upsert({
    where: { key: 'gagarin' },
    update: {},
    create: {
      key: 'gagarin',
      value: {
        active: true,
        playersTrigger: 50,
        daysTrigger: 45,
        bulletinFrequency: 'a cada 2–4 dias',
        channel: 'Central de Pesquisas e Notícias',
      },
    },
  });

  console.log('Seed concluído: preços, luas, boletins, planetas, terraformação, missões.');
}

main()
  .then(() => prisma.$disconnect())
  .catch((e: unknown) => {
    console.error(e);
    return prisma.$disconnect().finally(() => process.exit(1));
  });
