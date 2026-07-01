import '../models/notification.dart';

/// Costura do Centro de Notificações (mock hoje, API depois) — transversal.
abstract interface class NotificationRepository {
  Future<NotificationCenter> loadNotifications();
}
