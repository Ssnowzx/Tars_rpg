import { Injectable } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';

/// Casa de Leilões (§13). O catálogo de lotes é conteúdo canônico compartilhado
/// (`auctions`), mas o **nível do jogador** e o desbloqueio são por jogador — um
/// colono novo vê o próprio nível, não o do jogador de demonstração.
@Injectable()
export class AuctionService {
  constructor(private readonly prisma: PrismaService) {}

  async getAuctions(playerId: string) {
    const [cfg, player] = await Promise.all([
      this.prisma.serverConfig.findUnique({ where: { key: 'auctions' } }),
      this.prisma.player.findUniqueOrThrow({ where: { id: playerId }, select: { level: true } }),
    ]);
    const content = (cfg?.value ?? {}) as Record<string, unknown>;
    const unlockLevel = (content.unlockLevel as number) ?? 100;
    return {
      ...content,
      playerLevel: player.level,
      unlocked: player.level >= unlockLevel,
    };
  }
}
