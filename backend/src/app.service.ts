import { Injectable } from '@nestjs/common';

@Injectable()
export class AppService {
  getInfo(): { name: string; version: string; docs: string } {
    return {
      name: 'Fertways API',
      version: '0.0.1',
      docs: 'GET /api/health',
    };
  }
}
