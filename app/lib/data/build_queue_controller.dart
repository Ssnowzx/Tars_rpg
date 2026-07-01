import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/models/build_queue.dart';
import '../domain/models/world_models.dart' show PlotKind;

/// Fila de construção mutável (§17/§20) — o primeiro estado mutável do app.
/// Um `Timer` de 1s reemite o estado para animar a contagem regressiva e
/// remove obras concluídas. As ações de construir/evoluir (Colônia, Zona)
/// enfileiram aqui em vez de mostrar SnackBar "em breve".
class BuildQueueController extends Notifier<BuildQueueState> {
  Timer? _timer;
  int _seq = 0;

  int get _now => DateTime.now().millisecondsSinceEpoch;

  @override
  BuildQueueState build() {
    ref.onDispose(() {
      _timer?.cancel();
      _timer = null;
    });
    // Semente: uma obra já em andamento para a fila aparecer viva.
    final seed = [
      QueuedBuild(
        id: 'seed-0',
        name: 'Coletor Solar',
        kind: PlotKind.energy,
        fromLevel: 3,
        toLevel: 4,
        totalSeconds: 90,
        endsAtMs: _now + 48000,
      ),
    ];
    final initial = BuildQueueState(jobs: seed, maxSlots: 2, doubleQueue: true);
    _syncTimer(initial);
    return initial;
  }

  void _syncTimer(BuildQueueState s) {
    if (s.jobs.isNotEmpty && _timer == null) {
      _timer = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
    } else if (s.jobs.isEmpty) {
      _timer?.cancel();
      _timer = null;
    }
  }

  void _tick() {
    final now = _now;
    final alive = state.jobs.where((j) => !j.isDone(now)).toList();
    // Reemite sempre (nova lista) para atualizar a contagem, mesmo sem conclusão.
    state = state.copyWith(jobs: alive);
    _syncTimer(state);
  }

  /// Enfileira uma obra. Retorna false se a fila está cheia.
  bool enqueue({
    required String name,
    required PlotKind kind,
    required int fromLevel,
    required int toLevel,
    required int seconds,
  }) {
    if (state.isFull) return false;
    final job = QueuedBuild(
      id: 'job-${_seq++}',
      name: name,
      kind: kind,
      fromLevel: fromLevel,
      toLevel: toLevel,
      totalSeconds: seconds,
      endsAtMs: _now + seconds * 1000,
    );
    state = state.copyWith(jobs: [...state.jobs, job]);
    _syncTimer(state);
    return true;
  }

  void cancel(String id) {
    state = state.copyWith(jobs: state.jobs.where((j) => j.id != id).toList());
    _syncTimer(state);
  }

  /// Conclui instantaneamente todas as obras (mock — sem custo de aceleração).
  void finishAll() {
    state = state.copyWith(jobs: const []);
    _syncTimer(state);
  }
}

final buildQueueProvider =
    NotifierProvider<BuildQueueController, BuildQueueState>(BuildQueueController.new);
