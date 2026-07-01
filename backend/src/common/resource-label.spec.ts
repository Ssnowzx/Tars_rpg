import { ResourceKey } from '@prisma/client';
import { resourceLabel } from './resource-label';

describe('resourceLabel', () => {
  it('deve retornar o rótulo pt-BR de recursos primários e secundários', () => {
    expect(resourceLabel(ResourceKey.oxygen)).toBe('Oxigênio');
    expect(resourceLabel(ResourceKey.metalore)).toBe('Metal Bruto');
    expect(resourceLabel(ResourceKey.alloys)).toBe('Ligas Metálicas');
  });

  it('deve rotular os recursos raros das luas (§12)', () => {
    expect(resourceLabel(ResourceKey.helium3)).toBe('Cristal de Hélio-3');
    expect(resourceLabel(ResourceKey.fossilPlasma)).toBe('Plasma Fossilizado');
  });

  it('deve cobrir todas as 27 chaves de recurso sem cair no fallback', () => {
    // ARRANGE
    const keys = Object.values(ResourceKey);
    // ACT / ASSERT — nenhum rótulo deve ser igual à própria chave (fallback)
    for (const key of keys) {
      expect(resourceLabel(key)).not.toBe(key);
    }
  });
});
