import '../models/fleet.dart';

/// Costura da frota do colono (mock hoje, API depois) — §16/§21.
abstract interface class FleetRepository {
  Future<FleetBoard> loadFleet();
}
