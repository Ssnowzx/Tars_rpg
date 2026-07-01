import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

import '../../domain/models/notification.dart';
import '../../domain/repositories/notification_repository.dart';

class MockNotificationRepository implements NotificationRepository {
  const MockNotificationRepository({this.latency = const Duration(milliseconds: 350)});

  final Duration latency;

  @override
  Future<NotificationCenter> loadNotifications() async {
    await Future<void>.delayed(latency);
    final raw = await rootBundle.loadString('assets/fixtures/notifications.json');
    return NotificationCenter.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }
}
