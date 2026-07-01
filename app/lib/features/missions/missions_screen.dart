import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../app/theme/ds_colors.dart';
import '../../app/theme/ds_tokens.dart';
import '../../data/providers.dart';
import '../../domain/models/mission.dart';

({String label, IconData icon, Color color}) _categoryMeta(MissionCategory c, DsTokens t) => switch (c) {
      MissionCategory.tutorial => (label: 'Tutoria', icon: Icons.school_outlined, color: t.teal),
      MissionCategory.daily => (label: 'Diárias', icon: Icons.today_outlined, color: t.info),
      MissionCategory.weekly => (label: 'Semanais', icon: Icons.date_range_outlined, color: t.federation),
      MissionCategory.narrative => (label: 'Narrativa', icon: Icons.menu_book_outlined, color: t.solar),
      MissionCategory.federation => (label: 'Federação', icon: Icons.groups_outlined, color: t.federation),
      MissionCategory.war => (label: 'Guerra', icon: Icons.local_fire_department_outlined, color: t.deltaDown),
      MissionCategory.event => (label: 'Eventos', icon: Icons.bolt_outlined, color: t.warning),
    };

({String label, Color color}) _statusMeta(MissionStatus s, DsTokens t) => switch (s) {
      MissionStatus.available => (label: 'Disponível', color: t.textSecondary),
      MissionStatus.inProgress => (label: 'Em progresso', color: t.info),
      MissionStatus.completed => (label: 'Pronta', color: t.success),
      MissionStatus.claimed => (label: 'Resgatada', color: t.success),
      MissionStatus.locked => (label: 'Bloqueada', color: t.textSecondary),
    };

({String label, Color color, IconData icon}) _tierMeta(AchievementTier a, DsTokens t) => switch (a) {
      AchievementTier.bronze => (label: 'Bronze', color: FwPalette.rust300, icon: Icons.military_tech_outlined),
      AchievementTier.silver => (label: 'Prata', color: FwPalette.gray400, icon: Icons.military_tech_outlined),
      AchievementTier.gold => (label: 'Ouro', color: t.solar, icon: Icons.military_tech),
      AchievementTier.platinum => (label: 'Platina', color: t.info, icon: Icons.workspace_premium),
    };

({IconData icon, Color color}) _eventMeta(String type, DsTokens t) => switch (type) {
      'gagarin' => (icon: Icons.travel_explore_outlined, color: t.info),
      'storm' => (icon: Icons.bolt_outlined, color: t.warning),
      'war' => (icon: Icons.local_fire_department_outlined, color: t.deltaDown),
      'market' => (icon: Icons.show_chart, color: t.solar),
      'federation' => (icon: Icons.groups_outlined, color: t.federation),
      _ => (icon: Icons.event_outlined, color: t.textSecondary),
    };

const _categoryOrder = [
  MissionCategory.tutorial,
  MissionCategory.daily,
  MissionCategory.weekly,
  MissionCategory.narrative,
  MissionCategory.federation,
  MissionCategory.war,
  MissionCategory.event,
];

enum _Tab { missions, achievements, events }

/// Central de Missões, Conquistas e Eventos (GDD v29 §6). 7 tipos de missão com
/// progresso e recompensa, conquistas Bronze→Platina e eventos ativos. A escada
/// de progressão 1–100 (§5) fica no Perfil. Drill-in do shell (mantém HUD/nav).
class MissionsScreen extends ConsumerStatefulWidget {
  const MissionsScreen({super.key});

  @override
  ConsumerState<MissionsScreen> createState() => _MissionsScreenState();
}

class _MissionsScreenState extends ConsumerState<MissionsScreen> {
  _Tab _tab = _Tab.missions;

