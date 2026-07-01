import { Controller, Get, UseGuards } from '@nestjs/common';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';
import { CurrentUser, type AuthUser } from '../common/decorators/current-user.decorator';
import { PlayerService } from './player.service';

@Controller('me')
@UseGuards(JwtAuthGuard)
export class PlayerController {
  constructor(private readonly player: PlayerService) {}

  @Get()
  getMe(@CurrentUser() user: AuthUser) {
    return this.player.getMe(user.playerId);
  }
}
