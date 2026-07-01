import 'package:dio/dio.dart';

import '../../domain/models/mission.dart';
import '../../domain/repositories/mission_repository.dart';

/// Central de Missões/Conquistas/Eventos (§6) via API (/config).
class ApiMissionRepository implements MissionRepository {
  ApiMissionRepository(this._dio);
  final Dio _dio;

  @override
  Future<MissionBoard> loadBoard() async {
    final res = await _dio.get<Map<String, dynamic>>('/config/missionsBoard');
    return MissionBoard.fromJson(res.data!);
  }
}
