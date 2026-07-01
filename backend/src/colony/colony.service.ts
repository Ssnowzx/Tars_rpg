import { Injectable } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';

@Injectable()
export class ColonyService {
  constructor(private readonly prisma: PrismaService) {}

  async getColony(playerId: string) {
    const colony = await this.prisma.colony.findUniqueOrThrow({
      where: { playerId },
      include: { buildings: { orderBy: { createdAt: 'asc' } } },
    });
    return {
      id: colony.id,
      name: colony.name,
      sector: colony.sector,
      specialization: colony.specialization,
      builtCount: colony.buildings.filter((b) => b.built).length,
      freeCount: colony.buildings.filter((b) => !b.built).length,
      buildings: colony.buildings.map((b) => ({
        id: b.id,
        kind: b.kind,
        name: b.name,
        category: b.category,
        level: b.level,
        perHour: b.perHour,
        dx: b.dx,
        dy: b.dy,
        built: b.built,
      })),
    };
  }
}
