import 'package:dio/dio.dart';

import '../../domain/models/combat.dart';
import '../../domain/repositories/combat_repository.dart';

/// Combate territorial (§27) via API (/config).
class ApiCombatRepository implements CombatRepository {
  ApiCombatRepository(this._dio);
  final Dio _dio;

  @override
  Future<CombatState> loadCombat() async {
    final res = await _dio.get<Map<String, dynamic>>('/config/combat');
    return CombatState.fromJson(res.data!);
  }
}
