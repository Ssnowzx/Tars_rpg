import 'package:dio/dio.dart';

import '../../domain/models/mission.dart';
import '../../domain/repositories/mission_repository.dart';

/// Central de Missões/Conquistas/Eventos (§6) via API — board por jogador.
class ApiMissionRepository implements MissionRepository {
  ApiMissionRepository(this._dio);
  final Dio _dio;

  @override
  Future<MissionBoard> loadBoard() async {
    final res = await _dio.get<Map<String, dynamic>>('/missions/board');
    return MissionBoard.fromJson(res.data!);
  }

  @override
  Future<void> claim(String missionId) async {
    await _dio.post<Map<String, dynamic>>('/missions/$missionId/claim');
  }
}
