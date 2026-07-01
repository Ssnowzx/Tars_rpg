import 'package:flutter/foundation.dart';

/// Tipos de veículo da frota do colono (GDD v29 §21). Furgão e Caminhão sofrem
/// depreciação por horas de uso (§16.4); os demais não.
enum VehicleKind {
  van, // Furgão (6 m³)
  truck, // Caminhão de Carga (30 m³)
  drone,
  longHauler, // Nave de Longa Distância
  miningRobot, // Robô Minerador (ciclo)
  planetaryTransport, // Nave de Transporte Planetária
  fuelTanker, // Tanque de Combustível
  freighter, // Cargueiro Interplanetário
}

VehicleKind _kindFrom(String? s) => switch (s) {
      'truck' => VehicleKind.truck,
      'drone' => VehicleKind.drone,
      'longHauler' => VehicleKind.longHauler,
      'miningRobot' => VehicleKind.miningRobot,
      'planetaryTransport' => VehicleKind.planetaryTransport,
      'fuelTanker' => VehicleKind.fuelTanker,
      'freighter' => VehicleKind.freighter,
      _ => VehicleKind.van,
    };

/// Situação operacional do veículo. `critical` = abaixo do limite crítico de
/// condição → bloqueado até manutenção (§16.4).
enum VehicleStatus { idle, inTransit, loading, maintenance, critical }

VehicleStatus _statusFrom(String? s) => switch (s) {
      'inTransit' => VehicleStatus.inTransit,
      'loading' => VehicleStatus.loading,
      'maintenance' => VehicleStatus.maintenance,
      'critical' => VehicleStatus.critical,
      _ => VehicleStatus.idle,
    };

/// Um veículo da frota (§21). `condition` 0–100; `activeHours` alimenta a
/// depreciação (§16.4); `assignment` descreve a tarefa atual.
@immutable
class Vehicle {
  const Vehicle({
    required this.id,
    required this.plate,
    required this.kind,
    required this.capacityM3,
    required this.condition,
    required this.activeHours,
    required this.status,
    required this.assignment,
    required this.maintenanceCost,
    required this.buildDay,
    this.criticalThreshold = 20,
  });

  final String id;
  final String plate;
  final VehicleKind kind;
  final int capacityM3;
  final int condition; // %
  final int activeHours;
  final VehicleStatus status;
  final String assignment;
  final int maintenanceCost; // Fert$
  final String buildDay;
  final int criticalThreshold; // % abaixo do qual bloqueia (§16.4)

  /// Só Furgão e Caminhão depreciam por horas de uso (§16.4).
  bool get depreciates => kind == VehicleKind.van || kind == VehicleKind.truck;

  bool get isBlocked => status == VehicleStatus.critical;
  bool get needsMaintenance =>
      status == VehicleStatus.maintenance ||
      status == VehicleStatus.critical ||
      (depreciates && condition <= criticalThreshold + 15);

  factory Vehicle.fromJson(Map<String, dynamic> j) => Vehicle(
        id: j['id'] as String,
        plate: j['plate'] as String? ?? '',
        kind: _kindFrom(j['kind'] as String?),
        capacityM3: (j['capacityM3'] as num?)?.toInt() ?? 0,
        condition: (j['condition'] as num?)?.toInt() ?? 100,
        activeHours: (j['activeHours'] as num?)?.toInt() ?? 0,
        status: _statusFrom(j['status'] as String?),
        assignment: j['assignment'] as String? ?? '',
        maintenanceCost: (j['maintenanceCost'] as num?)?.toInt() ?? 0,
        buildDay: j['buildDay'] as String? ?? '',
        criticalThreshold: (j['criticalThreshold'] as num?)?.toInt() ?? 20,
      );
}

/// Estado da frota do colono (mock, §21). `garageUsed`/`garageCapacity` =
/// ocupação do hangar; os getters resumem o status operacional.
@immutable
class FleetBoard {
  const FleetBoard({
    required this.garageUsed,
    required this.garageCapacity,
    required this.vehicles,
  });

  final int garageUsed;
  final int garageCapacity;
  final List<Vehicle> vehicles;

  int get inTransit => vehicles.where((v) => v.status == VehicleStatus.inTransit).length;
  int get needsMaintenance => vehicles.where((v) => v.needsMaintenance).length;
  int get totalCapacity =>
      vehicles.fold(0, (sum, v) => sum + v.capacityM3);

  factory FleetBoard.fromJson(Map<String, dynamic> j) => FleetBoard(
        garageUsed: (j['garageUsed'] as num?)?.toInt() ?? 0,
        garageCapacity: (j['garageCapacity'] as num?)?.toInt() ?? 0,
        vehicles: (j['vehicles'] as List<dynamic>? ?? const [])
            .map((e) => Vehicle.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}
