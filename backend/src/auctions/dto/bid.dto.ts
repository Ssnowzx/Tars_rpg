import { IsInt, IsPositive } from 'class-validator';

export class BidDto {
  @IsInt()
  @IsPositive()
  amount!: number;
}
