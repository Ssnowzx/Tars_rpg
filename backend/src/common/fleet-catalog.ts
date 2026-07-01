import type { VehicleKind, VehicleStatus } from '@prisma/client';

/// Mapeia o rótulo de tipo usado pelo cliente (frontend `VehicleKind`) para o
/// enum do Prisma. Alguns rótulos do cliente não têm 1:1 no enum de domínio
/// (ex.: fuelTanker) — caem no equivalente mais próximo para persistência.
export function backendKind(kindLabel: string): VehicleKind {
  switch (kindLabel) {
    case 'truck':
      return 'truck';
    case 'drone':
      return 'drone';
    case 'miningRobot':
      return 'miner';
    case 'planetaryTransport':
      return 'planetaryShip';
    case 'freighter':
    case 'fuelTanker':
      return 'freighter';
    case 'longHauler':
      return 'longRange';
    default:
      return 'van';
  }
}

/// Mapeia o rótulo de status do cliente para o enum do Prisma (persistência).
export function backendStatus(statusLabel: string): VehicleStatus {
  switch (statusLabel) {
    case 'inTransit':
      return 'enRoute';
    case 'loading':
      return 'occupied';
    case 'maintenance':
    case 'critical':
      return 'maintenance';
    default:
      return 'idle';
  }
}

/// Capacidade padrão (m³) por tipo — usada ao fabricar veículos de starter.
export function defaultCapacity(kindLabel: string): number {
  switch (kindLabel) {
    case 'truck':
      return 30;
    case 'drone':
      return 1;
    case 'miningRobot':
      return 4;
    case 'planetaryTransport':
      return 120;
    case 'fuelTanker':
      return 80;
    case 'freighter':
      return 500;
    case 'longHauler':
      return 200;
    default:
      return 6; // van
  }
}

/// Descrição de um veículo a fabricar (frota inicial ou seed de demonstração).
export interface VehicleSpec {
  kindLabel: string;
  statusLabel: string;
  plate: string;
  capacityM3: number;
  condition: number;
  activeHours: number;
  maintenanceCost: number;
  assignment: string;
  buildDayLabel: string;
}

/// Frota inicial de um colono novo (§21): um Furgão e um Robô Minerador ociosos.
export function starterFleet(nick: string): VehicleSpec[] {
  const tag = nick.slice(0, 3).toUpperCase().padEnd(3, 'X').replace(/[^A-Z]/g, 'X');
  return [
    {
      kindLabel: 'van',
      statusLabel: 'idle',
      plate: `FRG-${tag}1`,
      capacityM3: 6,
      condition: 100,
      activeHours: 0,
      maintenanceCost: 0,
      assignment: 'Ocioso no hangar',
      buildDayLabel: 'Dia 1',
    },
    {
      kindLabel: 'miningRobot',
      statusLabel: 'idle',
      plate: `RBM-${tag}1`,
      capacityM3: 4,
      condition: 100,
      activeHours: 0,
      maintenanceCost: 0,
      assignment: 'Ocioso',
      buildDayLabel: 'Dia 1',
    },
  ];
}
