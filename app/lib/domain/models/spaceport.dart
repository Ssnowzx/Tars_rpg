import 'package:flutter/foundation.dart';

/// Nível de risco da rota a um planeta NPC (cor/ícone).
enum RouteRisk { none, low, high }

RouteRisk _riskFrom(String? s) => switch (s) {
      'low' => RouteRisk.low,
      'high' => RouteRisk.high,
      _ => RouteRisk.none,
    };

/// Planeta NPC do Espaçoporto (GDD §3).
@immutable
class NpcPlanet {
  const NpcPlanet({
    required this.id,
    required this.name,
    required this.distance,
    required this.risk,
    required this.riskLabel,
    required this.exports,
    required this.imports,
  });

  final String id;
  final String name;
  final String distance; // ex.: "~4h"
  final RouteRisk risk;
  final String riskLabel; // ex.: "Nenhum", "Alto — escolta opcional"
  final String exports;
  final String imports;

  factory NpcPlanet.fromJson(Map<String, dynamic> j) => NpcPlanet(
        id: j['id'] as String,
        name: j['name'] as String,
        distance: j['distance'] as String? ?? '',
        risk: _riskFrom(j['risk'] as String?),
        riskLabel: j['riskLabel'] as String? ?? 'Nenhum',
        exports: j['exports'] as String? ?? '',
        imports: j['imports'] as String? ?? '',
      );
}

/// Estado do Espaçoporto (mock).
@immutable
class SpaceportState {
  const SpaceportState({
    required this.freighters,
    required this.freightersTotal,
    required this.planets,
  });

  final int freighters; // Cargueiros Interplanetários disponíveis
  final int freightersTotal;
  final List<NpcPlanet> planets;

  factory SpaceportState.fromJson(Map<String, dynamic> j) => SpaceportState(
        freighters: j['freighters'] as int? ?? 0,
        freightersTotal: j['freightersTotal'] as int? ?? 0,
        planets: (j['planets'] as List<dynamic>? ?? const [])
            .map((e) => NpcPlanet.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}
