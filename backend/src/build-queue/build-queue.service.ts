import {
  BadRequestException,
  ForbiddenException,
  Injectable,
  NotFoundException,
} from '@nestjs/common';
import { BuildingCategory, BuildJob, BuildJobKind, Prisma, ResourceKey } from '@prisma/client';
import { baseProduction, buildCost, buildingResource, nextProduction } from '../common/production';
import { resourceTier } from '../common/resource-tier';
import { PrismaService } from '../prisma/prisma.service';
import { ResourcesService } from '../resources/resources.service';

const ONBOARDING_MS = 5 * 24 * 60 * 60 * 1000;

/// Tempo estimado de obra (§20), curva 1.5×, curto e demonstrável.
export function buildSeconds(toLevel: number): number {
  const base = 30;
  const n = Math.min(Math.max(toLevel - 1, 0), 8);
  return Math.min(Math.round(base * Math.pow(1.5, n)), 240);
}

interface CreateJobInput {
  name: string;
  kind: BuildJobKind;
  targetId: string;
  fromLevel: number;
  toLevel: number;
}

/// Fila de construção autoritativa (§17/§20). Espelha o C4 do frontend, mas
/// aqui é a fonte de verdade: as obras concluem no servidor (efeito no nível da
/// construção) por conclusão preguiçosa (ao ler/enfileirar) — cron pode ser
/// adicionado depois.
@Injectable()
export class BuildQueueService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly resources: ResourcesService,
  ) {}

  private async maxSlots(playerId: string): Promise<number> {
    const player = await this.prisma.player.findUniqueOrThrow({
      where: { id: playerId },
      select: { createdAt: true },
    });
    // Fila dupla nos primeiros 5 dias de conta (§20.2).
    return Date.now() - player.createdAt.getTime() < ONBOARDING_MS ? 2 : 1;
  }

  async completeExpired(playerId: string): Promise<void> {
    const due = await this.prisma.buildJob.findMany({
      where: { playerId, status: 'active', endsAt: { lte: new Date() } },
    });
    for (const job of due) {
      await this.applyCompletion(job);
    }
  }

  private async applyCompletion(job: BuildJob): Promise<void> {
    await this.prisma.$transaction(async (tx) => {
      if (job.targetKind === 'colonyBuilding' && job.targetId) {
        const building = await tx.building.findUnique({
          where: { id: job.targetId },
          include: { colony: { select: { playerId: true } } },
        });
        if (building) {
          // Evolução usa a curva 1.5× (§19); construção nova parte da base da
          // categoria. O perHour do prédio muda com o nível.
          const perHour =
            job.kind === 'upgrade' ? nextProduction(building.perHour) : baseProduction(building.category);
          await tx.building.update({
            where: { id: building.id },
            data:
              job.kind === 'upgrade'
                ? { level: { increment: 1 }, perHour }
                : { built: true, level: 1, perHour },
          });
          // Recalcula a produção por hora do recurso a partir de todos os
          // prédios daquela categoria (economia viva §19).
          await this.recomputeStockPerHour(tx, building.colony.playerId, building.colonyId, building.category);
        }
      }
      await tx.buildJob.update({ where: { id: job.id }, data: { status: 'done' } });
    });
  }

  /// Sincroniza `ResourceStock.perHour` com a soma da produção dos prédios
  /// construídos daquela categoria (o motor de acúmulo em /resources usa isso).
  private async recomputeStockPerHour(
    tx: Prisma.TransactionClient,
    playerId: string,
    colonyId: string,
    category: BuildingCategory,
  ): Promise<void> {
    const resource = buildingResource(category);
    if (!resource) return;
    const agg = await tx.building.aggregate({
      where: { colonyId, category, built: true },
      _sum: { perHour: true },
    });
    const perHour = agg._sum.perHour ?? 0;
    const stock = await tx.resourceStock.findUnique({
      where: { playerId_key: { playerId, key: resource } },
    });
    if (stock) {
      await tx.resourceStock.update({ where: { id: stock.id }, data: { perHour } });
    } else {
      await tx.resourceStock.create({
        data: { playerId, key: resource, tier: resourceTier(resource), amount: 0, perHour },
      });
    }
  }

  async list(playerId: string) {
    await this.completeExpired(playerId);
    const [jobs, maxSlots] = await Promise.all([
      this.prisma.buildJob.findMany({
        where: { playerId, status: 'active' },
        orderBy: { endsAt: 'asc' },
      }),
      this.maxSlots(playerId),
    ]);
    const now = Date.now();
    return {
      maxSlots,
      jobs: jobs.map((j) => ({
        id: j.id,
        name: j.name,
        kind: j.kind,
        fromLevel: j.fromLevel,
        toLevel: j.toLevel,
        totalSeconds: j.totalSeconds,
        remainingSeconds: Math.max(0, Math.ceil((j.endsAt.getTime() - now) / 1000)),
        endsAt: j.endsAt,
      })),
    };
  }

  private async assertCapacity(playerId: string): Promise<void> {
    await this.completeExpired(playerId);
    const [active, max] = await Promise.all([
      this.prisma.buildJob.count({ where: { playerId, status: 'active' } }),
      this.maxSlots(playerId),
    ]);
    if (active >= max) {
      throw new BadRequestException('Fila cheia — aguarde uma obra concluir');
    }
  }

  async enqueueUpgrade(playerId: string, buildingId: string) {
    const building = await this.prisma.building.findUnique({
      where: { id: buildingId },
      include: { colony: { select: { playerId: true } } },
    });
    if (!building) {
      throw new NotFoundException('Construção não encontrada');
    }
    if (building.colony.playerId !== playerId) {
      throw new ForbiddenException();
    }
    if (!building.built) {
      throw new BadRequestException('Construção ainda não existe');
    }
    await this.assertCapacity(playerId);
    const cost = buildCost(building.category, building.level + 1);
    return this.prisma.$transaction(async (tx) => {
      await this.deductCost(tx, playerId, cost);
      return this.createJob(tx, playerId, {
        name: building.name,
        kind: 'upgrade',
        targetId: buildingId,
        fromLevel: building.level,
        toLevel: building.level + 1,
      });
    });
  }

  async enqueueNew(
    playerId: string,
    dto: { kind: string; name: string; category: BuildingCategory },
  ) {
    const colony = await this.prisma.colony.findUniqueOrThrow({ where: { playerId } });
    const freeSlot = await this.prisma.building.findFirst({
      where: { colonyId: colony.id, built: false },
    });
    if (!freeSlot) {
      throw new BadRequestException('Sem slot livre disponível');
    }
    await this.assertCapacity(playerId);
    const cost = buildCost(dto.category, 1);
    return this.prisma.$transaction(async (tx) => {
      await this.deductCost(tx, playerId, cost);
      await tx.building.update({
        where: { id: freeSlot.id },
        data: { kind: dto.kind, name: dto.name, category: dto.category },
      });
      return this.createJob(tx, playerId, {
        name: dto.name,
        kind: 'construct',
        targetId: freeSlot.id,
        fromLevel: 0,
        toLevel: 1,
      });
    });
  }

  /// Debita o custo da obra (§20). Lança se faltar recurso (mensagem clara).
  private async deductCost(
    tx: Prisma.TransactionClient,
    playerId: string,
    cost: Partial<Record<ResourceKey, number>>,
  ): Promise<void> {
    for (const [key, amount] of Object.entries(cost)) {
      if (!amount) continue;
      await this.resources.adjust(playerId, key as ResourceKey, -amount, tx);
    }
  }

  private async createJob(tx: Prisma.TransactionClient, playerId: string, input: CreateJobInput) {
    const totalSeconds = buildSeconds(input.toLevel);
    return tx.buildJob.create({
      data: {
        playerId,
        name: input.name,
        targetKind: 'colonyBuilding',
        targetId: input.targetId,
        kind: input.kind,
        fromLevel: input.fromLevel,
        toLevel: input.toLevel,
        totalSeconds,
        endsAt: new Date(Date.now() + totalSeconds * 1000),
        status: 'active',
      },
    });
  }

  async cancel(playerId: string, jobId: string): Promise<{ ok: boolean }> {
    const job = await this.prisma.buildJob.findUnique({ where: { id: jobId } });
    if (!job || job.playerId !== playerId) {
      throw new NotFoundException('Obra não encontrada');
    }
    if (job.status !== 'active') {
      return { ok: true };
    }
    const building = job.targetId
      ? await this.prisma.building.findUnique({ where: { id: job.targetId } })
      : null;
    const refund = building ? buildCost(building.category, job.toLevel) : {};
    await this.prisma.$transaction(async (tx) => {
      await tx.buildJob.update({ where: { id: jobId }, data: { status: 'cancelled' } });
      // Devolve o custo debitado ao enfileirar.
      for (const [key, amount] of Object.entries(refund)) {
        if (amount) await this.resources.adjust(playerId, key as ResourceKey, amount, tx);
      }
      if (job.kind === 'construct' && job.targetId) {
        await tx.building.updateMany({
          where: { id: job.targetId, built: false },
          data: { kind: 'empty', name: 'Slot livre', category: 'empty' },
        });
      }
    });
    return { ok: true };
  }

  async complete(playerId: string, jobId: string): Promise<{ ok: boolean }> {
    const job = await this.prisma.buildJob.findUnique({ where: { id: jobId } });
    if (!job || job.playerId !== playerId) {
      throw new NotFoundException('Obra não encontrada');
    }
    if (job.status !== 'active') {
      throw new BadRequestException('Obra não está ativa');
    }
    await this.applyCompletion(job);
    return { ok: true };
  }
}
