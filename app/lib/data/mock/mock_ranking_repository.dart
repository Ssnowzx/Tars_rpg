import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

import '../../domain/models/war_ranking.dart';
import '../../domain/repositories/ranking_repository.dart';

class MockRankingRepository implements RankingRepository {
  const MockRankingRepository({this.latency = const Duration(milliseconds: 500)});

  final Duration latency;

  @override
  Future<WarRankings> loadWarRankings() async {
    await Future<void>.delayed(latency);
    final raw = await rootBundle.loadString('assets/fixtures/rankings.json');
    return WarRankings.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }
}
