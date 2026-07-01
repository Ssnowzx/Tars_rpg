import '../models/mission.dart';

/// Costura da central de Missões/Conquistas/Eventos (API por jogador) — §6.
abstract interface class MissionRepository {
  Future<MissionBoard> loadBoard();

  /// Resgata a recompensa de uma missão concluída (credita Fert$ no servidor).
  Future<void> claim(String missionId);
}
