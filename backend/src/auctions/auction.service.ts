import {
  BadRequestException,
  ForbiddenException,
  Injectable,
  NotFoundException,
} from '@nestjs/common';
import { Prisma } from '@prisma/client';
import { LedgerService } from '../common/ledger/ledger.service';
import { PrismaService } from '../prisma/prisma.service';

const UNLOCK_LEVEL = 100; // §13 — "Lenda de Fertways"

/// Tempo restante formatado a partir de `endsAt` (ex.: "Termina em 2h14").
function formatTimeLeft(endsAt: Date): string {
  const ms = endsAt.getTime() - Date.now();
  if (ms <= 0) return 'Encerrado';
  const totalMin = Math.floor(ms / 60_000);
  const days = Math.floor(totalMin / 1440);
  const hours = Math.floor((totalMin % 1440) / 60);
  const mins = totalMin % 60;
  if (days > 0) return `Termina em ${days}d ${hours}h`;
  if (hours > 0) return `Termina em ${hours}h${mins.toString().padStart(2, '0')}`;
  return `Termina em ${mins}min`;
}

/// Tempo decorrido desde o encerramento (para o histórico).
function relDay(date: Date): string {
  const min = Math.floor((Date.now() - date.getTime()) / 60_000);
  if (min < 60) return 'agora há pouco';
  const h = Math.floor(min / 60);
  if (h < 24) return `há ${h}h`;
  return `há ${Math.floor(h / 24)}d`;
}

/// Casa de Leilões (§13). Lotes são registros `Auction` reais; lances são `Bid`.
/// Nível do jogador e desbloqueio (Nível 100) são por jogador.
@Injectable()
export class AuctionService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly ledger: LedgerService,
  ) {}

  /// Encerra leilões vencidos: marca `ended` e cobra o vencedor (maior lance)
  /// via livro-razão. Se o vencedor estiver insolvente, encerra sem cobrança.
  async closeExpired(): Promise<void> {
    const due = await this.prisma.auction.findMany({
      where: { status: { not: 'ended' }, endsAt: { lte: new Date() } },
      include: { bids: { orderBy: { amount: 'desc' }, take: 1 } },
    });
    for (const a of due) {
      const top = a.bids[0];
      await this.prisma.$transaction(async (tx) => {
        await tx.auction.update({ where: { id: a.id }, data: { status: 'ended' } });
        if (top) {
          try {
            await this.ledger.apply(
              { playerId: top.playerId, amount: a.currentBid.negated(), reason: 'auction', refType: 'auction', refId: a.id },
              tx,
            );
          } catch {
            // Vencedor insolvente — leilão encerra sem cobrança.
          }
        }
      });
    }
  }

  async getAuctions(playerId: string) {
    await this.closeExpired();
    const [cfg, player, auctions, ended] = await Promise.all([
      this.prisma.serverConfig.findUnique({ where: { key: 'auctions' } }),
      this.prisma.player.findUniqueOrThrow({ where: { id: playerId }, select: { level: true } }),
      this.prisma.auction.findMany({
        where: { status: { not: 'ended' } },
        orderBy: { endsAt: 'asc' },
        include: {
          bids: { orderBy: { amount: 'desc' }, take: 1, include: { player: { select: { nickname: true } } } },
          _count: { select: { bids: true } },
        },
      }),
      this.prisma.auction.findMany({
        where: { status: 'ended' },
        orderBy: { endsAt: 'desc' },
        take: 10,
        include: {
          bids: { orderBy: { amount: 'desc' }, take: 1, include: { player: { select: { nickname: true } } } },
        },
      }),
    ]);
    const content = (cfg?.value ?? {}) as Record<string, unknown>;
    // Histórico real de leilões encerrados; se ainda não houver, usa a vitrine.
    const realHistory = ended.map((a) => ({
      name: a.name,
      winner: a.bids[0]?.player.nickname ?? 'Sem lances',
      finalPrice: Number(a.currentBid),
      day: relDay(a.endsAt),
    }));
    return {
      unlocked: player.level >= UNLOCK_LEVEL,
      unlockLevel: UNLOCK_LEVEL,
      unlockTitle: (content.unlockTitle as string) ?? 'Lenda de Fertways',
      playerLevel: player.level,
      blocked: false,
      blockReason: '',
      items: auctions.map((a) => {
        const top = a.bids[0];
        return {
          id: a.id,
          name: a.name,
          description: a.description,
          rarity: a.rarity,
          currentBid: Number(a.currentBid),
          minIncrement: Number(a.minIncrement),
          bidCount: a._count.bids,
          topBidder: top?.player.nickname ?? '',
          timeLeft: formatTimeLeft(a.endsAt),
          status: a.status,
          youAreTop: top?.playerId === playerId,
        };
      }),
      history: realHistory.length > 0 ? realHistory : (content.history ?? []),
    };
  }

  /// Registra um lance (§13): valida gate de nível, incremento mínimo e saldo,
  /// grava o `Bid` e eleva o lance atual do lote. (Cobrança do vencedor fica
  /// para o fechamento do leilão — fora deste escopo.)
  async bid(playerId: string, auctionId: string, amount: number) {
    return this.prisma.$transaction(async (tx) => {
      const [player, auction] = await Promise.all([
        tx.player.findUniqueOrThrow({ where: { id: playerId }, select: { level: true, fertBalance: true } }),
        tx.auction.findUnique({ where: { id: auctionId } }),
      ]);
      if (!auction || auction.status === 'ended') {
        throw new NotFoundException('Leilão indisponível');
      }
      if (player.level < UNLOCK_LEVEL) {
        throw new ForbiddenException(`Leilões liberam no Nível ${UNLOCK_LEVEL} (§13)`);
      }
      const minBid = auction.currentBid.plus(auction.minIncrement);
      const bid = new Prisma.Decimal(amount);
      if (bid.lessThan(minBid)) {
        throw new BadRequestException(`Lance mínimo: ${minBid.toFixed(0)} Fert$`);
      }
      if (player.fertBalance.lessThan(bid)) {
        throw new BadRequestException('Saldo Fert$ insuficiente para o lance');
      }
      await tx.bid.create({ data: { auctionId, playerId, amount: bid } });
      await tx.auction.update({ where: { id: auctionId }, data: { currentBid: bid } });
      return { ok: true, currentBid: bid.toFixed(0) };
    });
  }
}
