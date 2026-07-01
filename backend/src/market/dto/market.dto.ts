import { ResourceKey } from '@prisma/client';
import { IsEnum, IsInt, IsPositive, Min } from 'class-validator';

export class CreateListingDto {
  @IsEnum(ResourceKey)
  key!: ResourceKey;

  @IsInt()
  @Min(1)
  quantity!: number;

  @IsPositive()
  unitPrice!: number;
}

export class BuyDto {
  @IsInt()
  @Min(1)
  quantity!: number;
}
