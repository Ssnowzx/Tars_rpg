import '../models/player_profile.dart';

/// Costura de repositório do Perfil (mock hoje, API depois).
abstract interface class ProfileRepository {
  Future<PlayerProfile> loadProfile();
}
