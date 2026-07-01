import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

import '../../domain/models/public_office.dart';
import '../../domain/repositories/public_office_repository.dart';

class MockPublicOfficeRepository implements PublicOfficeRepository {
  const MockPublicOfficeRepository({this.latency = const Duration(milliseconds: 450)});

  final Duration latency;

  @override
  Future<PublicOfficeBoard> loadOffices() async {
    await Future<void>.delayed(latency);
    final raw = await rootBundle.loadString('assets/fixtures/offices.json');
    return PublicOfficeBoard.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }
}
