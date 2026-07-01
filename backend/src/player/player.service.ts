import { Injectable } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';

@Injectable()
export class PlayerService {
  constructor(private readonly prisma: PrismaService) {}

  async getMe(playerId: string) {
    const player = await this.prisma.player.findUniqueOrThrow({
      where: { id: playerId },
      include: { reputation: true },
    });
    return {
      id: player.id,
      email: player.email,
      nickname: player.nickname,
      avatarUrl: player.avatarUrl,
      locale: player.locale,
      marco: player.marco,
      level: player.level,
      xp: player.xp,
      fertBalance: player.fertBalance,
      reputation: player.reputation && {
        commercialTrust: player.reputation.commercialTrust,
        socialConduct: player.reputation.socialConduct,
        civicStatus: player.reputation.civicStatus,
        militaryHonor: player.reputation.militaryHonor,
      },
    };
  }
}
