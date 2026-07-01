import '../models/fleet.dart';

/// Costura da frota do colono (API por jogador) — §16/§21.
abstract interface class FleetRepository {
  Future<FleetBoard> loadFleet();

  /// Faz manutenção do veículo (§16.4): cobra o custo e restaura a condição.
  Future<void> maintain(String vehicleId);

  /// Sucateia o veículo, liberando a vaga do hangar.
  Future<void> scrap(String vehicleId);
}
