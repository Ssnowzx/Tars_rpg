import { readFileSync } from 'node:fs';
import { resolve } from 'node:path';
import {
  MissionCategory,
  MoonAtmosphere,
  Prisma,
  PrismaClient,
  ResourceKey,
  RouteRisk,
} from '@prisma/client';
import * as bcrypt from 'bcryptjs';
import { backendKind, backendStatus } from '../src/common/fleet-catalog';
import { STARTER_BUILDINGS, STARTER_STOCKS } from '../src/common/starter-data';

const prisma = new PrismaClient();

/// Conteúdo de referência do jogo (config canônica) servido do banco via
/// /config/:key. Lê os JSONs de referência e guarda em ServerConfig, para o
/// frontend consumir do servidor (fim dos mocks client-side).
const FIXTURES_DIR = resolve(process.cwd(), '../app/assets/fixtures');
const CONFIG_FIXTURES: { key: string; file: string }[] = [
  { key: 'market', file: 'market.json' },
  { key: 'informal', file: 'informal.json' },
  { key: 'auctions', file: 'auctions.json' },
  { key: 'missionsBoard', file: 'missions.json' },
  { key: 'fleet', file: 'fleet.json' },
  { key: 'federation', file: 'federation.json' },
  { key: 'disputes', file: 'disputes.json' },
  { key: 'rankings', file: 'rankings.json' },
  { key: 'offices', file: 'offices.json' },
  { key: 'chat', file: 'chat.json' },
  { key: 'capital', file: 'capital.json' },
  { key: 'ministries', file: 'ministries.json' },
  { key: 'planet', file: 'planet.json' },
  { key: 'combat', file: 'combat.json' },
];

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

interface ReputationSeed {
  commercialTrust: number;
  socialConduct: number;
  civicStatus: number;
  militaryHonor: number;
}

/// Garante um jogador com colônia, construções essenciais, estoques e reputação.
/// Idempotente: preserva a senha existente e só cria o que faltar.
async function ensurePlayer(opts: {
  email: string;
  nickname: string;
  passwordHash: string;
  sector: string;
  level: number;
  xp: number;
  fertBalance: number;
  reputation: ReputationSeed;
  fleetSlots?: number;
}): Promise<string> {
  const player = await prisma.player.upsert({
    where: { email: opts.email },
    update: { level: opts.level, xp: opts.xp, fertBalance: opts.fertBalance },
    create: {
      email: opts.email,
      nickname: opts.nickname,
      passwordHash: opts.passwordHash,
      level: opts.level,
      xp: opts.xp,
      fertBalance: opts.fertBalance,
    },
  });
  const colony = await prisma.colony.upsert({
    where: { playerId: player.id },
    update: { sector: opts.sector, fleetSlots: opts.fleetSlots ?? 4 },
    create: {
      playerId: player.id,
      name: `Colônia ${opts.nickname}`,
      sector: opts.sector,
      fleetSlots: opts.fleetSlots ?? 4,
    },
  });
  if ((await prisma.building.count({ where: { colonyId: colony.id } })) === 0) {
    await prisma.building.createMany({
      data: STARTER_BUILDINGS.map((b) => ({ ...b, colonyId: colony.id })),
    });
  }
  if ((await prisma.resourceStock.count({ where: { playerId: player.id } })) === 0) {
    await prisma.resourceStock.createMany({
      data: STARTER_STOCKS.map((s) => ({ ...s, playerId: player.id })),
    });
  }
  await prisma.reputation.upsert({
    where: { playerId: player.id },
    update: opts.reputation,
    create: { playerId: player.id, ...opts.reputation },
  });
  return player.id;
}

interface FleetFixtureVehicle {
  plate: string;
  kind: string;
  capacityM3?: number;
  condition?: number;
  activeHours?: number;
  status: string;
  assignment?: string;
  maintenanceCost?: number;
  buildDay?: string;
}

/// Cria a frota de demonstração de um jogador a partir do fixture (idempotente).
async function seedVehicles(ownerId: string, file: string): Promise<void> {
  if ((await prisma.vehicle.count({ where: { ownerId } })) > 0) return;
  const data = JSON.parse(readFileSync(resolve(FIXTURES_DIR, file), 'utf8')) as {
    vehicles: FleetFixtureVehicle[];
  };
  for (const v of data.vehicles) {
    await prisma.vehicle.create({
      data: {
        ownerId,
        kind: backendKind(v.kind),
        status: backendStatus(v.status),
        plate: v.plate,
        integrity: (v.condition ?? 100) / 100,
        kindLabel: v.kind,
        statusLabel: v.status,
        capacityM3: v.capacityM3 ?? 0,
        condition: v.condition ?? 100,
        activeHours: v.activeHours ?? 0,
        maintenanceCost: v.maintenanceCost ?? 0,
        assignment: v.assignment ?? '',
        buildDayLabel: v.buildDay ?? '',
      },
    });
  }
}

