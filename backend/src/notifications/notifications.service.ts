import { Injectable } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';

@Injectable()
export class NotificationsService {
  constructor(private readonly prisma: PrismaService) {}

  getForPlayer(playerId: string) {
    return this.prisma.notification.findMany({
      where: { playerId },
      orderBy: { createdAt: 'desc' },
      take: 50,
    });
  }

  async markRead(playerId: string, id: string): Promise<{ ok: boolean }> {
    await this.prisma.notification.updateMany({
      where: { id, playerId },
      data: { read: true },
    });
    return { ok: true };
  }
}
