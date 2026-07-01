import { BadRequestException, Injectable } from '@nestjs/common';
import { Prisma, ResourceKey } from '@prisma/client';
import { resourceTier } from '../common/resource-tier';
import { PrismaService } from '../prisma/prisma.service';

@Injectable()
export class ResourcesService {
  constructor(private readonly prisma: PrismaService) {}

  async getState(playerId: string) {
    const [player, stocks] = await Promise.all([
      this.prisma.player.findUniqueOrThrow({
        where: { id: playerId },
        select: { fertBalance: true },
      }),
      this.prisma.resourceStock.findMany({ where: { playerId }, orderBy: { key: 'asc' } }),
    ]);
    return {
      fertCoins: player.fertBalance,
      stocks: stocks.map((s) => ({
        key: s.key,
        tier: s.tier,
        amount: s.amount,
        capacity: s.capacity,
        perHour: s.perHour,
      })),
    };
  }

  /// Ajusta o estoque de um recurso (delta pode ser negativo). Cria a linha se
  /// não existir. Nunca deixa negativo.
  async adjust(
    playerId: string,
    key: ResourceKey,
    delta: number,
    tx?: Prisma.TransactionClient,
  ): Promise<void> {
    const db = tx ?? this.prisma;
    const stock = await db.resourceStock.findUnique({
      where: { playerId_key: { playerId, key } },
    });
    if (!stock) {
      if (delta < 0) {
        throw new BadRequestException(`Recurso insuficiente: ${key}`);
      }
      await db.resourceStock.create({
        data: { playerId, key, tier: resourceTier(key), amount: delta },
      });
      return;
    }
    const next = stock.amount + delta;
    if (next < 0) {
      throw new BadRequestException(`Recurso insuficiente: ${key}`);
    }
    await db.resourceStock.update({ where: { id: stock.id }, data: { amount: next } });
  }
}
