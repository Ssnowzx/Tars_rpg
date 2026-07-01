import { randomBytes } from 'node:crypto';
import {
  ConflictException,
  Injectable,
  UnauthorizedException,
} from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import * as bcrypt from 'bcryptjs';
import { LedgerService } from '../common/ledger/ledger.service';
import { backendKind, backendStatus, starterFleet } from '../common/fleet-catalog';
import { STARTER_BUILDINGS, STARTER_STOCKS } from '../common/starter-data';
import { PrismaService } from '../prisma/prisma.service';
import { AuthTokens, LoginDto, RegisterDto } from './dto/auth.dto';

@Injectable()
export class AuthService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly jwt: JwtService,
    private readonly ledger: LedgerService,
  ) {}

  /// Cria conta + colônia inicial (§onboarding): jogador, reputação, colônia com
  /// construções essenciais, estoques iniciais e 50 Fert$ de subsídio — tudo em
  /// uma transação.
  async register(dto: RegisterDto): Promise<AuthTokens> {
    const existing = await this.prisma.player.findFirst({
      where: { OR: [{ email: dto.email }, { nickname: dto.nickname }] },
      select: { id: true },
    });
    if (existing) {
      throw new ConflictException('Email ou nickname já em uso');
    }
    const passwordHash = await bcrypt.hash(dto.password, 10);

    const player = await this.prisma.$transaction(async (tx) => {
      const created = await tx.player.create({
        data: {
          email: dto.email,
          nickname: dto.nickname,
          passwordHash,
          fertBalance: 0,
        },
      });
      await tx.reputation.create({ data: { playerId: created.id } });
      const colony = await tx.colony.create({
        data: { playerId: created.id, name: `Colônia ${dto.nickname}`, sector: 'F-07' },
      });
      await tx.building.createMany({
        data: STARTER_BUILDINGS.map((b) => ({ ...b, colonyId: colony.id })),
      });
      await tx.resourceStock.createMany({
        data: STARTER_STOCKS.map((s) => ({ ...s, playerId: created.id })),
      });
      await tx.vehicle.createMany({
        data: starterFleet(created.id).map((v) => ({
          ownerId: created.id,
          kind: backendKind(v.kindLabel),
          status: backendStatus(v.statusLabel),
          plate: v.plate,
          kindLabel: v.kindLabel,
          statusLabel: v.statusLabel,
          capacityM3: v.capacityM3,
          condition: v.condition,
          activeHours: v.activeHours,
          maintenanceCost: v.maintenanceCost,
          assignment: v.assignment,
          buildDayLabel: v.buildDayLabel,
        })),
      });
      await this.ledger.apply(
        { playerId: created.id, amount: 50, reason: 'subsidy', refType: 'onboarding' },
        tx,
      );
      return created;
    });

    return this.issueTokens(player.id);
  }

  async login(dto: LoginDto): Promise<AuthTokens> {
    const player = await this.prisma.player.findUnique({ where: { email: dto.email } });
    if (!player) {
      throw new UnauthorizedException('Credenciais inválidas');
    }
    const ok = await bcrypt.compare(dto.password, player.passwordHash);
    if (!ok) {
      throw new UnauthorizedException('Credenciais inválidas');
    }
    return this.issueTokens(player.id);
  }

  /// Renova o access token a partir de um refresh token válido (não expirado /
  /// não revogado). Formato do refresh: "<id>.<segredo>".
  async refresh(refreshToken: string): Promise<{ accessToken: string }> {
    const [id, raw] = refreshToken.split('.');
    if (!id || !raw) {
      throw new UnauthorizedException('Refresh token inválido');
    }
    const record = await this.prisma.refreshToken.findUnique({ where: { id } });
    if (!record || record.revokedAt || record.expiresAt < new Date()) {
      throw new UnauthorizedException('Refresh token expirado');
    }
    const ok = await bcrypt.compare(raw, record.tokenHash);
    if (!ok) {
      throw new UnauthorizedException('Refresh token inválido');
    }
    return { accessToken: await this.signAccess(record.playerId) };
  }

  private async signAccess(playerId: string): Promise<string> {
    const ttl = Number(process.env.JWT_ACCESS_TTL ?? 3600);
    return this.jwt.signAsync(
      { sub: playerId },
      { secret: process.env.JWT_SECRET, expiresIn: ttl },
    );
  }

  private async issueTokens(playerId: string): Promise<AuthTokens> {
    const accessToken = await this.signAccess(playerId);
    const raw = randomBytes(48).toString('hex');
    const tokenHash = await bcrypt.hash(raw, 10);
    const days = Number(process.env.JWT_REFRESH_TTL_DAYS ?? 30);
    const expiresAt = new Date(Date.now() + days * 24 * 60 * 60 * 1000);
    const record = await this.prisma.refreshToken.create({
      data: { playerId, tokenHash, expiresAt },
    });
    return { accessToken, refreshToken: `${record.id}.${raw}`, playerId };
  }
}
