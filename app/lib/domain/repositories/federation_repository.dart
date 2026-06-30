import '../models/federation.dart';

/// Costura de repositório da federação do jogador (mock hoje, API depois) — §4.
abstract interface class FederationRepository {
  Future<Federation> loadFederation();
}