  void _toast(String m) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(m), behavior: SnackBarBehavior.floating, duration: const Duration(seconds: 2)),
      );

  /// Resgata a recompensa da missão no backend (credita Fert$) e atualiza o
  /// board e o HUD de recursos.
  Future<void> _claim(Mission m) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      await ref.read(missionRepositoryProvider).claim(m.id);
      ref.invalidate(missionBoardProvider);
      ref.invalidate(resourcesProvider);
      if (!mounted) return;
      messenger.showSnackBar(SnackBar(
        content: Text('Recompensa resgatada: ${m.reward}'),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ));
    } catch (_) {
      if (!mounted) return;
      messenger.showSnackBar(const SnackBar(
        content: Text('Não foi possível resgatar a recompensa agora.'),
        behavior: SnackBarBehavior.floating,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).extension<DsTokens>()!;
    final board = ref.watch(missionBoardProvider);

    return ColoredBox(
      color: t.surfacePage,
      child: board.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => Center(
          child: TextButton.icon(
            onPressed: () => ref.invalidate(missionBoardProvider),
            icon: const Icon(Icons.refresh),
            label: const Text('Não foi possível carregar as missões. Tocar para tentar de novo.'),
          ),
        ),
        data: (data) => Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const _Header(),
            _Summary(board: data),
            _Tabs(value: _tab, onChanged: (v) => setState(() => _tab = v)),
            Expanded(
              child: Align(
                alignment: Alignment.topCenter,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 840),
                  child: switch (_tab) {
                    _Tab.missions => _MissionsTab(board: data, onClaim: _claim, onReject: _toast),
                    _Tab.achievements => _AchievementsTab(board: data),
                    _Tab.events => _EventsTab(board: data),
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

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
          const Icon(Icons.flag_circle_outlined, size: 22, color: FwPalette.rust600),
          SizedBox(width: t.space2),
          Text('Missões',
              style: GoogleFonts.rajdhani(fontWeight: FontWeight.w700, fontSize: 22, color: FwPalette.gray900)),
        ],
      ),
    );
  }
}

class _Summary extends StatelessWidget {
  const _Summary({required this.board});
  final MissionBoard board;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).extension<DsTokens>()!;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: t.space4, vertical: t.space1),
      child: Wrap(
        spacing: t.space2,
        runSpacing: t.space1,
        children: [
          _SummaryChip(icon: Icons.today_outlined, color: t.info, text: 'Diárias ${board.dailyDone}/${board.dailyTotal}'),
          _SummaryChip(icon: Icons.local_fire_department_outlined, color: t.solar, text: 'Sequência ${board.streak}d'),
          if (board.claimable > 0)
            _SummaryChip(icon: Icons.redeem_outlined, color: t.success, text: '${board.claimable} para resgatar'),
          _SummaryChip(
              icon: Icons.military_tech_outlined,
              color: t.federation,
              text: 'Conquistas ${board.unlockedAchievements}/${board.achievements.length}'),
        ],
      ),
    );
  }
}

class _SummaryChip extends StatelessWidget {
  const _SummaryChip({required this.icon, required this.color, required this.text});
  final IconData icon;
  final Color color;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(6)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 4),
          Text(text, style: GoogleFonts.rajdhani(fontWeight: FontWeight.w700, fontSize: 11.5, color: color)),
        ],
      ),
    );
  }
}

class _Tabs extends StatelessWidget {
  const _Tabs({required this.value, required this.onChanged});
  final _Tab value;
  final ValueChanged<_Tab> onChanged;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).extension<DsTokens>()!;
    Widget chip(_Tab tab, String label, IconData icon) => Padding(
          padding: EdgeInsets.only(right: t.space2),
          child: ChoiceChip(
            avatar: Icon(icon, size: 15, color: value == tab ? FwPalette.rust600 : t.textSecondary),
            label: Text(label),
            selected: value == tab,
            onSelected: (_) => onChanged(tab),
          ),
        );
    return Padding(
      padding: EdgeInsets.fromLTRB(t.space4, t.space2, t.space4, t.space2),
      child: Row(
        children: [
          chip(_Tab.missions, 'Missões', Icons.flag_outlined),
          chip(_Tab.achievements, 'Conquistas', Icons.military_tech_outlined),
          chip(_Tab.events, 'Eventos', Icons.bolt_outlined),
        ],
      ),
    );
  }
}

// ── Aba Missões ──────────────────────────────────────────────────────────────

class _MissionsTab extends StatelessWidget {
  const _MissionsTab({required this.board, required this.onClaim, required this.onReject});
  final MissionBoard board;
  final ValueChanged<Mission> onClaim;
  final ValueChanged<String> onReject;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).extension<DsTokens>()!;
    final groups = [
      for (final c in _categoryOrder)
        (category: c, items: board.missions.where((m) => m.category == c).toList())
    ].where((g) => g.items.isNotEmpty).toList();

    return ListView(
      padding: EdgeInsets.fromLTRB(t.space4, t.space2, t.space4, t.space6),
      children: [
        for (final g in groups) ...[
          _GroupHeader(category: g.category, count: g.items.length),
          for (final m in g.items)
            _MissionCard(
              mission: m,
              onClaim: () => onClaim(m),
              onReject: () => onReject('Missão trocada (1 rejeição/dia, §6) — em breve'),
            ),
          SizedBox(height: t.space3),
        ],
      ],
    );
  }
}

