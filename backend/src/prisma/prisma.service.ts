import { Injectable, OnModuleInit } from '@nestjs/common';
import { PrismaClient } from '@prisma/client';

/// Conexão Prisma compartilhada. Ponto único de acesso ao banco (fonte
/// transacional). Conecta no boot; o Nest gerencia o desligamento.
@Injectable()
export class PrismaService extends PrismaClient implements OnModuleInit {
  async onModuleInit(): Promise<void> {
    await this.$connect();
  }
}
