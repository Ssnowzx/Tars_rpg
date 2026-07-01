import '../models/auction.dart';

/// Costura da Casa de Leilões (mock hoje, API depois) — §13.
abstract interface class AuctionRepository {
  Future<AuctionHouse> loadAuctions();
}
