import '../models/mission.dart';

/// Costura da central de Missões/Conquistas/Eventos (mock hoje, API depois) — §6.
abstract interface class MissionRepository {
  Future<MissionBoard> loadBoard();
}
