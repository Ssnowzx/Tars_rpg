import { Injectable } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';

/// Federação do jogador (§4). A *filiação* é um registro Prisma por jogador
/// (`FederationMember`); o *conteúdo* de exibição (roster de demonstração, regras,
/// aliados) é a config canônica em `federation`. Um jogador sem filiação recebe
/// um estado vazio ("você não está em uma federação").
@Injectable()
export class FederationService {
  constructor(private readonly prisma: PrismaService) {}

  async getFederation(playerId: string) {
    const [member, player] = await Promise.all([
      this.prisma.federationMember.findUnique({
        where: { playerId },
        include: { federation: true },
      }),
      this.prisma.player.findUniqueOrThrow({
        where: { id: playerId },
        select: { nickname: true },
      }),
    ]);

    if (!member) {
      return { inFederation: false, name: '', tag: '', motto: '', members: [], allies: [] };
    }

    const cfg = await this.prisma.serverConfig.findUnique({ where: { key: 'federation' } });
    const content = (cfg?.value ?? {}) as Record<string, unknown>;
    const members = Array.isArray(content.members) ? [...(content.members as Record<string, unknown>[])] : [];

    // Marca "isYou" no membro correspondente ao jogador logado (por nickname).
    const yourName = player.nickname;
    let matched = false;
    const roster = members.map((m) => {
      const isYou = !matched && (m.name === yourName || m.isYou === true);
      if (isYou) matched = true;
      return { ...m, isYou };
    });

    return {
      ...content,
      inFederation: true,
      name: member.federation.name,
      tag: member.federation.tag ?? content.tag ?? '',
      fundBalance: Number(member.federation.treasury) || content.fundBalance || 0,
      members: roster,
    };
  }
}
