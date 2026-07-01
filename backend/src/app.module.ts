import { Module } from '@nestjs/common';
import { ConfigModule } from '@nestjs/config';
import { AppController } from './app.controller';
import { AppService } from './app.service';
import { AuthModule } from './auth/auth.module';
import { BuildQueueModule } from './build-queue/build-queue.module';
import { ColonyModule } from './colony/colony.module';
import { LedgerModule } from './common/ledger/ledger.module';
import { ContentModule } from './content/content.module';
import { HealthController } from './health/health.controller';
import { MarketModule } from './market/market.module';
import { NotificationsModule } from './notifications/notifications.module';
import { PlayerModule } from './player/player.module';
import { PrismaModule } from './prisma/prisma.module';
import { ResourcesModule } from './resources/resources.module';

@Module({
  imports: [
    ConfigModule.forRoot({ isGlobal: true }),
    PrismaModule,
    LedgerModule,
    AuthModule,
    PlayerModule,
    ColonyModule,
    ResourcesModule,
    BuildQueueModule,
    MarketModule,
    ContentModule,
    NotificationsModule,
  ],
  controllers: [AppController, HealthController],
  providers: [AppService],
})
export class AppModule {}
