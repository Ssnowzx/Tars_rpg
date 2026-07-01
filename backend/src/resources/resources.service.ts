import { BadRequestException, Injectable } from '@nestjs/common';
import { Prisma, ResourceKey } from '@prisma/client';
import { productionRecipe } from '../common/production';
import { resourceTier } from '../common/resource-tier';
import { PrismaService } from '../prisma/prisma.service';

interface AccrualStock {
  id: string;
  key: ResourceKey;
  amount: number;
  capacity: number | null;
  perHour: number;
}

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

  /// Acúmulo de produção "compute-on-read" (§19/§24.5): cada recurso ganha
  /// `perHour × horas decorridas` desde a última marca, limitado à capacidade
  /// (o excedente com estoque cheio é perdido, como num jogo idle). Duas fases:
  /// (1) primários/brutos acumulam direto; (2) secundários com **receita**
  /// (ex.: Biocombustível = 2 Biomassa + 3 Energia) consomem insumos, limitados
  /// pela disponibilidade. Ignora leituras < 1 min (não reprocessa após ações).
  private async accrueProduction(
    playerId: string,
    producedAt: Date,
    stocks: AccrualStock[],
  ): Promise<void> {
    const now = Date.now();
    const elapsedMs = now - producedAt.getTime();
    if (elapsedMs < 60_000) return;
    const elapsedHours = elapsedMs / 3_600_000;

    const byKey = new Map(stocks.map((s) => [s.key, s]));
    const changed = new Set<string>();

    // Fase 1 — recursos sem receita acumulam direto.
    for (const s of stocks) {
      if (s.perHour <= 0 || productionRecipe(s.key)) continue;
      const gain = Math.floor(s.perHour * elapsedHours);
      if (gain <= 0) continue;
      const cap = s.capacity ?? Number.MAX_SAFE_INTEGER;
      const next = Math.min(cap, s.amount + gain);
      if (next !== s.amount) {
        s.amount = next;
        changed.add(s.id);
      }
    }

    // Fase 2 — secundários com receita consomem insumos (limite = disponibilidade).
    for (const s of stocks) {
      if (s.perHour <= 0) continue;
      const recipe = productionRecipe(s.key);
      if (!recipe) continue;
      const cap = s.capacity ?? Number.MAX_SAFE_INTEGER;
      let gain = Math.min(Math.floor(s.perHour * elapsedHours), cap - s.amount);
      for (const [inKey, perUnit] of Object.entries(recipe)) {
        const input = byKey.get(inKey as ResourceKey);
        gain = Math.min(gain, Math.floor((input?.amount ?? 0) / (perUnit ?? 1)));
      }
      if (gain <= 0) continue;
      for (const [inKey, perUnit] of Object.entries(recipe)) {
        const input = byKey.get(inKey as ResourceKey);
        if (input) {
          input.amount -= gain * (perUnit ?? 0);
          changed.add(input.id);
        }
      }
      s.amount += gain;
      changed.add(s.id);
    }

    // Persiste o que mudou e avança o relógio sempre que houve tempo real
    // decorrido (>= 1 min) — vender um recurso cheio não recarrega o passado.
    const updates: Prisma.PrismaPromise<unknown>[] = stocks
      .filter((s) => changed.has(s.id))
      .map((s) => this.prisma.resourceStock.update({ where: { id: s.id }, data: { amount: s.amount } }));
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
