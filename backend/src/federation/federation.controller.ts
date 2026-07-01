import { Controller, Get, UseGuards } from '@nestjs/common';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';
import { CurrentUser, type AuthUser } from '../common/decorators/current-user.decorator';
import { FederationService } from './federation.service';

@Controller('federation')
@UseGuards(JwtAuthGuard)
export class FederationController {
  constructor(private readonly federation: FederationService) {}

  @Get()
  get(@CurrentUser() user: AuthUser) {
    return this.federation.getFederation(user.playerId);
  }
}
