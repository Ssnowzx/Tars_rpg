import { Body, Controller, Get, Param, Post, UseGuards } from '@nestjs/common';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';
import { CurrentUser, type AuthUser } from '../common/decorators/current-user.decorator';
import { AuctionService } from './auction.service';
import { BidDto } from './dto/bid.dto';

@Controller('auctions')
@UseGuards(JwtAuthGuard)
export class AuctionController {
  constructor(private readonly auctions: AuctionService) {}

  @Get()
  get(@CurrentUser() user: AuthUser) {
    return this.auctions.getAuctions(user.playerId);
  }

  @Post(':id/bid')
  bid(@CurrentUser() user: AuthUser, @Param('id') id: string, @Body() dto: BidDto) {
    return this.auctions.bid(user.playerId, id, dto.amount);
  }
}
