import 'package:dio/dio.dart';

import '../../domain/models/auction.dart';
import '../../domain/repositories/auction_repository.dart';

/// Casa de Leilões (§13) via API (/config).
class ApiAuctionRepository implements AuctionRepository {
  ApiAuctionRepository(this._dio);
  final Dio _dio;

  @override
  Future<AuctionHouse> loadAuctions() async {
    final res = await _dio.get<Map<String, dynamic>>('/config/auctions');
    return AuctionHouse.fromJson(res.data!);
  }
}
