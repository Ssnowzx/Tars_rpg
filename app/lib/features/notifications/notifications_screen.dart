import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../app/theme/ds_colors.dart';
import '../../app/theme/ds_tokens.dart';
import '../../data/providers.dart';
import '../../domain/models/notification.dart';

/// Severidade por **cor + forma** (ícone diferente por nível, não só cor).
({Color color, IconData icon, String label}) _severityMeta(NotifSeverity s, DsTokens t) => switch (s) {
      NotifSeverity.info => (color: t.info, icon: Icons.info_outline, label: 'Info'),
      NotifSeverity.success => (color: t.success, icon: Icons.check_circle_outline, label: 'Sucesso'),
      NotifSeverity.warning => (color: t.warning, icon: Icons.warning_amber_outlined, label: 'Atenção'),
      NotifSeverity.critical => (color: t.deltaDown, icon: Icons.dangerous_outlined, label: 'Crítico'),
    };

({IconData icon, Color color, String label}) _kindMeta(NotifKind k, DsTokens t) => switch (k) {
      NotifKind.gagarin => (icon: Icons.travel_explore_outlined, color: t.info, label: 'Gagarin'),
      NotifKind.war => (icon: Icons.local_fire_department_outlined, color: t.deltaDown, label: 'Guerra'),
      NotifKind.market => (icon: Icons.storefront_outlined, color: t.solar, label: 'Mercado'),
      NotifKind.dispute => (icon: Icons.balance_outlined, color: t.federation, label: 'Reputações'),
      NotifKind.federation => (icon: Icons.groups_outlined, color: t.federation, label: 'Federação'),
      NotifKind.mission => (icon: Icons.flag_outlined, color: t.teal, label: 'Missão'),
      NotifKind.office => (icon: Icons.badge_outlined, color: t.info, label: 'Cargos'),
      NotifKind.auction => (icon: Icons.gavel_outlined, color: t.solar, label: 'Leilão'),
      NotifKind.fleet => (icon: Icons.local_shipping_outlined, color: t.info, label: 'Frota'),
      NotifKind.system => (icon: Icons.settings_outlined, color: t.textSecondary, label: 'Sistema'),
    };

enum _Filter { all, unread, important }

/// Centro de Notificações (GDD v29 — transversal). Agrega eventos de todos os
/// sistemas (guerra §27, Reputações §9, Gagarin §12.1, mercado, missões §6,
/// federação §4, cargos §14, leilões §13, frota §16). Severidade por **cor +
/// forma**. Drill-in do shell (mantém HUD/nav).
class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {
  _Filter _filter = _Filter.all;

  void _toast(String m) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(m), behavior: SnackBarBehavior.floating, duration: const Duration(seconds: 2)),
      );

  void _onAction(AppNotification n) {
    if (n.route.isNotEmpty) {
      context.go(n.route);
    } else {
      _toast('${n.actionLabel.isNotEmpty ? n.actionLabel : n.title} — em breve');
    }
  }

  bool _matches(AppNotification n) => switch (_filter) {
        _Filter.all => true,
        _Filter.unread => !n.read,
        _Filter.important => n.isImportant,
      };

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).extension<DsTokens>()!;
    final center = ref.watch(notificationsProvider);

    return ColoredBox(
      color: t.surfacePage,
      child: center.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => Center(
          child: TextButton.icon(
            onPressed: () => ref.invalidate(notificationsProvider),
            icon: const Icon(Icons.refresh),
            label: const Text('Não foi possível carregar as notificações. Tocar para tentar de novo.'),
          ),
        ),
        data: (data) {
          final items = data.notifications.where(_matches).toList();
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _Header(unread: data.unreadCount, onMarkAll: () => _toast('Todas marcadas como lidas — em breve')),
              _Filters(
                value: _filter,
                unread: data.unreadCount,
                important: data.importantCount,
                onChanged: (f) => setState(() => _filter = f),
              ),
              Expanded(
                child: Align(
                  alignment: Alignment.topCenter,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 840),
                    child: items.isEmpty
                        ? Center(child: Text('Nada por aqui.', style: TextStyle(color: t.textSecondary)))
                        : ListView(
                            padding: EdgeInsets.fromLTRB(t.space4, t.space2, t.space4, t.space6),
                            children: [
                              const _Legend(),
                              for (final n in items)
                                _NotificationCard(notification: n, onAction: () => _onAction(n)),
                            ],
                          ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.unread, required this.onMarkAll});
  final int unread;
  final VoidCallback onMarkAll;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).extension<DsTokens>()!;
    return Padding(
      padding: EdgeInsets.fromLTRB(t.space4, t.space4, t.space4, t.space2),
      child: Row(
        children: [
          InkWell(
            onTap: () => context.go('/map'),
            borderRadius: BorderRadius.circular(t.radiusSm),
            child: Padding(
              padding: const EdgeInsets.all(6),
              child: Icon(Icons.arrow_back, size: 20, color: t.textSecondary),
            ),
          ),
          SizedBox(width: t.space2),
          const Icon(Icons.notifications_none, size: 22, color: FwPalette.rust600),
          SizedBox(width: t.space2),
          Text('Notificações',
              style: GoogleFonts.rajdhani(fontWeight: FontWeight.w700, fontSize: 22, color: FwPalette.gray900)),
          if (unread > 0) ...[
            SizedBox(width: t.space2),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
              decoration: BoxDecoration(color: FwPalette.rust600, borderRadius: BorderRadius.circular(10)),
              child: Text('$unread',
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white)),
            ),
          ],
          const Spacer(),
          TextButton.icon(
            onPressed: onMarkAll,
            style: TextButton.styleFrom(visualDensity: VisualDensity.compact, foregroundColor: t.textSecondary),
            icon: const Icon(Icons.done_all, size: 16),
            label: const Text('Marcar todas'),
          ),
        ],
      ),
    );
  }
}

