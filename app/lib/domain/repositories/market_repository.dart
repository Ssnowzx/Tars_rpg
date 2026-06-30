import '../models/informal_trade.dart';
import '../models/market.dart';

/// Costura de repositório do Mercado Central (mock hoje, API depois). Cobre o
/// Mercado Central (§13) e o Comércio Informal entre colonos (§8).
abstract interface class MarketRepository {
  Future<MarketBoard> loadBoard();
  Future<InformalBoard> loadInformalBoard();
}
