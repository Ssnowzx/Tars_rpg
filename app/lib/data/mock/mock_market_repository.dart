import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

import '../../domain/models/informal_trade.dart';
import '../../domain/models/market.dart';
import '../../domain/repositories/market_repository.dart';

class MockMarketRepository implements MarketRepository {
  const MockMarketRepository({this.latency = const Duration(milliseconds: 550)});

  final Duration latency;

  @override
  Future<MarketBoard> loadBoard() async {
    await Future<void>.delayed(latency);
    final raw = await rootBundle.loadString('assets/fixtures/market.json');
    return MarketBoard.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }

  @override
  Future<InformalBoard> loadInformalBoard() async {
    await Future<void>.delayed(latency);
    final raw = await rootBundle.loadString('assets/fixtures/informal.json');
    return InformalBoard.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }
}
