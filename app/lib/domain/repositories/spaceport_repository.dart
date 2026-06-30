import '../models/spaceport.dart';

/// Costura de repositório do Espaçoporto (mock hoje, API depois).
abstract interface class SpaceportRepository {
  Future<SpaceportState> loadSpaceport();
}
