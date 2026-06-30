import '../models/combat.dart';

/// Costura de repositório do combate territorial (mock hoje, API depois) — §27.
abstract interface class CombatRepository {
  Future<CombatState> loadCombat();
}
