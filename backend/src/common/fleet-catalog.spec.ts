import { backendKind, backendStatus, defaultCapacity, starterFleet } from './fleet-catalog';

describe('fleet-catalog', () => {
  describe('backendKind', () => {
    it('deve mapear rótulos do cliente para o enum do Prisma', () => {
      // ARRANGE / ACT / ASSERT
      expect(backendKind('truck')).toBe('truck');
      expect(backendKind('miningRobot')).toBe('miner');
      expect(backendKind('planetaryTransport')).toBe('planetaryShip');
      expect(backendKind('longHauler')).toBe('longRange');
    });

    it('deve cair no equivalente mais próximo quando não há 1:1 (fuelTanker → freighter)', () => {
      expect(backendKind('fuelTanker')).toBe('freighter');
    });

    it('deve usar "van" como padrão para rótulos desconhecidos', () => {
      expect(backendKind('desconhecido')).toBe('van');
    });
  });

  describe('backendStatus', () => {
    it('deve mapear os status de exibição para o enum do Prisma', () => {
      expect(backendStatus('inTransit')).toBe('enRoute');
      expect(backendStatus('loading')).toBe('occupied');
      expect(backendStatus('critical')).toBe('maintenance');
      expect(backendStatus('idle')).toBe('idle');
    });
  });

  describe('defaultCapacity', () => {
    it('deve retornar a capacidade padrão por tipo', () => {
      expect(defaultCapacity('van')).toBe(6);
      expect(defaultCapacity('truck')).toBe(30);
      expect(defaultCapacity('freighter')).toBe(500);
    });
  });

  describe('starterFleet', () => {
    it('deve dar a um colono novo um Furgão e um Robô Minerador ociosos', () => {
      // ACT
      const fleet = starterFleet('Vale');

      // ASSERT
      expect(fleet).toHaveLength(2);
      expect(fleet.map((v) => v.kindLabel)).toEqual(['van', 'miningRobot']);
      expect(fleet.every((v) => v.statusLabel === 'idle')).toBe(true);
      expect(fleet.every((v) => v.condition === 100)).toBe(true);
    });

    it('deve gerar placas com o prefixo do nickname sanitizado', () => {
      const fleet = starterFleet('Ana');
      expect(fleet[0].plate).toBe('FRG-ANA1');
      expect(fleet[1].plate).toBe('RBM-ANA1');
    });
  });
});
