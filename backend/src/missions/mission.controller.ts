import { Controller, Get, Param, Post, UseGuards } from '@nestjs/common';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';
import { CurrentUser, type AuthUser } from '../common/decorators/current-user.decorator';
import { MissionService } from './mission.service';

@Controller('missions')
@UseGuards(JwtAuthGuard)
export class MissionController {
  constructor(private readonly missions: MissionService) {}

  @Get('board')
  board(@CurrentUser() user: AuthUser) {
    return this.missions.getBoard(user.playerId);
  }

  @Post(':id/claim')
  claim(@CurrentUser() user: AuthUser, @Param('id') id: string) {
    return this.missions.claim(user.playerId, id);
  }
}
