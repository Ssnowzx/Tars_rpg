import { Module } from '@nestjs/common';
import { ResourcesModule } from '../resources/resources.module';
import { MarketController } from './market.controller';
import { MarketService } from './market.service';

@Module({
  imports: [ResourcesModule],
  controllers: [MarketController],
  providers: [MarketService],
})
export class MarketModule {}
