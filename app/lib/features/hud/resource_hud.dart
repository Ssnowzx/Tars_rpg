import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../app/theme/ds_colors.dart';
import '../../app/theme/ds_tokens.dart';
import '../../data/locale_controller.dart';
import '../../data/providers.dart';
import '../../domain/models/resources.dart';
import '../../domain/models/world_models.dart';
import '../../l10n/app_localizations.dart';

/// Barra superior persistente (HUD) — direção Solar Frontier: brasão + nome da
/// colônia + nível/XP, contadores de recurso (valor/capacidade + produção/h) e
/// cluster do jogador à direita. Cor sempre pareada com ícone + rótulo.
class TopResourceBar extends ConsumerWidget {
  const TopResourceBar({super.key});

  static const double height = 66;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = Theme.of(context).extension<DsTokens>()!;
    final scheme = Theme.of(context).colorScheme;
    final colony = ref.watch(colonyProvider);
    final resources = ref.watch(resourcesProvider);

    return Container(
      height: height,
      decoration: BoxDecoration(
        color: scheme.surface,
        border: Border(bottom: BorderSide(color: t.borderDefault)),
      ),
      padding: EdgeInsets.symmetric(horizontal: t.space4),
      child: Row(
        children: [
          _ColonyBlock(header: colony.asData?.value.header),
          SizedBox(width: t.space4),
          Expanded(
            child: resources.when(
              loading: () => Align(
                alignment: Alignment.centerLeft,
                child: Text('Carregando recursos…', style: TextStyle(color: t.textSecondary)),
              ),
              error: (_, __) => Row(children: [
                Icon(Icons.error_outline, size: 18, color: scheme.error),
                SizedBox(width: t.space2),
                const Text('Falha ao carregar recursos'),
              ]),
              data: (r) => _ResourceStrip(resources: r),
            ),
          ),
          SizedBox(width: t.space4),
          const _PlayerCluster(),
        ],
      ),
    );
  }
}

class _ColonyBlock extends StatelessWidget {
  const _ColonyBlock({this.header});
  final ColonyHeader? header;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).extension<DsTokens>()!;
    final name = header?.name ?? 'Colônia';
    final level = header?.level ?? 0;
    final xp = header?.xpFraction ?? 0;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 42,
          height: 42,
          child: Image.asset(
            'assets/images/crest-v1.png',
            fit: BoxFit.contain,
            filterQuality: FilterQuality.medium,
            errorBuilder: (_, __, ___) => Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(t.radiusMd),
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [FwPalette.rust600, FwPalette.solar500],
                ),
              ),
              child: const Icon(Icons.hexagon_outlined, color: Colors.white, size: 22),
            ),
          ),
        ),
        SizedBox(width: t.space2),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              name,
              style: GoogleFonts.rajdhani(
                fontWeight: FontWeight.w700,
                fontSize: 17,
                color: FwPalette.gray900,
                height: 1,
              ),
            ),
            SizedBox(height: t.space1),
            Row(
              children: [
                _LevelBadge(level: level),
                SizedBox(width: t.space2),
                Container(
                  width: 110,
                  height: 7,
                  decoration: BoxDecoration(
                    color: t.surfaceSunken,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: t.borderDefault),
                  ),
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: xp,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4),
                        gradient: const LinearGradient(
                          colors: [FwPalette.solar500, FwPalette.solar300],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}

class _LevelBadge extends StatelessWidget {
  const _LevelBadge({required this.level});
  final int level;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: FwPalette.rust50,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: FwPalette.rust200),
      ),
      child: Text(
        'NÍVEL $level',
        style: GoogleFonts.rajdhani(
          fontWeight: FontWeight.w700,
          fontSize: 10.5,
          letterSpacing: 0.5,
          color: FwPalette.rust700,
        ),
      ),
    );
  }
}

class _ResourceStrip extends StatelessWidget {
  const _ResourceStrip({required this.resources});
  final Resources resources;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).extension<DsTokens>()!;
    final money = NumberFormat.decimalPattern(Localizations.localeOf(context).languageCode);

    final chips = <Widget>[
      _ResourceChip(
        icon: Icons.paid_outlined,
        color: t.solar,
        label: 'Fert\$',
        value: money.format(resources.fertCoins),
        perHour: resources.fertPerHour,
      ),
      for (final s in resources.stocks)
        _ResourceChip(
          icon: _iconFor(s.id),
          color: _colorFor(s.id, t),
          label: s.label,
          value: money.format(s.amount),
          capacity: s.capacity == null ? null : money.format(s.capacity),
          perHour: s.perHour,
        ),
    ];

    return Center(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (var i = 0; i < chips.length; i++) ...[
              if (i > 0) SizedBox(width: t.space2),
              chips[i],
            ],
          ],
        ),
      ),
    );
  }

  IconData _iconFor(String id) => switch (id) {
        'oxygen' => Icons.air_outlined,
        'water' => Icons.water_drop_outlined,
        'biomass' => Icons.eco_outlined,
        'energy' => Icons.bolt_outlined,
        'metalore' => Icons.terrain_outlined,
        'alloys' => Icons.view_in_ar_outlined,
        'biofuel' => Icons.local_fire_department_outlined,
        'electronics' => Icons.memory_outlined,
        _ => Icons.inventory_2_outlined,
      };

  Color _colorFor(String id, DsTokens t) => switch (id) {
        'oxygen' => FwPalette.teal300,
        'water' => t.teal,
        'biomass' => t.success,
        'energy' => t.warning,
        'metalore' => FwPalette.gray700,
        'alloys' => FwPalette.rust600,
        'biofuel' => FwPalette.green800,
        'electronics' => t.federation,
        _ => t.textSecondary,
      };
}

