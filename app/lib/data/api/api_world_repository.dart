import 'package:dio/dio.dart';

import '../../domain/models/colony_buildings.dart';
import '../../domain/models/planet_models.dart';
import '../../domain/models/world_models.dart';
import '../../domain/repositories/world_repository.dart';

/// Implementação de API: a Colônia (slot) e o cabeçalho vêm de /colony + /me;
/// o mapa-planeta (config canônica) vem de /config/planet.
class ApiWorldRepository implements WorldRepository {
  ApiWorldRepository(this._dio);
  final Dio _dio;

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
  Future<PlanetState> loadPlanet() async {
    final res = await _dio.get<Map<String, dynamic>>('/config/planet');
    return PlanetState.fromJson(res.data!);
  }
}
