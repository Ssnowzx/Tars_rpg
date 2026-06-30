import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

import '../../domain/models/ministry.dart';
import '../../domain/repositories/ministry_repository.dart';

class MockMinistryRepository implements MinistryRepository {
  const MockMinistryRepository({this.latency = const Duration(milliseconds: 500)});

  final Duration latency;

  @override
  Future<MinistriesData> loadMinistries() async {
    await Future<void>.delayed(latency);
    final raw = await rootBundle.loadString('assets/fixtures/ministries.json');
    return MinistriesData.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }
}