class _ResourceChip extends StatelessWidget {
  const _ResourceChip({
    required this.icon,
    required this.color,
    required this.label,
    required this.value,
    this.capacity,
    this.perHour = 0,
  });

  final IconData icon;
  final Color color;
  final String label;
  final String value;
  final String? capacity;
  final int perHour;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).extension<DsTokens>()!;
    final up = perHour >= 0;
    final deltaColor = up ? t.deltaUp : t.deltaDown;
    final semantic = '$label: $value${capacity != null ? ' de $capacity' : ''}, '
        '${up ? 'mais' : 'menos'} ${perHour.abs()} por hora';

    return Semantics(
      label: semantic,
      child: Container(
        padding: EdgeInsets.fromLTRB(t.space1, t.space1, t.space3, t.space1),
        decoration: BoxDecoration(
          color: FwPalette.gray50,
          borderRadius: BorderRadius.circular(t.radiusMd),
          border: Border.all(color: t.borderDefault),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(t.radiusSm),
              ),
              child: Icon(icon, size: 16, color: color),
            ),
            SizedBox(width: t.space2),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      value,
                      style: GoogleFonts.rajdhani(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                        height: 1,
                        color: FwPalette.gray900,
                      ),
                    ),
                    if (capacity != null)
                      Text(
                        '/$capacity',
                        style: TextStyle(fontSize: 10.5, color: t.textSecondary, height: 1),
                      ),
                  ],
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Icon(up ? Icons.arrow_drop_up : Icons.arrow_drop_down, size: 12, color: deltaColor),
                    Text(
                      '${perHour.abs()}/h',
                      style: GoogleFonts.rajdhani(
                        fontWeight: FontWeight.w600,
                        fontSize: 10.5,
                        height: 1,
                        color: deltaColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _PlayerCluster extends ConsumerWidget {
  const _PlayerCluster();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = Theme.of(context).extension<DsTokens>()!;
    final unread = ref.watch(notificationsProvider).maybeWhen(
          data: (c) => c.unreadCount,
          orElse: () => 0,
        );
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _IconBtn(
          icon: Icons.notifications_none,
          badgeCount: unread,
          onTap: () => context.go('/map/notifications'),
        ),
        SizedBox(width: t.space2),
        const _IconBtn(icon: Icons.help_outline),
        SizedBox(width: t.space2),
        const _LanguageMenu(),
        SizedBox(width: t.space3),
        Container(
          padding: EdgeInsets.fromLTRB(t.space1, t.space1, t.space3, t.space1),
          decoration: BoxDecoration(
            color: FwPalette.gray50,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: t.borderDefault),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ClipOval(
                child: SizedBox(
                  width: 32,
                  height: 32,
                  child: Image.asset(
                    'assets/images/avatar-vale-v1.png',
                    fit: BoxFit.cover,
                    filterQuality: FilterQuality.medium,
                    errorBuilder: (_, __, ___) => const DecoratedBox(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(colors: [FwPalette.teal500, FwPalette.teal700]),
                      ),
                      child: Icon(Icons.person, color: Colors.white, size: 19),
                    ),
                  ),
                ),
              ),
              SizedBox(width: t.space2),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Cmdt. Vale',
                      style: GoogleFonts.rajdhani(
                          fontWeight: FontWeight.w700, fontSize: 13, height: 1, color: FwPalette.gray900)),
                  Text('Governadora',
                      style: TextStyle(fontSize: 10, color: t.textSecondary, height: 1.3)),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _IconBtn extends StatelessWidget {
  const _IconBtn({required this.icon, this.badgeCount = 0, this.onTap});
  final IconData icon;
  final int badgeCount;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).extension<DsTokens>()!;
    final content = Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: FwPalette.gray50,
            borderRadius: BorderRadius.circular(t.radiusMd),
            border: Border.all(color: t.borderDefault),
          ),
          child: Icon(icon, size: 18, color: FwPalette.gray700),
        ),
        if (badgeCount > 0)
          Positioned(
            top: -3,
            right: -3,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
              constraints: const BoxConstraints(minWidth: 16),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: FwPalette.rust600,
                borderRadius: BorderRadius.circular(9),
                border: Border.all(color: FwPalette.gray50, width: 1.5),
              ),
              child: Text(badgeCount > 9 ? '9+' : '$badgeCount',
                  style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: Colors.white)),
            ),
          ),
      ],
    );
    if (onTap == null) return content;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(t.radiusMd),
      child: content,
    );
  }
}

/// Seletor de idioma (§11): troca PT-BR/ES/EN na hora via [localeProvider].
class _LanguageMenu extends ConsumerWidget {
  const _LanguageMenu();

  static const _langs = [('pt', 'Português'), ('es', 'Español'), ('en', 'English')];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final code = ref.watch(localeProvider)?.languageCode ?? 'pt';
    final l10n = AppLocalizations.of(context);
    return PopupMenuButton<String>(
      tooltip: l10n.settingsLanguage,
      position: PopupMenuPosition.under,
      onSelected: (c) => ref.read(localeProvider.notifier).set(Locale(c)),
      itemBuilder: (_) => [
        for (final (c, name) in _langs)
          CheckedPopupMenuItem<String>(value: c, checked: c == code, child: Text(name)),
      ],
      child: const _IconBtn(icon: Icons.language_outlined),
    );
  }
}
