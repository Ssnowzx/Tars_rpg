import { BadRequestException, Injectable, NotFoundException } from '@nestjs/common';
import { Prisma } from '@prisma/client';
import { LedgerService } from '../common/ledger/ledger.service';
import { resourceLabel } from '../common/resource-label';
import { PrismaService } from '../prisma/prisma.service';
import { ResourcesService } from '../resources/resources.service';
import { CreateListingDto } from './dto/market.dto';

/// Taxa de mercado (§13/§8.3) — incidência única no fechamento.
const MARKET_TAX_RATE = 0.03;

/// Reputação Confiança Comercial (0–1000) → estrelas 0–5 exibidas no board.
function ratingFromTrust(trust: number): number {
  return Math.round(Math.min(5, Math.max(0, trust / 200)) * 10) / 10;
}

@Injectable()
export class MarketService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly ledger: LedgerService,
    private readonly resources: ResourcesService,
  ) {}

  getPrices() {
    return this.prisma.marketPrice.findMany({ orderBy: { key: 'asc' } });
  }

  /// Board do Mercado Central no formato que o cliente consome (§13): tickers de
  /// preço (§22) + ordens reais a partir dos anúncios abertos (escrow). Os ids
  /// das ordens são os ids reais dos `MarketListing` (usados no /buy).
  async getBoard() {
    const [prices, listings] = await Promise.all([
      this.prisma.marketPrice.findMany({ orderBy: { key: 'asc' } }),
      this.prisma.marketListing.findMany({
        where: { status: 'open' },
        orderBy: { createdAt: 'desc' },
        include: {
          seller: {
            select: {
              nickname: true,
              reputation: { select: { commercialTrust: true } },
              colony: { select: { sector: true } },
            },
          },
        },
      }),
    ]);
    return {
      tickers: prices.map((p) => ({
        resourceId: p.key,
        resourceLabel: resourceLabel(p.key),
        lastPrice: Number(p.basePrice),
        changePct: 0,
      })),
      orders: listings.map((l) => ({
        id: l.id,
        side: 'sell',
        resourceId: l.key,
        resourceLabel: resourceLabel(l.key),
        quantity: l.quantity,
        unitPrice: Number(l.unitPrice),
        trader: l.seller.nickname,
        traderSector: l.seller.colony?.sector ?? '',
        traderRating: ratingFromTrust(l.seller.reputation?.commercialTrust ?? 500),
      })),
    };
  }

  async getListings() {
    const listings = await this.prisma.marketListing.findMany({
      where: { status: 'open' },
      orderBy: { createdAt: 'desc' },
      include: { seller: { select: { nickname: true } } },
    });
    return listings.map((l) => ({
      id: l.id,
      key: l.key,
      quantity: l.quantity,
      unitPrice: l.unitPrice,
      seller: l.seller.nickname,
      createdAt: l.createdAt,
    }));
  }

  /// Cria anúncio com escrow: reserva (debita) o recurso do vendedor (§13).
  async createListing(playerId: string, dto: CreateListingDto) {
    return this.prisma.$transaction(async (tx) => {
      await this.resources.adjust(playerId, dto.key, -dto.quantity, tx);
      return tx.marketListing.create({
        data: {
          sellerId: playerId,
          key: dto.key,
          quantity: dto.quantity,
          unitPrice: new Prisma.Decimal(dto.unitPrice),
          status: 'open',
        },
      });
    });
  }

  /// Compra: comprador paga Fert$ (ledger), vendedor recebe líquido (menos taxa),
  /// comprador recebe os recursos (já em escrow). Tudo em uma transação (§6/§13).
  async buy(playerId: string, listingId: string, quantity: number) {
    return this.prisma.$transaction(async (tx) => {
      const listing = await tx.marketListing.findUnique({ where: { id: listingId } });
      if (!listing || listing.status !== 'open') {
        throw new NotFoundException('Anúncio indisponível');
      }
      if (listing.sellerId === playerId) {
        throw new BadRequestException('Não é possível comprar o próprio anúncio');
      }
      if (quantity > listing.quantity) {
        throw new BadRequestException('Quantidade acima do disponível');
      }
      const total = listing.unitPrice.mul(quantity);
      const tax = total.mul(MARKET_TAX_RATE);
      const net = total.minus(tax);

      await this.ledger.apply(
        { playerId, amount: total.negated(), reason: 'marketBuy', refType: 'listing', refId: listing.id },
        tx,
      );
      await this.ledger.apply(
        { playerId: listing.sellerId, amount: net, reason: 'marketSale', refType: 'listing', refId: listing.id },
        tx,
      );
      await this.resources.adjust(playerId, listing.key, quantity, tx);
      await tx.marketOrder.create({
        data: { listingId: listing.id, buyerId: playerId, quantity, total, taxPaid: tax },
      });
      const remaining = listing.quantity - quantity;
      await tx.marketListing.update({
        where: { id: listing.id },
        data: { quantity: remaining, status: remaining === 0 ? 'sold' : 'open' },
      });
      return {
        ok: true,
        total: total.toFixed(4),
        tax: tax.toFixed(4),
        net: net.toFixed(4),
        remaining,
      };
    });
  }

  /// Cancela anúncio aberto e devolve o recurso em escrow ao vendedor.
  async cancelListing(playerId: string, listingId: string): Promise<{ ok: boolean }> {
    return this.prisma.$transaction(async (tx) => {
      const listing = await tx.marketListing.findUnique({ where: { id: listingId } });
      if (!listing || listing.sellerId !== playerId) {
        throw new NotFoundException('Anúncio não encontrado');
      }
      if (listing.status !== 'open') {
        throw new BadRequestException('Anúncio não está aberto');
      }
      await this.resources.adjust(playerId, listing.key, listing.quantity, tx);
      await tx.marketListing.update({
        where: { id: listing.id },
        data: { status: 'cancelled', quantity: 0 },
      });
      return { ok: true };
    });
  }
}
