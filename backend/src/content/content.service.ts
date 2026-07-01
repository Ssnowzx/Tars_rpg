import { Injectable } from '@nestjs/common';
import { ResourceKey } from '@prisma/client';
import { PrismaService } from '../prisma/prisma.service';

const MOON_ORDER = ['armstrong', 'tereshkova', 'sagan', 'aldrin', 'ride', 'leonov', 'hawking', 'laika'];

const TERRAFORM_TRIGGER = 75;

function rareLabel(key: ResourceKey): string {
  const map: Partial<Record<ResourceKey, string>> = {
    niobium: 'Nióbio Alienígena',
    helium3: 'Cristal de Hélio-3',
    quartz: 'Quartzo Piezoelétrico',
    redIron: 'Ferro Vermelho',
    organicResin: 'Resina Orgânica',
    methaneIce: 'Gelo de Metano',
    fossilPlasma: 'Plasma Fossilizado',
    bioFungus: 'Fungo Bioluminescente',
  };
  return map[key] ?? key;
}

function relTime(date: Date): string {
  const diffMs = Date.now() - date.getTime();
  const min = Math.floor(diffMs / 60000);
  if (min < 1) return 'agora';
  if (min < 60) return `há ${min}min`;
  const h = Math.floor(min / 60);
  if (h < 24) return `há ${h}h`;
  return `há ${Math.floor(h / 24)}d`;
}

const INDICATOR_LABELS: Record<string, { label: string; note: string }> = {
  atmosphere: {
    label: 'Atmosfera',
    note: 'Pressão e composição respirável do ar. Alimentada por Geradores de Atmosfera e biomassa.',
  },
  water: {
    label: 'Ciclo Hídrico',
    note: 'Água líquida estável em superfície. O indicador mais atrasado — determina o gatilho da T2.',
  },
  biosphere: {
    label: 'Biosfera',
    note: 'Cobertura viva e solo fértil. Avança com fazendas, estufas e projetos de biomassa.',
  },
};

/// Leitura de dados de referência semeados (§3/§4/§12) no formato que o
/// frontend consome direto (Model.fromJson).
@Injectable()
export class ContentService {
  constructor(private readonly prisma: PrismaService) {}

  async getLunar() {
    const [moons, bulletins, config, indicators] = await Promise.all([
      this.prisma.moon.findMany(),
      this.prisma.gagarinBulletin.findMany({ orderBy: { publishedAt: 'desc' }, take: 10 }),
      this.prisma.serverConfig.findUnique({ where: { key: 'gagarin' } }),
      this.prisma.terraformIndicator.findMany(),
    ]);
    const cfg = (config?.value ?? {}) as Record<string, unknown>;
    const byKey = new Map(moons.map((m) => [m.key, m]));
    const lowest = indicators.length ? Math.min(...indicators.map((i) => i.percent)) : 0;
    return {
      gagarinActive: (cfg.active as boolean) ?? true,
      playersRegistered: (cfg.playersRegistered as number) ?? 0,
      playersTrigger: (cfg.playersTrigger as number) ?? 50,
      daysElapsed: (cfg.daysElapsed as number) ?? 0,
      daysTrigger: (cfg.daysTrigger as number) ?? 45,
      bulletinFrequency: (cfg.bulletinFrequency as string) ?? 'a cada 2–4 dias',
      terraformPercent: lowest,
      terraformTrigger: TERRAFORM_TRIGGER,
      orbitWindowActive: (cfg.orbitWindowActive as boolean) ?? false,
      bulletins: bulletins.map((b) => ({
        id: b.id,
        cycle: b.cycle,
        kind: b.kind,
        title: b.title,
        body: b.body,
        moonId: b.moonId ?? '',
        time: relTime(b.publishedAt),
      })),
      moons: MOON_ORDER.map((k) => byKey.get(k))
        .filter((m): m is NonNullable<typeof m> => m != null)
        .map((m) => ({
          id: m.key,
          name: m.name,
          honoree: m.honoree,
          honoreeNote: m.honoreeNote,
          atmosphere: m.atmosphere,
          rareResourceId: m.rareResource,
          rareResource: rareLabel(m.rareResource),
          profile: m.profile,
          t2Reading: m.t2Reading,
          mystery: m.mystery,
        })),
    };
  }

  async getTerraform() {
    const [indicators, config] = await Promise.all([
      this.prisma.terraformIndicator.findMany(),
      this.prisma.serverConfig.findUnique({ where: { key: 'gagarin' } }),
    ]);
    const cfg = (config?.value ?? {}) as Record<string, unknown>;
    const order = ['atmosphere', 'water', 'biosphere'];
    const byKind = new Map(indicators.map((i) => [i.kind, i]));
    return {
      triggerPercent: TERRAFORM_TRIGGER,
      dailyContributed: 0,
      dailyCap: 50,
      totalContributed: 0,
      civicStatusGain: 2,
      contributorTopPct: 35,
      orbitWindowActive: (cfg.orbitWindowActive as boolean) ?? false,
      tracks: order
        .map((k) => byKind.get(k as never))
        .filter((i): i is NonNullable<typeof i> => i != null)
        .map((i) => ({
          kind: i.kind,
          label: INDICATOR_LABELS[i.kind]?.label ?? i.kind,
          percent: i.percent,
          perDay: i.perDay,
          note: INDICATOR_LABELS[i.kind]?.note ?? '',
        })),
    };
  }

  getSpaceport() {
    return this.prisma.npcPlanet.findMany({ orderBy: { key: 'asc' } });
  }

  getMissions() {
    return this.prisma.mission.findMany({ orderBy: { key: 'asc' } });
  }

  /// Config estático do servidor por chave (ex.: layout da Capital, painéis dos
  /// ministérios, mapa-planeta). É a config canônica do jogo servida do banco.
  async getConfig(key: string): Promise<unknown> {
    const row = await this.prisma.serverConfig.findUnique({ where: { key } });
    return row?.value ?? null;
  }
}
