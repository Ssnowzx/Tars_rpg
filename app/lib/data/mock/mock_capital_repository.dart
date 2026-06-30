import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

import '../../domain/models/institution_slot.dart';
import '../../domain/models/resources.dart';
import '../../domain/repositories/capital_repository.dart';

/// Implementação mock: lê fixtures de `assets/fixtures/` e simula latência de
/// rede para exercitar estados de loading. Trocável por uma `ApiCapitalRepository`
/// sem tocar a UI.
class MockCapitalRepository implements CapitalRepository {
  const MockCapitalRepository({this.latency = const Duration(milliseconds: 600)});

  final Duration latency;

  @override
  Future<Resources> loadResources() async {
    await Future<void>.delayed(latency);
    final raw = await rootBundle.loadString('assets/fixtures/player.json');
    final json = jsonDecode(raw) as Map<String, dynamic>;
    return Resources.fromJson(json['resources'] as Map<String, dynamic>);
  }

  @override
  Future<List<InstitutionSlot>> loadSlots() async {
    await Future<void>.delayed(latency);
    final raw = await rootBundle.loadString('assets/fixtures/capital.json');
    final json = jsonDecode(raw) as Map<String, dynamic>;
    return (json['slots'] as List<dynamic>)
        .map((e) => InstitutionSlot.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
