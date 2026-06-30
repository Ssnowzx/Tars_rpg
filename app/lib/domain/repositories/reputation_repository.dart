import '../models/dispute.dart';

/// Costura do Ministério das Reputações / Justiça (mock hoje, API depois) — §9.
abstract interface class ReputationRepository {
  Future<DisputeBoard> loadDisputes();
}
