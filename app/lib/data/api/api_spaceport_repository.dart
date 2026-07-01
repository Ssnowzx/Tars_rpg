import 'package:dio/dio.dart';

import '../../domain/models/spaceport.dart';
import '../../domain/repositories/spaceport_repository.dart';

/// Implementação de API: planetas NPC vêm do backend (/spaceport). A frota de
/// cargueiros ainda não tem endpoint — usa um valor padrão.
class ApiSpaceportRepository implements SpaceportRepository {
  ApiSpaceportRepository(this._dio);
  final Dio _dio;

  @override
  Future<SpaceportState> loadSpaceport() async {
    final res = await _dio.get<List<dynamic>>('/spaceport');
    final planets = (res.data ?? const []).map((e) {
      final p = e as Map<String, dynamic>;
      final risk = _riskFrom(p['risk'] as String?);
      return NpcPlanet(
        id: p['key'] as String,
        name: p['name'] as String,
        distance: p['distance'] as String? ?? '',
        risk: risk,
        riskLabel: _riskLabel(risk),
        exports: p['exports'] as String? ?? '',
        imports: p['imports'] as String? ?? '',
      );
    }).toList();
    return SpaceportState(freighters: 2, freightersTotal: 3, planets: planets);
  }
}

RouteRisk _riskFrom(String? s) => switch (s) {
      'low' => RouteRisk.low,
      'high' => RouteRisk.high,
      _ => RouteRisk.none,
    };

String _riskLabel(RouteRisk r) => switch (r) {
      RouteRisk.none => 'Nenhum',
      RouteRisk.low => 'Baixo',
      RouteRisk.high => 'Alto — escolta opcional',
    };
