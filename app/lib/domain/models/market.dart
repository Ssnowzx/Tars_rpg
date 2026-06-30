import 'package:flutter/foundation.dart';

/// Lado da ordem no Mercado Central.
enum MarketSide { buy, sell }

MarketSide _sideFrom(String s) => s == 'buy' ? MarketSide.buy : MarketSide.sell;

/// Uma ordem de compra/venda de recurso (GDD §13). Mostra sinais de confiança
/// do vendedor (avaliação 0–5, GDD §8) no ponto da transação.
@immutable
class MarketOrder {
  const MarketOrder({
    required this.id,
    required this.side,
    required this.resourceId,
    required this.resourceLabel,
    required this.quantity,
    required this.unitPrice,
    required this.trader,
    required this.traderSector,
    required this.traderRating,
  });

  final String id;
  final MarketSide side;
  final String resourceId; // oxygen/water/biomass/energy/alloys/chemicals/electronics
  final String resourceLabel;
  final int quantity;
  final double unitPrice; // Fert$ por unidade (§22, frações)
  final String trader;
  final String traderSector;
  final double traderRating; // 0–5

  double get total => quantity * unitPrice;

  /// Sinal de risco de calote (reputação baixa).
  bool get risky => traderRating < 3.5;

  factory MarketOrder.fromJson(Map<String, dynamic> j) => MarketOrder(
        id: j['id'] as String,
        side: _sideFrom(j['side'] as String? ?? 'sell'),
        resourceId: j['resourceId'] as String,
        resourceLabel: j['resourceLabel'] as String,
        quantity: j['quantity'] as int,
        unitPrice: (j['unitPrice'] as num).toDouble(),
        trader: j['trader'] as String,
        traderSector: j['traderSector'] as String? ?? '',
        traderRating: ((j['traderRating'] as num?)?.toDouble() ?? 5).clamp(0, 5).toDouble(),
      );
}

/// Resumo de preço de um recurso (mini data-viz).
@immutable
class MarketTicker {
  const MarketTicker({
    required this.resourceId,
    required this.resourceLabel,
    required this.lastPrice,
    required this.changePct,
  });

  final String resourceId;
  final String resourceLabel;
  final double lastPrice;
  final double changePct; // variação %

  factory MarketTicker.fromJson(Map<String, dynamic> j) => MarketTicker(
        resourceId: j['resourceId'] as String,
        resourceLabel: j['resourceLabel'] as String,
        lastPrice: (j['lastPrice'] as num).toDouble(),
        changePct: (j['changePct'] as num?)?.toDouble() ?? 0,
      );
}

/// Estado do Mercado Central (mock).
@immutable
class MarketBoard {
  const MarketBoard({required this.tickers, required this.orders});

  final List<MarketTicker> tickers;
  final List<MarketOrder> orders;

  factory MarketBoard.fromJson(Map<String, dynamic> j) => MarketBoard(
        tickers: (j['tickers'] as List<dynamic>? ?? const [])
            .map((e) => MarketTicker.fromJson(e as Map<String, dynamic>))
            .toList(),
        orders: (j['orders'] as List<dynamic>? ?? const [])
            .map((e) => MarketOrder.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}
