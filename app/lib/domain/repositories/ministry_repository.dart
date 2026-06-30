import '../models/ministry.dart';

/// Costura de repositório dos Ministérios da Capital (mock hoje, API depois).
abstract interface class MinistryRepository {
  Future<MinistriesData> loadMinistries();
}