class _GroupHeader extends StatelessWidget {
  const _GroupHeader({required this.category, required this.count});
  final MissionCategory category;
  final int count;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).extension<DsTokens>()!;
    final meta = _categoryMeta(category, t);
    return Padding(
      padding: EdgeInsets.only(top: t.space2, bottom: t.space2),
      child: Row(
        children: [
          Icon(meta.icon, size: 16, color: meta.color),
          SizedBox(width: t.space2),
          Text(meta.label.toUpperCase(),
              style: GoogleFonts.rajdhani(
                  fontWeight: FontWeight.w700, fontSize: 12, letterSpacing: 1.1, color: FwPalette.gray500)),
          SizedBox(width: t.space2),
          Text('$count', style: TextStyle(fontSize: 11, color: t.textSecondary)),
        ],
      ),
    );
  }
}

class _MissionCard extends StatelessWidget {
  const _MissionCard({required this.mission, required this.onClaim, required this.onReject});
  final Mission mission;
  final VoidCallback onClaim;
  final VoidCallback onReject;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).extension<DsTokens>()!;
    final scheme = Theme.of(context).colorScheme;
    final cat = _categoryMeta(mission.category, t);
    final status = _statusMeta(mission.status, t);
    final locked = mission.status == MissionStatus.locked;
    final showBar = mission.target > 1 && !locked && mission.status != MissionStatus.claimed;
    return Opacity(
      opacity: locked ? 0.6 : 1,
      child: Container(
        margin: EdgeInsets.only(bottom: t.space2),
        padding: EdgeInsets.all(t.space3),
        decoration: BoxDecoration(
          color: scheme.surface,
          borderRadius: BorderRadius.circular(t.radiusCard),
          border: Border(
            left: BorderSide(color: cat.color, width: 3),
            top: BorderSide(color: t.borderDefault),
            right: BorderSide(color: t.borderDefault),
            bottom: BorderSide(color: t.borderDefault),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(mission.title,
                      style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700, color: FwPalette.gray900)),
                ),
                SizedBox(width: t.space2),
                _StatusPill(label: status.label, color: status.color, icon: _statusIcon(mission.status)),
              ],
            ),
            SizedBox(height: t.space1),
            Text(mission.description,
                style: TextStyle(fontSize: 12, height: 1.3, color: t.textSecondary)),
            if (showBar) ...[
              SizedBox(height: t.space2),
              _ProgressBar(fraction: mission.progress, color: cat.color),
              SizedBox(height: t.space1),
              Text('${mission.current} / ${mission.target}',
                  style: TextStyle(fontSize: 10.5, color: t.textSecondary)),
            ],
            SizedBox(height: t.space2),
            Row(
              children: [
                Icon(Icons.card_giftcard_outlined, size: 14, color: t.solar),
                SizedBox(width: t.space1),
                Expanded(
                  child: Text(mission.reward,
                      style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: t.solar)),
                ),
                if (mission.rejectable && mission.status == MissionStatus.inProgress)
                  TextButton(
                    onPressed: onReject,
                    style: TextButton.styleFrom(visualDensity: VisualDensity.compact, padding: EdgeInsets.symmetric(horizontal: t.space2)),
                    child: const Text('Trocar', style: TextStyle(fontSize: 12)),
                  ),
                _trailing(context, t),
              ],
            ),
            SizedBox(height: t.space1),
            Row(
              children: [
                Icon(Icons.schedule_outlined, size: 12, color: t.textSecondary),
                SizedBox(width: t.space1),
                Text(mission.timeLabel, style: TextStyle(fontSize: 10.5, color: t.textSecondary)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _trailing(BuildContext context, DsTokens t) {
    switch (mission.status) {
      case MissionStatus.completed:
        return FilledButton.icon(
          onPressed: onClaim,
          style: FilledButton.styleFrom(
              backgroundColor: t.success,
              visualDensity: VisualDensity.compact,
              padding: EdgeInsets.symmetric(horizontal: t.space3)),
          icon: const Icon(Icons.redeem, size: 15),
          label: const Text('Resgatar'),
        );
      case MissionStatus.claimed:
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check_circle, size: 15, color: t.success),
            SizedBox(width: t.space1),
            Text('Resgatada', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: t.success)),
          ],
        );
      case MissionStatus.locked:
        return Icon(Icons.lock_outline, size: 16, color: t.textSecondary);
      case MissionStatus.available:
      case MissionStatus.inProgress:
        return const SizedBox.shrink();
    }
  }
}

IconData _statusIcon(MissionStatus s) => switch (s) {
      MissionStatus.completed => Icons.check_circle_outline,
      MissionStatus.claimed => Icons.check,
      MissionStatus.locked => Icons.lock_outline,
      MissionStatus.inProgress => Icons.pending_outlined,
      MissionStatus.available => Icons.radio_button_unchecked,
    };

