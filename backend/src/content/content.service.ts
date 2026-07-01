import { Injectable } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';

/// Leitura de dados de referência semeados (§3/§4/§12): luas, indicadores de
/// terraformação, planetas NPC e catálogo de missões.
@Injectable()
export class ContentService {
  constructor(private readonly prisma: PrismaService) {}

  async getLunar() {
    const [moons, bulletins, config] = await Promise.all([
      this.prisma.moon.findMany({ orderBy: { key: 'asc' } }),
      this.prisma.gagarinBulletin.findMany({ orderBy: { publishedAt: 'desc' }, take: 10 }),
      this.prisma.serverConfig.findUnique({ where: { key: 'gagarin' } }),
    ]);
    return { gagarin: config?.value ?? null, moons, bulletins };
  }

  getTerraform() {
    return this.prisma.terraformIndicator.findMany();
  }

  getSpaceport() {
    return this.prisma.npcPlanet.findMany({ orderBy: { key: 'asc' } });
  }

  getMissions() {
    return this.prisma.mission.findMany({ orderBy: { key: 'asc' } });
  }
}
