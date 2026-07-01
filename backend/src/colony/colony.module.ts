import { Module } from '@nestjs/common';
import { BuildQueueModule } from '../build-queue/build-queue.module';
import { ColonyController } from './colony.controller';
import { ColonyService } from './colony.service';

@Module({
  imports: [BuildQueueModule],
  controllers: [ColonyController],
  providers: [ColonyService],
})
export class ColonyModule {}