// ── Aba Conquistas ───────────────────────────────────────────────────────────

class _AchievementsTab extends StatelessWidget {
  const _AchievementsTab({required this.board});
  final MissionBoard board;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).extension<DsTokens>()!;
    return ListView(
      padding: EdgeInsets.fromLTRB(t.space4, t.space3, t.space4, t.space6),
      children: [for (final a in board.achievements) _AchievementCard(achievement: a)],
    );
  }
}

class _AchievementCard extends StatelessWidget {
  const _AchievementCard({required this.achievement});
  final Achievement achievement;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).extension<DsTokens>()!;
    final scheme = Theme.of(context).colorScheme;
    final tier = _tierMeta(achievement.tier, t);
    final unlocked = achievement.unlocked;
    return Container(
      margin: EdgeInsets.only(bottom: t.space2),
      padding: EdgeInsets.all(t.space3),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(t.radiusCard),
        border: Border.all(color: unlocked ? tier.color.withValues(alpha: 0.5) : t.borderDefault),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: tier.color.withValues(alpha: unlocked ? 0.16 : 0.08),
            ),
            child: Icon(unlocked ? tier.icon : Icons.lock_outline,
                size: 22, color: unlocked ? tier.color : t.textSecondary),
          ),
          SizedBox(width: t.space3),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(achievement.title,
                          style: TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w700,
                              color: unlocked ? FwPalette.gray900 : t.textSecondary)),
                    ),
                    _StatusPill(label: tier.label, color: tier.color, icon: Icons.military_tech_outlined),
                  ],
                ),
                SizedBox(height: t.space1),
                Text(achievement.description,
                    style: TextStyle(fontSize: 12, height: 1.3, color: t.textSecondary)),
                SizedBox(height: t.space2),
                if (unlocked)
                  Row(
                    children: [
                      Icon(Icons.check_circle, size: 14, color: tier.color),
                      SizedBox(width: t.space1),
                      Text('Conquistada',
                          style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: tier.color)),
                    ],
                  )
                else ...[
                  _ProgressBar(fraction: achievement.progress, color: tier.color),
                  SizedBox(height: t.space1),
                  Text('${achievement.current} / ${achievement.target}',
                      style: TextStyle(fontSize: 10.5, color: t.textSecondary)),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Aba Eventos ──────────────────────────────────────────────────────────────

class _EventsTab extends StatelessWidget {
  const _EventsTab({required this.board});
  final MissionBoard board;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).extension<DsTokens>()!;
    if (board.events.isEmpty) {
      return Center(child: Text('Nenhum evento ativo.', style: TextStyle(color: t.textSecondary)));
    }
    return ListView(
      padding: EdgeInsets.fromLTRB(t.space4, t.space3, t.space4, t.space6),
      children: [for (final e in board.events) _EventCard(event: e)],
    );
  }
}

class _EventCard extends StatelessWidget {
  const _EventCard({required this.event});
  final GameEvent event;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).extension<DsTokens>()!;
    final scheme = Theme.of(context).colorScheme;
    final meta = _eventMeta(event.type, t);
    return Container(
      margin: EdgeInsets.only(bottom: t.space2),
      padding: EdgeInsets.all(t.space3),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(t.radiusCard),
        border: Border.all(color: t.borderDefault),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            alignment: Alignment.center,
            decoration: BoxDecoration(color: meta.color.withValues(alpha: 0.14), borderRadius: BorderRadius.circular(t.radiusMd)),
            child: Icon(meta.icon, size: 20, color: meta.color),
          ),
          SizedBox(width: t.space3),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(event.title,
                          style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700, color: FwPalette.gray900)),
                    ),
                    _StatusPill(label: event.timeLabel, color: meta.color, icon: Icons.schedule_outlined),
                  ],
                ),
                SizedBox(height: t.space1),
                Text(event.description,
                    style: TextStyle(fontSize: 12, height: 1.35, color: t.textSecondary)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Comuns ───────────────────────────────────────────────────────────────────

class _ProgressBar extends StatelessWidget {
  const _ProgressBar({required this.fraction, required this.color});
  final double fraction;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).extension<DsTokens>()!;
    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: LinearProgressIndicator(
        value: fraction.clamp(0, 1),
        minHeight: 7,
        backgroundColor: t.surfaceSunken,
        valueColor: AlwaysStoppedAnimation<Color>(color),
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.label, required this.color, this.icon});
  final String label;
  final Color color;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[Icon(icon, size: 11, color: color), const SizedBox(width: 4)],
          Text(label, style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w600, color: color)),
        ],
      ),
    );
  }
}
