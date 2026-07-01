import { Module } from '@nestjs/common';
import { ResourcesModule } from '../resources/resources.module';
import { BuildQueueController } from './build-queue.controller';
import { BuildQueueService } from './build-queue.service';

@Module({
  imports: [ResourcesModule],
  controllers: [BuildQueueController],
  providers: [BuildQueueService],
  exports: [BuildQueueService],
})
export class BuildQueueModule {}
