import 'package:flutter/foundation.dart';

/// Origem/categoria da notificação (transversal — vem de todos os sistemas).
enum NotifKind { gagarin, war, market, dispute, federation, mission, office, auction, fleet, system }

NotifKind _kindFrom(String? s) => switch (s) {
      'war' => NotifKind.war,
      'market' => NotifKind.market,
      'dispute' => NotifKind.dispute,
      'federation' => NotifKind.federation,
      'mission' => NotifKind.mission,
      'office' => NotifKind.office,
      'auction' => NotifKind.auction,
      'fleet' => NotifKind.fleet,
      'system' => NotifKind.system,
      _ => NotifKind.gagarin,
    };

/// Severidade da notificação. A UI distingue por **cor + forma** (ícone
/// diferente por nível), nunca só por cor.
enum NotifSeverity { info, success, warning, critical }

NotifSeverity _severityFrom(String? s) => switch (s) {
      'success' => NotifSeverity.success,
      'warning' => NotifSeverity.warning,
      'critical' => NotifSeverity.critical,
      _ => NotifSeverity.info,
    };

/// Uma notificação in-app (§ transversal). `route` = destino opcional ao tocar
/// na ação; `time` já vem formatado (ex.: "há 8min").
@immutable
class AppNotification {
  const AppNotification({
    required this.id,
    required this.kind,
    required this.severity,
    required this.title,
    required this.body,
    required this.time,
    required this.read,
    this.actionLabel = '',
    this.route = '',
  });

  final String id;
  final NotifKind kind;
  final NotifSeverity severity;
  final String title;
  final String body;
  final String time;
  final bool read;
  final String actionLabel;
  final String route;

  bool get isImportant => severity == NotifSeverity.warning || severity == NotifSeverity.critical;

  factory AppNotification.fromJson(Map<String, dynamic> j) => AppNotification(
        id: j['id'] as String,
        kind: _kindFrom(j['kind'] as String?),
        severity: _severityFrom(j['severity'] as String?),
        title: j['title'] as String? ?? '',
        body: j['body'] as String? ?? '',
        time: j['time'] as String? ?? '',
        read: j['read'] as bool? ?? false,
        actionLabel: j['actionLabel'] as String? ?? '',
        route: j['route'] as String? ?? '',
      );
}

/// Estado do Centro de Notificações (mock, transversal).
@immutable
class NotificationCenter {
  const NotificationCenter({required this.notifications});
  final List<AppNotification> notifications;

  int get unreadCount => notifications.where((n) => !n.read).length;
  int get importantCount => notifications.where((n) => n.isImportant && !n.read).length;

  factory NotificationCenter.fromJson(Map<String, dynamic> j) => NotificationCenter(
        notifications: (j['notifications'] as List<dynamic>? ?? const [])
            .map((e) => AppNotification.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}
