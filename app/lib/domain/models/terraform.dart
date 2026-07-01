import 'package:flutter/foundation.dart';

/// Os três indicadores públicos da terraformação global (§04 / §12.3).
enum TerraformIndicator { atmosphere, water, biosphere }

TerraformIndicator _indicatorFrom(String? s) => switch (s) {
      'water' => TerraformIndicator.water,
      'biosphere' => TerraformIndicator.biosphere,
      _ => TerraformIndicator.atmosphere,
    };

/// Um indicador coletivo (atmosfera / ciclo hídrico / biosfera) e seu progresso
/// rumo ao marco de 75% (§12.3).
@immutable
class TerraformTrack {
  const TerraformTrack({
    required this.kind,
    required this.label,
    required this.percent,
    required this.perDay,
    required this.note,
  });

  final TerraformIndicator kind;
  final String label;

  /// Progresso público do indicador (0–100).
  final int percent;

  /// Tendência: avanço médio por dia do servidor.
  final int perDay;
  final String note;

  factory TerraformTrack.fromJson(Map<String, dynamic> j) => TerraformTrack(
        kind: _indicatorFrom(j['kind'] as String?),
        label: j['label'] as String? ?? '',
        percent: j['percent'] as int? ?? 0,
        perDay: j['perDay'] as int? ?? 0,
        note: j['note'] as String? ?? '',
      );
}

/// Estado da Terraformação Global (§04 + §12.3): objetivo coletivo da temporada.
/// Os três indicadores públicos avançam por contribuição; ao alcançarem 75%,
/// inicia-se a campanha lunar (gatilho da Temporada 2). Contribuir só concede
/// Status Cívico e cosméticos — nunca vantagem econômica ou competitiva.
@immutable
class TerraformState {
  const TerraformState({
    required this.tracks,
    required this.triggerPercent,
    required this.dailyContributed,
    required this.dailyCap,
    required this.totalContributed,
    required this.civicStatusGain,
    required this.contributorTopPct,
    required this.orbitWindowActive,
  });

  final List<TerraformTrack> tracks;
  final int triggerPercent;

  /// Sua contribuição de hoje e o teto diário anti-farming (§04).
  final int dailyContributed;
  final int dailyCap;

  /// Sua contribuição acumulada e o Status Cívico ganho por contribuição.
  final int totalContributed;
  final int civicStatusGain;

  /// Você está entre os top N% que mais contribuíram (conquista §6).
  final int contributorTopPct;

  /// Evento "Janela de Órbita Lunar" ativo (§12.3).
  final bool orbitWindowActive;

  /// O gatilho exige os TRÊS indicadores em 75% — o menor determina o progresso.
  int get lowestPercent =>
      tracks.isEmpty ? 0 : tracks.map((t) => t.percent).reduce((a, b) => a < b ? a : b);

  double get overallFraction =>
      triggerPercent == 0 ? 0.0 : (lowestPercent / triggerPercent).clamp(0.0, 1.0);

  bool get season2Unlocked => tracks.isNotEmpty && tracks.every((t) => t.percent >= triggerPercent);

  double get dailyFraction => dailyCap == 0 ? 0.0 : (dailyContributed / dailyCap).clamp(0.0, 1.0);

  bool get dailyCapReached => dailyContributed >= dailyCap;

  double trackFraction(TerraformTrack t) =>
      triggerPercent == 0 ? 0.0 : (t.percent / triggerPercent).clamp(0.0, 1.0);

  factory TerraformState.fromJson(Map<String, dynamic> j) => TerraformState(
        tracks: (j['tracks'] as List<dynamic>? ?? const [])
            .map((e) => TerraformTrack.fromJson(e as Map<String, dynamic>))
            .toList(),
        triggerPercent: j['triggerPercent'] as int? ?? 75,
        dailyContributed: j['dailyContributed'] as int? ?? 0,
        dailyCap: j['dailyCap'] as int? ?? 0,
        totalContributed: j['totalContributed'] as int? ?? 0,
        civicStatusGain: j['civicStatusGain'] as int? ?? 0,
        contributorTopPct: j['contributorTopPct'] as int? ?? 0,
        orbitWindowActive: j['orbitWindowActive'] as bool? ?? false,
      );
}
