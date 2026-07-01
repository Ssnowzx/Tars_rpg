import 'package:dio/dio.dart';

import '../../domain/models/auction.dart';
import '../../domain/repositories/auction_repository.dart';

/// Casa de Leilões (§13) via API — lotes/lances reais.
class ApiAuctionRepository implements AuctionRepository {
  ApiAuctionRepository(this._dio);
  final Dio _dio;

  @override
  Future<AuctionHouse> loadAuctions() async {
    final res = await _dio.get<Map<String, dynamic>>('/auctions');
    return AuctionHouse.fromJson(res.data!);
  }

  @override
  Future<void> placeBid(String auctionId, int amount) async {
    await _dio.post<Map<String, dynamic>>('/auctions/$auctionId/bid', data: {'amount': amount});
  }
}
