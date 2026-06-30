import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

import '../../domain/models/player_profile.dart';
import '../../domain/repositories/profile_repository.dart';

class MockProfileRepository implements ProfileRepository {
  const MockProfileRepository({this.latency = const Duration(milliseconds: 500)});

  final Duration latency;

  @override
  Future<PlayerProfile> loadProfile() async {
    await Future<void>.delayed(latency);
    final raw = await rootBundle.loadString('assets/fixtures/profile.json');
    return PlayerProfile.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }
}
