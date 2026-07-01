import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

import '../../domain/models/terraform.dart';
import '../../domain/repositories/terraform_repository.dart';

class MockTerraformRepository implements TerraformRepository {
  const MockTerraformRepository({this.latency = const Duration(milliseconds: 400)});
  final Duration latency;

  @override
  Future<TerraformState> loadTerraform() async {
    await Future<void>.delayed(latency);
    final raw = await rootBundle.loadString('assets/fixtures/terraform.json');
    return TerraformState.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }
}
