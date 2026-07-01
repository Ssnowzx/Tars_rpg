import { Controller, Get, Param, Post, UseGuards } from '@nestjs/common';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';
import { CurrentUser, type AuthUser } from '../common/decorators/current-user.decorator';
import { FleetService } from './fleet.service';

@Controller('fleet')
@UseGuards(JwtAuthGuard)
export class FleetController {
  constructor(private readonly fleet: FleetService) {}

  @Get()
  get(@CurrentUser() user: AuthUser) {
    return this.fleet.getFleet(user.playerId);
  }

  @Post(':id/maintain')
  maintain(@CurrentUser() user: AuthUser, @Param('id') id: string) {
    return this.fleet.maintain(user.playerId, id);
  }

  @Post(':id/scrap')
  scrap(@CurrentUser() user: AuthUser, @Param('id') id: string) {
    return this.fleet.scrap(user.playerId, id);
  }
}
