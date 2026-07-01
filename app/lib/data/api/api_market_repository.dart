import 'package:dio/dio.dart';

import '../../domain/models/informal_trade.dart';
import '../../domain/models/market.dart';
import '../../domain/repositories/market_repository.dart';

/// Mercado Central (§13) via API real (ordens de escrow + livro-razão Fert$) e
/// Comércio Informal (§8) via config canônica.
class ApiMarketRepository implements MarketRepository {
  ApiMarketRepository(this._dio);
  final Dio _dio;

  @override
  Future<MarketBoard> loadBoard() async {
    final res = await _dio.get<Map<String, dynamic>>('/market/board');
    return MarketBoard.fromJson(res.data!);
  }

  @override
  Future<InformalBoard> loadInformalBoard() async {
    final res = await _dio.get<Map<String, dynamic>>('/informal');
    return InformalBoard.fromJson(res.data!);
  }

  @override
  Future<void> acceptInformalOffer(String offerId) async {
    await _dio.post<Map<String, dynamic>>('/informal/$offerId/accept');
  }

  @override
  Future<MarketTradeResult> buyOrder(String listingId, int quantity) async {
    final res = await _dio.post<Map<String, dynamic>>(
      '/market/listings/$listingId/buy',
      data: {'quantity': quantity},
    );
    final data = res.data ?? const {};
    return MarketTradeResult(
      total: double.tryParse('${data['total']}') ?? 0,
      tax: double.tryParse('${data['tax']}') ?? 0,
      remaining: (data['remaining'] as num?)?.toInt() ?? 0,
    );
  }

  @override
  Future<void> createListing({
    required String resourceKey,
    required int quantity,
    required double unitPrice,
  }) async {
    await _dio.post<Map<String, dynamic>>(
      '/market/listings',
      data: {'key': resourceKey, 'quantity': quantity, 'unitPrice': unitPrice},
    );
  }
}
