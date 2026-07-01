import 'package:dio/dio.dart';

import '../../domain/models/informal_trade.dart';
import '../../domain/models/market.dart';
import '../../domain/repositories/market_repository.dart';

/// Mercado Central (§13) e Comércio Informal (§8) via API (/config).
class ApiMarketRepository implements MarketRepository {
  ApiMarketRepository(this._dio);
  final Dio _dio;

  @override
  Future<MarketBoard> loadBoard() async {
    final res = await _dio.get<Map<String, dynamic>>('/config/market');
    return MarketBoard.fromJson(res.data!);
  }

  @override
  Future<InformalBoard> loadInformalBoard() async {
    final res = await _dio.get<Map<String, dynamic>>('/config/informal');
    return InformalBoard.fromJson(res.data!);
  }
}
