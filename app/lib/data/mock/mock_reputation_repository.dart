import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

import '../../domain/models/dispute.dart';
import '../../domain/repositories/reputation_repository.dart';

class MockReputationRepository implements ReputationRepository {
  const MockReputationRepository({this.latency = const Duration(milliseconds: 450)});

  final Duration latency;

  @override
  Future<DisputeBoard> loadDisputes() async {
    await Future<void>.delayed(latency);
    final raw = await rootBundle.loadString('assets/fixtures/disputes.json');
    return DisputeBoard.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }
}
