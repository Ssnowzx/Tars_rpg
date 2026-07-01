import '../models/auction.dart';

/// Costura da Casa de Leilões (API real) — §13.
abstract interface class AuctionRepository {
  Future<AuctionHouse> loadAuctions();

  /// Registra um lance num lote (gate Nível 100, §13).
  Future<void> placeBid(String auctionId, int amount);
}
