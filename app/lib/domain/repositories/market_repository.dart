import '../models/informal_trade.dart';
import '../models/market.dart';

/// Costura de repositório do Mercado Central (API real de escrow/livro-razão).
/// Cobre o Mercado Central (§13) e o Comércio Informal entre colonos (§8).
abstract interface class MarketRepository {
  Future<MarketBoard> loadBoard();
  Future<InformalBoard> loadInformalBoard();

  /// Compra uma quantidade de um anúncio aberto (§13). Transfere recurso +
  /// Fert$ com taxa, tudo no servidor. Devolve o resumo do fechamento.
  Future<MarketTradeResult> buyOrder(String listingId, int quantity);

  /// Cria um anúncio de venda com escrow (reserva o recurso do vendedor, §13).
  Future<void> createListing({
    required String resourceKey,
    required int quantity,
    required double unitPrice,
  });
}

/// Resumo do fechamento de uma compra no Mercado Central.
class MarketTradeResult {
  const MarketTradeResult({required this.total, required this.tax, required this.remaining});
  final double total;
  final double tax;
  final int remaining;
}
