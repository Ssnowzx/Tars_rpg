import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

import '../../domain/models/fleet.dart';
import '../../domain/repositories/fleet_repository.dart';

class MockFleetRepository implements FleetRepository {
  const MockFleetRepository({this.latency = const Duration(milliseconds: 450)});

  final Duration latency;

  @override
  Future<FleetBoard> loadFleet() async {
    await Future<void>.delayed(latency);
    final raw = await rootBundle.loadString('assets/fixtures/fleet.json');
    return FleetBoard.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }
}
