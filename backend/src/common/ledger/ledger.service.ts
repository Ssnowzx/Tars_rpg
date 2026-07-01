import { BadRequestException, Injectable } from '@nestjs/common';
import { LedgerReason, Prisma } from '@prisma/client';
import { PrismaService } from '../../prisma/prisma.service';

type Db = PrismaService | Prisma.TransactionClient;

export interface LedgerMovement {
  playerId: string;
  amount: Prisma.Decimal | number | string; // positivo = crédito, negativo = débito
  reason: LedgerReason;
  refType?: string;
  refId?: string;
}

/// Movimenta Fert$ de forma atômica: atualiza o saldo do jogador e anexa um
/// lançamento imutável no livro-razão (§6). Use dentro de uma transação para
/// operações compostas (ex.: compra no Mercado).
@Injectable()
export class LedgerService {
  constructor(private readonly prisma: PrismaService) {}

  async apply(movement: LedgerMovement, tx?: Prisma.TransactionClient) {
    const db: Db = tx ?? this.prisma;
    const player = await db.player.findUniqueOrThrow({
      where: { id: movement.playerId },
      select: { fertBalance: true },
    });
    const amount = new Prisma.Decimal(movement.amount);
    const balanceAfter = player.fertBalance.plus(amount);
    if (balanceAfter.isNegative()) {
      throw new BadRequestException('Saldo Fert$ insuficiente');
    }
    await db.player.update({
      where: { id: movement.playerId },
      data: { fertBalance: balanceAfter },
    });
    return db.ledgerEntry.create({
      data: {
        playerId: movement.playerId,
        amount,
        balanceAfter,
        reason: movement.reason,
        refType: movement.refType ?? null,
        refId: movement.refId ?? null,
      },
    });
  }
}
