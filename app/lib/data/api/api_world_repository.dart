import 'package:dio/dio.dart';

import '../../domain/models/colony_buildings.dart';
import '../../domain/models/planet_models.dart';
import '../../domain/models/world_models.dart';
import '../../domain/repositories/world_repository.dart';
import '../mock/mock_world_repository.dart';

/// Implementação de API: a Colônia (slot) e o cabeçalho vêm do backend
/// (/colony + /me). O mapa-planeta ainda não tem endpoint — cai no fixture.
class ApiWorldRepository implements WorldRepository {
  ApiWorldRepository(this._dio, {this.fallback = const MockWorldRepository()});
  final Dio _dio;
  final MockWorldRepository fallback;

  @override
  Future<ColonyBase> loadColonyBase() async {
    final res = await _dio.get<Map<String, dynamic>>('/colony');
    return ColonyBase.fromJson(res.data!);
  }

  @override
  Future<ColonyState> loadColony() async {
    final me = (await _dio.get<Map<String, dynamic>>('/me')).data!;
    final colony = (await _dio.get<Map<String, dynamic>>('/colony')).data!;
    final level = (me['level'] as num?)?.toInt() ?? 1;
    return ColonyState(
      header: ColonyHeader(
        name: colony['name'] as String? ?? 'Colônia',
        sector: colony['sector'] as String? ?? '',
        level: level,
        xp: (me['xp'] as num?)?.toInt() ?? 0,
        xpMax: level * 1000,
      ),
      plots: const [],
      construction: const [],
    );
  }

  @override
  Future<PlanetState> loadPlanet() => fallback.loadPlanet();
}
