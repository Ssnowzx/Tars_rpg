import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

import '../../domain/models/federation.dart';
import '../../domain/repositories/federation_repository.dart';

class MockFederationRepository implements FederationRepository {
  const MockFederationRepository({this.latency = const Duration(milliseconds: 450)});

  final Duration latency;

  @override
  Future<Federation> loadFederation() async {
    await Future<void>.delayed(latency);
    final raw = await rootBundle.loadString('assets/fixtures/federation.json');
    return Federation.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }
}
