import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/models/build_queue.dart';
import '../domain/models/world_models.dart' show PlotKind;
import 'api/api_client.dart';
import 'providers.dart';

/// Fila de construção — **autoritativa no backend** (`/build-queue`). Um Timer
/// de 1s anima a contagem regressiva (a partir de `endsAt`); ao concluir uma
/// obra (ou a cada ~5s) refaz o fetch — o backend conclui as obras vencidas e
/// aplica o novo nível — e invalida a Colônia para refletir a mudança.
class BuildQueueController extends Notifier<BuildQueueState> {
  Timer? _timer;
  int _sinceRefetch = 0;

  Dio get _dio => ref.read(dioProvider);
  int get _now => DateTime.now().millisecondsSinceEpoch;

  @override
  BuildQueueState build() {
    ref.onDispose(() {
      _timer?.cancel();
      _timer = null;
    });
    unawaited(refresh());
    return const BuildQueueState(jobs: [], maxSlots: 1, doubleQueue: false);
  }

  Future<void> refresh() async {
    try {
      final res = await _dio.get<Map<String, dynamic>>('/build-queue');
      final data = res.data!;
      final jobs = (data['jobs'] as List<dynamic>).map((e) {
        final j = e as Map<String, dynamic>;
        return QueuedBuild(
          id: j['id'] as String,
          name: j['name'] as String,
          kind: PlotKind.empty,
          fromLevel: (j['fromLevel'] as num?)?.toInt() ?? 0,
          toLevel: (j['toLevel'] as num?)?.toInt() ?? 1,
          totalSeconds: (j['totalSeconds'] as num?)?.toInt() ?? 0,
          endsAtMs: DateTime.parse(j['endsAt'] as String).millisecondsSinceEpoch,
        );
      }).toList();
      final maxSlots = (data['maxSlots'] as num?)?.toInt() ?? 1;
      state = BuildQueueState(jobs: jobs, maxSlots: maxSlots, doubleQueue: maxSlots >= 2);
      _syncTimer();
    } catch (_) {
      // Sem sessão / rede: mantém o estado atual.
    }
  }

  void _syncTimer() {
    if (state.jobs.isNotEmpty && _timer == null) {
      _timer = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
    } else if (state.jobs.isEmpty) {
      _timer?.cancel();
      _timer = null;
    }
  }

  void _tick() {
    final anyDone = state.jobs.any((j) => j.isDone(_now));
    state = state.copyWith(jobs: List.of(state.jobs)); // reemite p/ animar
    _sinceRefetch++;
    if (anyDone || _sinceRefetch >= 5) {
      _sinceRefetch = 0;
      unawaited(refresh());
      ref.invalidate(colonyBaseProvider);
    }
    _syncTimer();
  }

  /// Evolui uma construção (Nv N→N+1). false = fila cheia / erro.
  Future<bool> enqueueUpgrade(String buildingId) =>
      _mutate(() => _dio.post<void>('/colony/buildings/$buildingId/upgrade'));

  /// Constrói uma estrutura no primeiro slot livre.
  Future<bool> enqueueNew({required String kind, required String name, required String category}) =>
      _mutate(() => _dio.post<void>('/colony/build', data: {'kind': kind, 'name': name, 'category': category}));

  Future<bool> _mutate(Future<void> Function() action) async {
    try {
      await action();
      await refresh();
      ref.invalidate(colonyBaseProvider);
      return true;
    } on DioException {
      return false;
    }
  }

  Future<void> cancel(String id) async {
    try {
      await _dio.post<void>('/build-queue/$id/cancel');
    } on DioException {
      // ignora
    }
    await refresh();
    ref.invalidate(colonyBaseProvider);
  }

  Future<void> finishAll() async {
    for (final id in state.jobs.map((j) => j.id).toList()) {
      try {
        await _dio.post<void>('/build-queue/$id/complete');
      } on DioException {
        // ignora
      }
    }
    await refresh();
    ref.invalidate(colonyBaseProvider);
  }
}

final buildQueueProvider =
    NotifierProvider<BuildQueueController, BuildQueueState>(BuildQueueController.new);
