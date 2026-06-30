import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

import '../../domain/models/spaceport.dart';
import '../../domain/repositories/spaceport_repository.dart';

class MockSpaceportRepository implements SpaceportRepository {
  const MockSpaceportRepository({this.latency = const Duration(milliseconds: 500)});

  final Duration latency;

  @override
  Future<SpaceportState> loadSpaceport() async {
    await Future<void>.delayed(latency);
    final raw = await rootBundle.loadString('assets/fixtures/spaceport.json');
    return SpaceportState.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }
}
