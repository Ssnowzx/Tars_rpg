import 'package:flutter/foundation.dart';

import 'world_models.dart';

/// Parser público de [PlotKind] para os lotes da colônia.
PlotKind colonyKindFrom(String s) => switch (s) {
      'water' => PlotKind.water,
      'metals' => PlotKind.metals,
      'biomass' => PlotKind.biomass,
      'energy' => PlotKind.energy,
      'factory' => PlotKind.factory,
      'capital' => PlotKind.capital,
      _ => PlotKind.empty,
    };

/// Um lote de produção da colônia (nível "Colônia": entre Planeta e Capital).
/// Produz um dos 5 recursos do HUD; lotes vazios são expansão claimável.
@immutable
class ColonyLot {
  const ColonyLot({
    required this.id,
    required this.name,
    required this.kind,
    required this.level,
    required this.dx,
    required this.dy,
    this.perHour = 0,
    this.built = true,
  });

  final String id;
  final String name;
  final PlotKind kind;
  final int level;
  final double dx;
  final double dy;
  final int perHour; // produção líquida do lote por hora
  final bool built;

  bool get isFree => !built || kind == PlotKind.empty;
  bool get isCapital => kind == PlotKind.capital;

  factory ColonyLot.fromJson(Map<String, dynamic> j) => ColonyLot(
        id: j['id'] as String,
        name: j['name'] as String,
        kind: colonyKindFrom(j['kind'] as String? ?? 'empty'),
        level: j['level'] as int? ?? 0,
        dx: (j['dx'] as num).toDouble(),
        dy: (j['dy'] as num).toDouble(),
        perHour: j['perHour'] as int? ?? 0,
        built: j['built'] as bool? ?? true,
      );
}

/// Layout completo da colônia (mock).
@immutable
class ColonyLayout {
  const ColonyLayout({required this.name, required this.lots});

  final String name;
  final List<ColonyLot> lots;

  int get builtCount => lots.where((l) => l.built && !l.isCapital).length;
  int get freeCount => lots.where((l) => l.isFree).length;

  factory ColonyLayout.fromJson(Map<String, dynamic> j) => ColonyLayout(
        name: j['name'] as String? ?? 'Colônia',
        lots: (j['lots'] as List<dynamic>? ?? const [])
            .map((e) => ColonyLot.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}
