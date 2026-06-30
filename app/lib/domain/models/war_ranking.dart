import 'package:flutter/foundation.dart';

/// Uma linha de ranking (jogador ou federação).
@immutable
class RankingEntry {
  const RankingEntry({
    required this.rank,
    required this.name,
    required this.value,
    this.percentile,
    this.isYou = false,
    this.federation = false,
  });

  final int rank;
  final String name;
  final String value; // já formatado (raw nos subs; score 0–100 no geral)
  final double? percentile; // percentil 0–100 no servidor (§27.13)
  final bool isYou;
  final bool federation;

  factory RankingEntry.fromJson(Map<String, dynamic> j) => RankingEntry(
        rank: j['rank'] as int,
        name: j['name'] as String,
        value: j['value'].toString(),
        percentile: (j['percentile'] as num?)?.toDouble(),
        isYou: j['isYou'] as bool? ?? false,
        federation: j['federation'] as bool? ?? false,
      );
}

/// Um dos 6 sub-rankings (GDD §15.2).
@immutable
class SubRanking {
  const SubRanking({
    required this.id,
    required this.name,
    required this.measures,
    required this.scope,
    required this.entries,
  });

  final String id;
  final String name;
  final String measures;
  final String scope; // "Individual + Federação" / "Somente Federação"
  final List<RankingEntry> entries;

  factory SubRanking.fromJson(Map<String, dynamic> j) => SubRanking(
        id: j['id'] as String,
        name: j['name'] as String,
        measures: j['measures'] as String? ?? '',
        scope: j['scope'] as String? ?? '',
        entries: (j['entries'] as List<dynamic>? ?? const [])
            .map((e) => RankingEntry.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}

/// Peso de uma métrica no Ranking Geral (GDD §15.3).
@immutable
class GeneralWeight {
  const GeneralWeight({required this.metric, required this.weight});
  final String metric;
  final int weight; // %

  factory GeneralWeight.fromJson(Map<String, dynamic> j) =>
      GeneralWeight(metric: j['metric'] as String, weight: j['weight'] as int);
}

/// Ranking de Guerras completo (GDD §15) — mock.
@immutable
class WarRankings {
  const WarRankings({required this.weights, required this.general, required this.subs});

  final List<GeneralWeight> weights;
  final List<RankingEntry> general;
  final List<SubRanking> subs;

  factory WarRankings.fromJson(Map<String, dynamic> j) => WarRankings(
        weights: (j['weights'] as List<dynamic>? ?? const [])
            .map((e) => GeneralWeight.fromJson(e as Map<String, dynamic>))
            .toList(),
        general: (j['general'] as List<dynamic>? ?? const [])
            .map((e) => RankingEntry.fromJson(e as Map<String, dynamic>))
            .toList(),
        subs: (j['subs'] as List<dynamic>? ?? const [])
            .map((e) => SubRanking.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}