class _Filters extends StatelessWidget {
  const _Filters({required this.value, required this.unread, required this.important, required this.onChanged});
  final _Filter value;
  final int unread;
  final int important;
  final ValueChanged<_Filter> onChanged;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).extension<DsTokens>()!;
    Widget chip(_Filter f, String label) => Padding(
          padding: EdgeInsets.only(right: t.space2),
          child: ChoiceChip(
            label: Text(label),
            selected: value == f,
            onSelected: (_) => onChanged(f),
          ),
        );
    return Padding(
      padding: EdgeInsets.fromLTRB(t.space4, 0, t.space4, t.space2),
      child: Row(
        children: [
          chip(_Filter.all, 'Todas'),
          chip(_Filter.unread, 'Não lidas${unread > 0 ? ' ($unread)' : ''}'),
          chip(_Filter.important, 'Importantes${important > 0 ? ' ($important)' : ''}'),
        ],
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  const _Legend();

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).extension<DsTokens>()!;
    Widget item(NotifSeverity s) {
      final m = _severityMeta(s, t);
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(m.icon, size: 14, color: m.color),
          SizedBox(width: t.space1),
          Text(m.label, style: TextStyle(fontSize: 10.5, color: t.textSecondary)),
        ],
      );
    }

    return Container(
      margin: EdgeInsets.only(bottom: t.space2),
      padding: EdgeInsets.symmetric(horizontal: t.space3, vertical: t.space2),
      decoration: BoxDecoration(color: t.surfaceSunken, borderRadius: BorderRadius.circular(t.radiusMd)),
      child: Row(
        children: [
          Icon(Icons.palette_outlined, size: 13, color: t.textSecondary),
          SizedBox(width: t.space2),
          Text('Severidade por cor + forma:',
              style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w600, color: t.textSecondary)),
          SizedBox(width: t.space3),
          Expanded(
            child: Wrap(
              spacing: t.space3,
              runSpacing: t.space1,
              children: [
                item(NotifSeverity.info),
                item(NotifSeverity.success),
                item(NotifSeverity.warning),
                item(NotifSeverity.critical),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  const _NotificationCard({required this.notification, required this.onAction});
  final AppNotification notification;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).extension<DsTokens>()!;
    final scheme = Theme.of(context).colorScheme;
    final sev = _severityMeta(notification.severity, t);
    final kind = _kindMeta(notification.kind, t);
    final unread = !notification.read;
    return Container(
      margin: EdgeInsets.only(bottom: t.space2),
      padding: EdgeInsets.all(t.space3),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(t.radiusCard),
        border: Border(
          left: BorderSide(color: sev.color, width: 3),
          top: BorderSide(color: t.borderDefault),
          right: BorderSide(color: t.borderDefault),
          bottom: BorderSide(color: t.borderDefault),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Selo de severidade (cor + forma).
          Container(
            width: 38,
            height: 38,
            alignment: Alignment.center,
            decoration: BoxDecoration(color: sev.color.withValues(alpha: 0.14), borderRadius: BorderRadius.circular(t.radiusMd)),
            child: Icon(sev.icon, size: 20, color: sev.color),
          ),
          SizedBox(width: t.space3),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(notification.title,
                          style: TextStyle(
                              fontSize: 13.5,
                              fontWeight: unread ? FontWeight.w700 : FontWeight.w600,
                              color: FwPalette.gray900)),
                    ),
                    SizedBox(width: t.space2),
                    _KindChip(icon: kind.icon, color: kind.color, label: kind.label),
                    if (unread) ...[
                      SizedBox(width: t.space2),
                      const SizedBox(
                        width: 8,
                        height: 8,
                        child: DecoratedBox(
                          decoration: BoxDecoration(color: FwPalette.rust600, shape: BoxShape.circle),
                        ),
                      ),
                    ],
                  ],
                ),
                SizedBox(height: t.space1),
                Text(notification.body, style: TextStyle(fontSize: 12, height: 1.35, color: t.textSecondary)),
                SizedBox(height: t.space2),
                Row(
                  children: [
                    Icon(Icons.schedule_outlined, size: 12, color: t.textSecondary),
                    SizedBox(width: t.space1),
                    Text(notification.time, style: TextStyle(fontSize: 10.5, color: t.textSecondary)),
                    const Spacer(),
                    if (notification.actionLabel.isNotEmpty)
                      TextButton.icon(
                        onPressed: onAction,
                        style: TextButton.styleFrom(
                            visualDensity: VisualDensity.compact,
                            foregroundColor: kind.color,
                            padding: EdgeInsets.symmetric(horizontal: t.space2)),
                        icon: const Icon(Icons.arrow_forward, size: 14),
                        label: Text(notification.actionLabel, style: const TextStyle(fontSize: 12)),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _KindChip extends StatelessWidget {
  const _KindChip({required this.icon, required this.color, required this.label});
  final IconData icon;
  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(6)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: color),
          const SizedBox(width: 3),
          Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: color)),
        ],
      ),
    );
  }
}
