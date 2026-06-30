import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

import '../../domain/models/mission.dart';
import '../../domain/repositories/mission_repository.dart';

class MockMissionRepository implements MissionRepository {
  const MockMissionRepository({this.latency = const Duration(milliseconds: 450)});

  final Duration latency;

  @override
  Future<MissionBoard> loadBoard() async {
    await Future<void>.delayed(latency);
    final raw = await rootBundle.loadString('assets/fixtures/missions.json');
    return MissionBoard.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }
}
