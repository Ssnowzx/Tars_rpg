import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

import '../../domain/models/lunar.dart';
import '../../domain/repositories/lunar_repository.dart';

class MockLunarRepository implements LunarRepository {
  const MockLunarRepository({this.latency = const Duration(milliseconds: 400)});
  final Duration latency;

  @override
  Future<LunarExploration> loadLunar() async {
    await Future<void>.delayed(latency);
    final raw = await rootBundle.loadString('assets/fixtures/lunar.json');
    return LunarExploration.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }
}
