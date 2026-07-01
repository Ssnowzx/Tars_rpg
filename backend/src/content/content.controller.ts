import { Controller, Get, Param } from '@nestjs/common';
import { ContentService } from './content.service';

/// Dados de referência públicos (não exigem login).
@Controller()
export class ContentController {
  constructor(private readonly content: ContentService) {}

  @Get('lunar')
  lunar() {
    return this.content.getLunar();
  }

  @Get('terraform')
  terraform() {
    return this.content.getTerraform();
  }

  @Get('spaceport')
  spaceport() {
    return this.content.getSpaceport();
  }

  @Get('missions')
  missions() {
    return this.content.getMissions();
  }

  /// Config estático por chave (Capital, ministérios, mapa-planeta, etc.).
  @Get('config/:key')
  config(@Param('key') key: string): Promise<unknown> {
    return this.content.getConfig(key);
  }
}
