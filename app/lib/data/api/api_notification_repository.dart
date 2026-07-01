import 'package:dio/dio.dart';

import '../../domain/models/notification.dart';
import '../../domain/repositories/notification_repository.dart';

/// Notificações reais do jogador (/notifications). Conta nova = lista vazia.
class ApiNotificationRepository implements NotificationRepository {
  ApiNotificationRepository(this._dio);
  final Dio _dio;

  @override
  Future<NotificationCenter> loadNotifications() async {
    final res = await _dio.get<List<dynamic>>('/notifications');
    final items = (res.data ?? const []).map((e) {
      final n = e as Map<String, dynamic>;
      return AppNotification.fromJson(<String, dynamic>{
        'id': n['id'],
        'kind': n['kind'],
        'severity': n['severity'],
        'title': n['title'],
        'body': n['body'],
        'time': _relTime(n['createdAt'] as String?),
        'read': n['read'],
        'route': n['route'] ?? '',
      });
    }).toList();
    return NotificationCenter(notifications: items);
  }
}

String _relTime(String? iso) {
  if (iso == null) return '';
  final t = DateTime.tryParse(iso);
  if (t == null) return '';
  final d = DateTime.now().difference(t);
  if (d.inMinutes < 1) return 'agora';
  if (d.inHours < 1) return 'há ${d.inMinutes}min';
  if (d.inDays < 1) return 'há ${d.inHours}h';
  return 'há ${d.inDays}d';
}
