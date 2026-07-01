import { BuildingCategory } from '@prisma/client';
import { IsEnum, IsString, MaxLength, MinLength } from 'class-validator';

export class BuildDto {
  @IsString()
  @MinLength(2)
  @MaxLength(40)
  kind!: string;

  @IsString()
  @MinLength(2)
  @MaxLength(60)
  name!: string;

  @IsEnum(BuildingCategory)
  category!: BuildingCategory;
}
