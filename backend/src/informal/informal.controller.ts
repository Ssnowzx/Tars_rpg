import { Controller, Get, Param, Post, UseGuards } from '@nestjs/common';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';
import { CurrentUser, type AuthUser } from '../common/decorators/current-user.decorator';
import { InformalService } from './informal.service';

@Controller('informal')
@UseGuards(JwtAuthGuard)
export class InformalController {
  constructor(private readonly informal: InformalService) {}

  @Get()
  board(@CurrentUser() user: AuthUser) {
    return this.informal.getBoard(user.playerId);
  }

  @Post(':id/accept')
  accept(@CurrentUser() user: AuthUser, @Param('id') id: string) {
    return this.informal.accept(user.playerId, id);
  }
}
