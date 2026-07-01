import 'package:dio/dio.dart';

import '../../domain/models/war_ranking.dart';
import '../../domain/repositories/ranking_repository.dart';

/// Ranking de Guerras via API (/config).
class ApiRankingRepository implements RankingRepository {
  ApiRankingRepository(this._dio);
  final Dio _dio;

  @override
  Future<WarRankings> loadWarRankings() async {
    final res = await _dio.get<Map<String, dynamic>>('/config/rankings');
    return WarRankings.fromJson(res.data!);
  }
}
