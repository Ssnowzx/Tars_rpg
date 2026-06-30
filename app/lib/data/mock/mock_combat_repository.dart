import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

import '../../domain/models/combat.dart';
import '../../domain/repositories/combat_repository.dart';

class MockCombatRepository implements CombatRepository {
  const MockCombatRepository({this.latency = const Duration(milliseconds: 450)});

  final Duration latency;

  @override
  Future<CombatState> loadCombat() async {
    await Future<void>.delayed(latency);
    final raw = await rootBundle.loadString('assets/fixtures/combat.json');
    return CombatState.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }
}
