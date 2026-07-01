import { Controller, Get, Param, Post, UseGuards } from '@nestjs/common';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';
import { CurrentUser, type AuthUser } from '../common/decorators/current-user.decorator';
import { BuildQueueService } from './build-queue.service';

@Controller('build-queue')
@UseGuards(JwtAuthGuard)
export class BuildQueueController {
  constructor(private readonly queue: BuildQueueService) {}

  @Get()
  list(@CurrentUser() user: AuthUser) {
    return this.queue.list(user.playerId);
  }

  @Post(':id/cancel')
  cancel(@CurrentUser() user: AuthUser, @Param('id') id: string) {
    return this.queue.cancel(user.playerId, id);
  }

  @Post(':id/complete')
  complete(@CurrentUser() user: AuthUser, @Param('id') id: string) {
    return this.queue.complete(user.playerId, id);
  }
}
