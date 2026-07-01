import { BadRequestException, Injectable, NotFoundException } from '@nestjs/common';
import { resourceLabel } from '../common/resource-label';
import { frontendTier } from '../common/resource-tier';
import { PrismaService } from '../prisma/prisma.service';
import { ResourcesService } from '../resources/resources.service';

/// Confiança Comercial (0–1000) → estrelas 0–5.
function ratingFromTrust(trust: number): number {
  return Math.round(Math.min(5, Math.max(0, trust / 200)) * 10) / 10;
}

/// Comércio Informal (§8): ofertas de barter reais entre colonos. Sem escrow —
/// aceitar troca os recursos atomicamente. As alíquotas/isenção do cabeçalho
/// são conteúdo canônico (`informal` config).
@Injectable()
export class InformalService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly resources: ResourcesService,
  ) {}

  async getBoard(playerId: string) {
    const [offers, cfg] = await Promise.all([
      this.prisma.informalOffer.findMany({
        where: { status: 'open', NOT: { sellerId: playerId } },
        orderBy: { createdAt: 'asc' },
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
      this.prisma.serverConfig.findUnique({ where: { key: 'informal' } }),
    ]);
    const content = (cfg?.value ?? {}) as Record<string, unknown>;
    return {
      taxRates: content.taxRates ?? { primary: 3, secondary: 2, rare: 1 },
      federationExemption: content.federationExemption ?? '',
      offers: offers.map((o) => {
        const trust = o.seller.reputation?.commercialTrust ?? 500;
        return {
          id: o.id,
          trader: o.seller.nickname,
          sector: o.seller.colony?.sector ?? '',
          rating: ratingFromTrust(trust),
          ratings: o.deals,
          commercialTrust: trust,
          distanceSlots: o.distanceSlots,
          deals: o.deals,
          successRate: o.successRate,
          scams: o.scams,
          give: { resourceId: o.giveKey, label: resourceLabel(o.giveKey), qty: o.giveQty, tier: frontendTier(o.giveKey) },
          want: { resourceId: o.wantKey, label: resourceLabel(o.wantKey), qty: o.wantQty, tier: frontendTier(o.wantKey) },
          sameFederation: false,
          note: o.note,
        };
      }),
      history: [],
    };
  }

  /// Aceita a oferta: você envia `want`, recebe `give`; o ofertante faz o
  /// inverso. Tudo numa transação (§8 — sem escrow, sem árbitro automático).
  async accept(playerId: string, offerId: string) {
    return this.prisma.$transaction(async (tx) => {
      const offer = await tx.informalOffer.findUnique({ where: { id: offerId } });
      if (!offer || offer.status !== 'open') {
        throw new NotFoundException('Oferta indisponível');
      }
      if (offer.sellerId === playerId) {
        throw new BadRequestException('Não é possível aceitar a própria oferta');
      }
      // Comprador: -want, +give. Ofertante: +want, -give.
      await this.resources.adjust(playerId, offer.wantKey, -offer.wantQty, tx);
      await this.resources.adjust(playerId, offer.giveKey, offer.giveQty, tx);
      await this.resources.adjust(offer.sellerId, offer.wantKey, offer.wantQty, tx);
      await this.resources.adjust(offer.sellerId, offer.giveKey, -offer.giveQty, tx);
      await tx.informalOffer.update({ where: { id: offer.id }, data: { status: 'closed' } });
      return {
        ok: true,
        received: { key: offer.giveKey, qty: offer.giveQty },
        sent: { key: offer.wantKey, qty: offer.wantQty },
      };
    });
  }
}
