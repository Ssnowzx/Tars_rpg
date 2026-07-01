import 'package:dio/dio.dart';

import '../../domain/models/fleet.dart';
import '../../domain/repositories/fleet_repository.dart';

/// Frota do colono (§16/§21) via API (/config).
class ApiFleetRepository implements FleetRepository {
  ApiFleetRepository(this._dio);
  final Dio _dio;

  @override
  Future<FleetBoard> loadFleet() async {
    final res = await _dio.get<Map<String, dynamic>>('/config/fleet');
    return FleetBoard.fromJson(res.data!);
  }
}
