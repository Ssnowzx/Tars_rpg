import { Body, Controller, Get, Param, Post, UseGuards } from '@nestjs/common';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';
import { CurrentUser, type AuthUser } from '../common/decorators/current-user.decorator';
import { BuyDto, CreateListingDto } from './dto/market.dto';
import { MarketService } from './market.service';

@Controller('market')
export class MarketController {
  constructor(private readonly market: MarketService) {}

  /// Preços-base de referência (§22) — público.
  @Get('prices')
  prices() {
    return this.market.getPrices();
  }

  @Get('listings')
  @UseGuards(JwtAuthGuard)
  listings() {
    return this.market.getListings();
  }

  @Post('listings')
  @UseGuards(JwtAuthGuard)
  create(@CurrentUser() user: AuthUser, @Body() dto: CreateListingDto) {
    return this.market.createListing(user.playerId, dto);
  }

  @Post('listings/:id/buy')
  @UseGuards(JwtAuthGuard)
  buy(@CurrentUser() user: AuthUser, @Param('id') id: string, @Body() dto: BuyDto) {
    return this.market.buy(user.playerId, id, dto.quantity);
  }

  @Post('listings/:id/cancel')
  @UseGuards(JwtAuthGuard)
  cancel(@CurrentUser() user: AuthUser, @Param('id') id: string) {
    return this.market.cancelListing(user.playerId, id);
  }
}
