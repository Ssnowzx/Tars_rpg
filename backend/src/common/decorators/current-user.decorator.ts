import { createParamDecorator, ExecutionContext } from '@nestjs/common';

export interface AuthUser {
  playerId: string;
}

/// Injeta o jogador autenticado (a partir do JWT) num handler de rota.
export const CurrentUser = createParamDecorator(
  (_data: unknown, ctx: ExecutionContext): AuthUser => {
    const request = ctx.switchToHttp().getRequest<{ user: AuthUser }>();
    return request.user;
  },
);
