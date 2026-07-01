import '../models/lunar.dart';

/// Costura da Exploração Lunar / Telescópio Gagarin (§12) — mock hoje, API
/// depois. Troque só o binding em `data/providers.dart`.
abstract interface class LunarRepository {
  Future<LunarExploration> loadLunar();
}
