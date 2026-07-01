import 'package:dio/dio.dart';

import '../../domain/models/fleet.dart';
import '../../domain/repositories/fleet_repository.dart';

/// Frota do colono (§16/§21) via API — registros `Vehicle` por jogador.
class ApiFleetRepository implements FleetRepository {
  ApiFleetRepository(this._dio);
  final Dio _dio;

  @override
  Future<FleetBoard> loadFleet() async {
    final res = await _dio.get<Map<String, dynamic>>('/fleet');
    return FleetBoard.fromJson(res.data!);
  }

  @override
  Future<void> maintain(String vehicleId) async {
    await _dio.post<Map<String, dynamic>>('/fleet/$vehicleId/maintain');
  }

  @override
  Future<void> scrap(String vehicleId) async {
    await _dio.post<Map<String, dynamic>>('/fleet/$vehicleId/scrap');
  }
}
