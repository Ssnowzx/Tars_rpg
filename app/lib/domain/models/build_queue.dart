import 'dart:math' as math;

import 'package:flutter/foundation.dart';

import 'world_models.dart' show PlotKind;

/// Tempo estimado de obra (segundos) para alcançar [toLevel], curva 1.5×
/// (GDD §20). Valores curtos e demonstráveis para o mock; a planilha de
/// balanceamento define os tempos reais por construção.
int buildSeconds(int toLevel) {
  const base = 30;
  final n = (toLevel - 1).clamp(0, 8);
  return (base * math.pow(1.5, n)).round().clamp(base, 240);
}

/// Uma obra na fila de construção (mutável, §17/§20). O tempo restante e o
/// progresso são derivados do relógio a cada tick — não são valores fixos.
@immutable
class QueuedBuild {
  const QueuedBuild({
    required this.id,
    required this.name,
    required this.kind,
    required this.fromLevel,
    required this.toLevel,
    required this.totalSeconds,
    required this.endsAtMs,
  });

  final String id;
  final String name;
  final PlotKind kind;
  final int fromLevel;
  final int toLevel;
  final int totalSeconds;

  /// Epoch (ms) em que a obra conclui.
  final int endsAtMs;

  int remainingSeconds(int nowMs) => ((endsAtMs - nowMs) / 1000).ceil().clamp(0, totalSeconds);

  double progress(int nowMs) {
    if (totalSeconds <= 0) return 1;
    final elapsed = totalSeconds - remainingSeconds(nowMs);
    return (elapsed / totalSeconds).clamp(0.0, 1.0);
  }

  bool isDone(int nowMs) => nowMs >= endsAtMs;

  String remainingLabel(int nowMs) {
    final s = remainingSeconds(nowMs);
    final m = s ~/ 60;
    final sec = s % 60;
    return '${m.toString().padLeft(2, '0')}:${sec.toString().padLeft(2, '0')}';
  }
}

/// Estado da fila de construção. Fila dupla (2 vagas) nos primeiros 5 dias de
/// conta (§03/§20.2); depois, fila única.
@immutable
class BuildQueueState {
  const BuildQueueState({
    required this.jobs,
    required this.maxSlots,
    required this.doubleQueue,
  });

  final List<QueuedBuild> jobs;
  final int maxSlots;
  final bool doubleQueue;

  bool get isFull => jobs.length >= maxSlots;

  BuildQueueState copyWith({List<QueuedBuild>? jobs}) => BuildQueueState(
        jobs: jobs ?? this.jobs,
        maxSlots: maxSlots,
        doubleQueue: doubleQueue,
      );
}
