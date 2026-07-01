import { Body, Controller, Get, Param, Post, UseGuards } from '@nestjs/common';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';
import { BuildQueueService } from '../build-queue/build-queue.service';
import { CurrentUser, type AuthUser } from '../common/decorators/current-user.decorator';
import { ColonyService } from './colony.service';
import { BuildDto } from './dto/build.dto';

@Controller('colony')
@UseGuards(JwtAuthGuard)
export class ColonyController {
  constructor(
    private readonly colony: ColonyService,
    private readonly queue: BuildQueueService,
  ) {}

  @Get()
  get(@CurrentUser() user: AuthUser) {
    return this.colony.getColony(user.playerId);
  }

  /// Evoluir uma construção existente (Nv N → N+1) — enfileira obra.
  @Post('buildings/:id/upgrade')
  upgrade(@CurrentUser() user: AuthUser, @Param('id') id: string) {
    return this.queue.enqueueUpgrade(user.playerId, id);
  }

  /// Construir no primeiro slot livre — enfileira obra.
  @Post('build')
  build(@CurrentUser() user: AuthUser, @Body() dto: BuildDto) {
    return this.queue.enqueueNew(user.playerId, dto);
  }
}
