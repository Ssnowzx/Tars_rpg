import { BadRequestException, Injectable, NotFoundException } from '@nestjs/common';
import { Prisma } from '@prisma/client';
import { LedgerService } from '../common/ledger/ledger.service';
import { PrismaService } from '../prisma/prisma.service';

export interface MissionEntry {
  id: string;
  category: string;
  title: string;
  description: string;
  current: number;
  target: number;
  reward: string;
  status: string;
  timeLabel: string;
  rejectable?: boolean;
}

export interface AchievementEntry {
  id: string;
  title: string;
  description: string;
  tier: string;
  current: number;
  target: number;
  unlocked: boolean;
}

export interface MissionBoard {
  dailyDone: number;
  dailyTotal: number;
  streak: number;
  missions: MissionEntry[];
  achievements: AchievementEntry[];
  events: unknown[];
}

/// Painel de Missões/Conquistas/Eventos (§6) por jogador.
/// - O *conteúdo* (quais missões existem) é config canônica em `missionsBoard`.
/// - O *progresso* é por jogador: guardado em `Player.missionState` (JSON).
///   Jogador novo (missionState null) recebe um board "fresco" derivado do
///   conteúdo (progresso zerado, sem streak, conquistas travadas).
@Injectable()
export class MissionService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly ledger: LedgerService,
  ) {}

  async getBoard(playerId: string): Promise<MissionBoard> {
    const player = await this.prisma.player.findUniqueOrThrow({
      where: { id: playerId },
      select: { missionState: true },
    });
    if (player.missionState) {
      return player.missionState as unknown as MissionBoard;
    }
    return this.freshBoard();
  }

  /// Resgata a recompensa de uma missão concluída: credita Fert$ (livro-razão) e
  /// marca a missão como `claimed`, persistindo o estado do jogador.
  async claim(playerId: string, missionId: string) {
    const board = await this.getBoard(playerId);
    const mission = board.missions.find((m) => m.id === missionId);
    if (!mission) {
      throw new NotFoundException('Missão não encontrada');
    }
    if (mission.status !== 'completed') {
      throw new BadRequestException('Missão não está pronta para resgate');
    }
    const fert = parseFertReward(mission.reward);

    await this.prisma.$transaction(async (tx) => {
      if (fert > 0) {
        await this.ledger.apply(
          { playerId, amount: new Prisma.Decimal(fert), reason: 'missionReward', refType: 'mission', refId: missionId },
          tx,
        );
      }
      mission.status = 'claimed';
      mission.current = mission.target;
      if (mission.category === 'daily') {
        board.dailyDone = Math.min(board.dailyTotal, board.dailyDone + 1);
      }
      await tx.player.update({
        where: { id: playerId },
        data: { missionState: board as unknown as Prisma.InputJsonValue },
      });
    });
    return { ok: true, fertRewarded: fert };
  }

  /// Board inicial de um jogador novo (progresso zerado a partir do conteúdo).
  private async freshBoard(): Promise<MissionBoard> {
    const cfg = await this.prisma.serverConfig.findUnique({ where: { key: 'missionsBoard' } });
    const content = (cfg?.value ?? {}) as unknown as MissionBoard;
    const missions = (content.missions ?? []).map((m) => ({
      ...m,
      current: 0,
      status: freshStatus(m.category),
    }));
    return {
      dailyDone: 0,
      dailyTotal: missions.filter((m) => m.category === 'daily').length,
      streak: 0,
      missions,
      achievements: (content.achievements ?? []).map((a) => ({ ...a, current: 0, unlocked: false })),
      events: content.events ?? [],
    };
  }
}

/// Missões de tutorial/diárias/semanais/eventos começam disponíveis; as de
/// narrativa/federação/guerra começam travadas (divulgação progressiva §6).
function freshStatus(category: string): string {
  switch (category) {
    case 'tutorial':
    case 'daily':
    case 'weekly':
    case 'event':
      return 'available';
    default:
      return 'locked';
  }
}

/// Extrai o valor em Fert$ de uma string de recompensa (ex.: "+800 Fert$ · …").
function parseFertReward(reward: string): number {
  const match = reward.match(/([\d.]+)\s*Fert/i);
  if (!match) return 0;
  const digits = match[1].replace(/\./g, '');
  const value = Number.parseInt(digits, 10);
  return Number.isFinite(value) ? value : 0;
}
