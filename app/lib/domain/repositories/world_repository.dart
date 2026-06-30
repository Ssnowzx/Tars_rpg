import '../models/colony_buildings.dart';
import '../models/planet_models.dart';
import '../models/world_models.dart';

/// Costura de repositório do mapa-mundo (mock hoje, API depois).
abstract interface class WorldRepository {
  /// Status da colônia do jogador (cabeçalho/HUD: nome, nível, XP).
  Future<ColonyState> loadColony();

  /// Mapa-planeta: Capital, colônias vizinhas, zonas neutras, espaçoporto, marcos.
  Future<PlanetState> loadPlanet();

  /// Slot do colono: construções de produção/estrutura + slots livres (v21 §17).
  Future<ColonyBase> loadColonyBase();
}
