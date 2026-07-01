import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

import '../../domain/models/auction.dart';
import '../../domain/repositories/auction_repository.dart';

class MockAuctionRepository implements AuctionRepository {
  const MockAuctionRepository({this.latency = const Duration(milliseconds: 450)});

  final Duration latency;

  @override
  Future<AuctionHouse> loadAuctions() async {
    await Future<void>.delayed(latency);
    final raw = await rootBundle.loadString('assets/fixtures/auctions.json');
    return AuctionHouse.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }
}
