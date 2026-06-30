import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

import '../../domain/models/colony_buildings.dart';
import '../../domain/models/planet_models.dart';
import '../../domain/models/world_models.dart';
import '../../domain/repositories/world_repository.dart';

class MockWorldRepository implements WorldRepository {
  const MockWorldRepository({this.latency = const Duration(milliseconds: 500)});

  final Duration latency;

  @override
  Future<ColonyState> loadColony() async {
    await Future<void>.delayed(latency);
    final raw = await rootBundle.loadString('assets/fixtures/world.json');
    return ColonyState.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }

  @override
  Future<PlanetState> loadPlanet() async {
    await Future<void>.delayed(latency);
    final raw = await rootBundle.loadString('assets/fixtures/planet.json');
    return PlanetState.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }

  @override
  Future<ColonyBase> loadColonyBase() async {
    await Future<void>.delayed(latency);
    final raw = await rootBundle.loadString('assets/fixtures/colony.json');
    return ColonyBase.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }
}
