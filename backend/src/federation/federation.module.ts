import { Module } from '@nestjs/common';
import { FederationController } from './federation.controller';
import { FederationService } from './federation.service';

@Module({
  controllers: [FederationController],
  providers: [FederationService],
})
export class FederationModule {}
