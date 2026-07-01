import { BadRequestException, Injectable, NotFoundException } from '@nestjs/common';
import { Prisma } from '@prisma/client';
import { LedgerService } from '../common/ledger/ledger.service';
import { PrismaService } from '../prisma/prisma.service';

/// Frota do colono (§16/§21) por jogador. Lê os registros `Vehicle` do dono e as
/// vagas de hangar da colônia — um jogador novo vê apenas sua frota inicial.
@Injectable()
export class FleetService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly ledger: LedgerService,
  ) {}

  async getFleet(playerId: string) {
    const [vehicles, colony] = await Promise.all([
      this.prisma.vehicle.findMany({
        where: { ownerId: playerId },
        orderBy: { createdAt: 'asc' },
      }),
      this.prisma.colony.findUnique({
        where: { playerId },
        select: { fleetSlots: true },
      }),
    ]);
    return {
      garageUsed: vehicles.length,
      garageCapacity: colony?.fleetSlots ?? 4,
      vehicles: vehicles.map((v) => ({
        id: v.id,
        plate: v.plate ?? '',
        kind: v.kindLabel,
        capacityM3: v.capacityM3,
        condition: v.condition,
        activeHours: v.activeHours,
        status: v.statusLabel,
        assignment: v.assignment,
        maintenanceCost: v.maintenanceCost,
        buildDay: v.buildDayLabel,
        criticalThreshold: 20,
      })),
    };
  }

  /// Manutenção (§16.4): cobra o custo em Fert$ (livro-razão) e restaura a
  /// condição do veículo, tirando-o do estado bloqueado/manutenção.
  async maintain(playerId: string, vehicleId: string) {
    const vehicle = await this.prisma.vehicle.findFirst({ where: { id: vehicleId, ownerId: playerId } });
    if (!vehicle) throw new NotFoundException('Veículo não encontrado');
    return this.prisma.$transaction(async (tx) => {
      if (vehicle.maintenanceCost > 0) {
        await this.ledger.apply(
          {
            playerId,
            amount: new Prisma.Decimal(-vehicle.maintenanceCost),
            reason: 'maintenance',
            refType: 'vehicle',
            refId: vehicleId,
          },
          tx,
        );
      }
      await tx.vehicle.update({
        where: { id: vehicleId },
        data: {
          integrity: 1,
          condition: 100,
          status: 'idle',
          statusLabel: 'idle',
          assignment: 'Ocioso no hangar',
          activeHours: 0,
        },
      });
      return { ok: true };
    });
  }

  /// Sucateamento: remove o veículo da frota do jogador, liberando vaga.
  async scrap(playerId: string, vehicleId: string): Promise<{ ok: boolean }> {
    const result = await this.prisma.vehicle.deleteMany({ where: { id: vehicleId, ownerId: playerId } });
    if (result.count === 0) throw new BadRequestException('Veículo não encontrado');
    return { ok: true };
  }
}
