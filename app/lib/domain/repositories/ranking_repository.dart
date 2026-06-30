import '../models/war_ranking.dart';

/// Costura de repositório do Ranking de Guerras (mock hoje, API depois).
abstract interface class RankingRepository {
  Future<WarRankings> loadWarRankings();
}
