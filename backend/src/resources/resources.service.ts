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
        select: { fertBalance: true, producedAt: true },
      }),
      this.prisma.resourceStock.findMany({ where: { playerId }, orderBy: { key: 'asc' } }),
    ]);
    await this.accrueProduction(playerId, player.producedAt, stocks);
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

  /// Acúmulo de produção "compute-on-read" (§19): cada recurso ganha
  /// `perHour × horas decorridas` desde a última marca, limitado à capacidade
  /// (o excedente com estoque cheio é perdido, como num jogo idle). Ignora
  /// leituras muito próximas (< 1 min) para não reprocessar após ações (ex.:
  /// uma compra que invalida os recursos) nem perder frações à toa.
  private async accrueProduction(
    playerId: string,
    producedAt: Date,
    stocks: { id: string; amount: number; capacity: number | null; perHour: number }[],
  ): Promise<void> {
    const now = Date.now();
    const elapsedMs = now - producedAt.getTime();
    if (elapsedMs < 60_000) return;
    const elapsedHours = elapsedMs / 3_600_000;

    const updates: Prisma.PrismaPromise<unknown>[] = [];
    for (const s of stocks) {
      if (s.perHour <= 0) continue;
      const gain = Math.floor(s.perHour * elapsedHours);
      if (gain <= 0) continue;
      const cap = s.capacity ?? Number.MAX_SAFE_INTEGER;
      const next = Math.min(cap, s.amount + gain);
      if (next !== s.amount) {
        updates.push(this.prisma.resourceStock.update({ where: { id: s.id }, data: { amount: next } }));
        s.amount = next; // reflete no payload retornado
      }
    }
    // Avança o relógio sempre que houve tempo real decorrido (>= 1 min), mesmo
    // que tudo estivesse no teto — assim vender um recurso cheio não recarrega
    // instantaneamente o período já "perdido".
    await this.prisma.$transaction([
      ...updates,
      this.prisma.player.update({ where: { id: playerId }, data: { producedAt: new Date(now) } }),
    ]);
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
