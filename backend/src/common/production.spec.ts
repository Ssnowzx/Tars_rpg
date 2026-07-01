import { ResourceKey } from '@prisma/client';
import { baseProduction, buildCost, buildingResource, nextProduction } from './production';

describe('production', () => {
  describe('buildingResource', () => {
    it('deve mapear categorias produtivas para o recurso', () => {
      expect(buildingResource('oxygen')).toBe(ResourceKey.oxygen);
      expect(buildingResource('rawmetal')).toBe(ResourceKey.metalore);
      expect(buildingResource('metals')).toBe(ResourceKey.alloys);
      expect(buildingResource('components')).toBe(ResourceKey.componentBasic);
    });

    it('deve retornar null para categorias sem produção', () => {
      expect(buildingResource('habitat')).toBeNull();
      expect(buildingResource('military')).toBeNull();
      expect(buildingResource('empty')).toBeNull();
    });
  });

  describe('nextProduction', () => {
    it('deve aplicar a curva 1.5× ao evoluir', () => {
      expect(nextProduction(54)).toBe(81);
      expect(nextProduction(88)).toBe(132);
    });
  });

  describe('baseProduction', () => {
    it('deve dar a produção-base do nível 1 por categoria', () => {
      expect(baseProduction('water')).toBe(25);
      expect(baseProduction('energy')).toBe(18);
      expect(baseProduction('habitat')).toBe(0);
    });
  });

  describe('buildCost', () => {
    it('deve custar Metal Bruto + Energia escalando 1.5× por nível', () => {
      // ARRANGE / ACT
      const lvl1 = buildCost('water', 1);
      const lvl4 = buildCost('oxygen', 4);
      // ASSERT
      expect(lvl1[ResourceKey.metalore]).toBe(25);
      expect(lvl1[ResourceKey.energy]).toBe(12);
      expect(lvl4[ResourceKey.metalore]).toBe(84); // 25 × 1.5³
    });

    it('não deve custar nada para habitat / slot vazio', () => {
      expect(buildCost('habitat', 2)).toEqual({});
      expect(buildCost('empty', 1)).toEqual({});
    });
  });
});
