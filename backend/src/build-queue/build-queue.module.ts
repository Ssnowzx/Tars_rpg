import { Module } from '@nestjs/common';
import { BuildQueueController } from './build-queue.controller';
import { BuildQueueService } from './build-queue.service';

@Module({
  controllers: [BuildQueueController],
  providers: [BuildQueueService],
  exports: [BuildQueueService],
})
export class BuildQueueModule {}
