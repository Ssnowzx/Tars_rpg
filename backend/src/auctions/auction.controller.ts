import { Controller, Get, UseGuards } from '@nestjs/common';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';
import { CurrentUser, type AuthUser } from '../common/decorators/current-user.decorator';
import { AuctionService } from './auction.service';

@Controller('auctions')
@UseGuards(JwtAuthGuard)
export class AuctionController {
  constructor(private readonly auctions: AuctionService) {}

  @Get()
  get(@CurrentUser() user: AuthUser) {
    return this.auctions.getAuctions(user.playerId);
  }
}
