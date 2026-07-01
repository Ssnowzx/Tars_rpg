import {
  BadRequestException,
  ForbiddenException,
  Injectable,
  NotFoundException,
} from '@nestjs/common';
import { BuildingCategory, BuildJob, BuildJobKind } from '@prisma/client';
import { PrismaService } from '../prisma/prisma.service';

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
  constructor(private readonly prisma: PrismaService) {}

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
        const targetId = job.targetId;
        if (job.kind === 'upgrade') {
          await tx.building.update({
            where: { id: targetId },
            data: { level: { increment: 1 } },
          });
        } else {
          await tx.building.update({
            where: { id: targetId },
            data: { built: true, level: 1 },
          });
        }
      }
      await tx.buildJob.update({ where: { id: job.id }, data: { status: 'done' } });
    });
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
    return this.create(playerId, {
      name: building.name,
      kind: 'upgrade',
      targetId: buildingId,
      fromLevel: building.level,
      toLevel: building.level + 1,
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
    await this.prisma.building.update({
      where: { id: freeSlot.id },
      data: { kind: dto.kind, name: dto.name, category: dto.category },
    });
    return this.create(playerId, {
      name: dto.name,
      kind: 'construct',
      targetId: freeSlot.id,
      fromLevel: 0,
      toLevel: 1,
    });
  }

  private async create(playerId: string, input: CreateJobInput) {
    const totalSeconds = buildSeconds(input.toLevel);
    return this.prisma.buildJob.create({
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
    await this.prisma.buildJob.update({ where: { id: jobId }, data: { status: 'cancelled' } });
    if (job.kind === 'construct' && job.targetId) {
      await this.prisma.building.updateMany({
        where: { id: job.targetId, built: false },
        data: { kind: 'empty', name: 'Slot livre', category: 'empty' },
      });
    }
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
