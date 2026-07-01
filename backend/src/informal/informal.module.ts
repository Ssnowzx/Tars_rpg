import { Module } from '@nestjs/common';
import { ResourcesModule } from '../resources/resources.module';
import { InformalController } from './informal.controller';
import { InformalService } from './informal.service';

@Module({
  imports: [ResourcesModule],
  controllers: [InformalController],
  providers: [InformalService],
})
export class InformalModule {}