/// Vendedores NPC + anúncios abertos no Mercado Central, para o board ter ordens
/// reais compráveis (§13). Idempotente: só semeia se não houver anúncios abertos.
async function seedMarketNpcs(passwordHash: string): Promise<void> {
  const npcs: {
    email: string;
    nickname: string;
    sector: string;
    trust: number;
    listings: { key: ResourceKey; quantity: number; unitPrice: number }[];
  }[] = [
    { email: 'renata@fertways.test', nickname: 'Renata Sol', sector: 'E-09', trust: 780, listings: [
      { key: 'water', quantity: 600, unitPrice: 0.0064 },
      { key: 'biomass', quantity: 900, unitPrice: 0.0088 },
    ] },
    { email: 'adeyemi@fertways.test', nickname: 'K. Adeyemi', sector: 'C-05', trust: 850, listings: [
      { key: 'alloys', quantity: 320, unitPrice: 0.0131 },
      { key: 'metalore', quantity: 450, unitPrice: 0.19 },
    ] },
    { email: 'tanaka@fertways.test', nickname: 'L. Tanaka', sector: 'B-03', trust: 900, listings: [
      { key: 'energy', quantity: 1200, unitPrice: 0.0035 },
      { key: 'oxygen', quantity: 700, unitPrice: 0.0052 },
    ] },
    { email: 'drax@fertways.test', nickname: 'Drax', sector: 'H-12', trust: 640, listings: [
      { key: 'chemicals', quantity: 240, unitPrice: 0.0173 },
      { key: 'componentBasic', quantity: 40, unitPrice: 1.31 },
    ] },
  ];
  for (const npc of npcs) {
    const id = await ensurePlayer({
      email: npc.email,
      nickname: npc.nickname,
      passwordHash,
      sector: npc.sector,
      level: 20,
      xp: 20000,
      fertBalance: 10000,
      reputation: { commercialTrust: npc.trust, socialConduct: 600, civicStatus: 600, militaryHonor: 500 },
    });
    if ((await prisma.marketListing.count({ where: { sellerId: id, status: 'open' } })) > 0) continue;
    for (const l of npc.listings) {
      await prisma.marketListing.create({
        data: {
          sellerId: id,
          key: l.key,
          quantity: l.quantity,
          unitPrice: new Prisma.Decimal(l.unitPrice),
          status: 'open',
        },
      });
    }
  }
}

/// Conteúdo de demonstração por jogador (§ pendência: dados por jogador): frota,
/// missões e federação de Cmdt. Vale + vendedores NPC do Mercado.
async function seedDemo(): Promise<void> {
  const passwordHash = await bcrypt.hash('colonia123', 10);

  const fedContent = JSON.parse(readFileSync(resolve(FIXTURES_DIR, 'federation.json'), 'utf8')) as {
    name: string;
    tag: string;
    fundBalance: number;
  };
  const federation = await prisma.federation.upsert({
    where: { name: fedContent.name },
    update: { tag: fedContent.tag, treasury: new Prisma.Decimal(fedContent.fundBalance) },
    create: { name: fedContent.name, tag: fedContent.tag, treasury: new Prisma.Decimal(fedContent.fundBalance) },
  });

  const valeId = await ensurePlayer({
    email: 'vale@fertways.test',
    nickname: 'CmdtVale',
    passwordHash,
    sector: 'F-07',
    level: 14,
    xp: 8420,
    fertBalance: 62000,
    reputation: { commercialTrust: 812, socialConduct: 690, civicStatus: 745, militaryHonor: 430 },
    fleetSlots: 12,
  });

  const missionContent = JSON.parse(readFileSync(resolve(FIXTURES_DIR, 'missions.json'), 'utf8')) as object;
  await prisma.player.update({
    where: { id: valeId },
    data: { missionState: missionContent as Prisma.InputJsonValue },
  });

  await prisma.federationMember.upsert({
    where: { playerId: valeId },
    update: { federationId: federation.id, role: 'member' },
    create: { playerId: valeId, federationId: federation.id, role: 'member' },
  });

  await seedVehicles(valeId, 'fleet.json');
  await seedMarketNpcs(passwordHash);
}

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
  const gagarin = {
    active: true,
    playersRegistered: 37,
    playersTrigger: 50,
    daysElapsed: 31,
    daysTrigger: 45,
    orbitWindowActive: true,
    bulletinFrequency: 'a cada 2–4 dias',
    channel: 'Central de Pesquisas e Notícias',
  };
  await prisma.serverConfig.upsert({
    where: { key: 'gagarin' },
    update: { value: gagarin },
    create: { key: 'gagarin', value: gagarin },
  });

  // Config de referência (lê os JSONs canônicos → ServerConfig).
  for (const { key, file } of CONFIG_FIXTURES) {
    const raw = readFileSync(resolve(FIXTURES_DIR, file), 'utf8');
    const value = JSON.parse(raw) as unknown;
    await prisma.serverConfig.upsert({
      where: { key },
      update: { value: value as object },
      create: { key, value: value as object },
    });
  }

  // Conteúdo de demonstração por jogador (frota/missões/federação + NPCs).
  await seedDemo();

  console.log(`Seed concluído: preços, luas, boletins, planetas, terraformação, missões, +${CONFIG_FIXTURES.length} configs de referência + demo por jogador.`);
}

main()
  .then(() => prisma.$disconnect())
  .catch((e: unknown) => {
    console.error(e);
    return prisma.$disconnect().finally(() => process.exit(1));
  });
