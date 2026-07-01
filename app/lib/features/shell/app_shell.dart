import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme/ds_colors.dart';
import '../../app/theme/ds_tokens.dart';
import '../../l10n/app_localizations.dart';
import '../hud/resource_hud.dart';

/// Shell do jogo (direção Solar Frontier): barra de recursos no topo (full
/// width), NavigationRail à esquerda (web desktop) / NavigationBar no Android,
/// e barra de ações inferior.
class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  static const _wideBreakpoint = 900.0;

  void _go(int index) => navigationShell.goBranch(
        index,
        initialLocation: index == navigationShell.currentIndex,
      );

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final t = Theme.of(context).extension<DsTokens>()!;
    final destinations = <_Dest>[
      _Dest(l10n.navMap, Icons.map_outlined, Icons.map),
      _Dest(l10n.navCapital, Icons.apartment_outlined, Icons.apartment),
      _Dest(l10n.navMarket, Icons.storefront_outlined, Icons.storefront),
      _Dest(l10n.navSpaceport, Icons.rocket_launch_outlined, Icons.rocket_launch),
      _Dest(l10n.navProfile, Icons.flag_outlined, Icons.flag),
    ];

    return Scaffold(
      body: Column(
        children: [
          const TopResourceBar(),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth >= _wideBreakpoint) {
                  return Row(
                    children: [
                      NavigationRail(
                        selectedIndex: navigationShell.currentIndex,
                        onDestinationSelected: _go,
                        labelType: NavigationRailLabelType.all,
                        destinations: [
                          for (final d in destinations)
                            NavigationRailDestination(
                              icon: Icon(d.icon),
                              selectedIcon: Icon(d.selectedIcon),
                              label: Text(d.label),
                            ),
                        ],
                      ),
                      VerticalDivider(width: 1, color: t.borderDefault),
                      Expanded(child: navigationShell),
                    ],
                  );
                }
                return navigationShell;
              },
            ),
          ),
          _BottomBar(isWide: MediaQuery.sizeOf(context).width >= _wideBreakpoint, onNav: _go, current: navigationShell.currentIndex, destinations: destinations),
        ],
      ),
    );
  }
}

class _BottomBar extends StatelessWidget {
  const _BottomBar({
    required this.isWide,
    required this.onNav,
    required this.current,
    required this.destinations,
  });

  final bool isWide;
  final void Function(int) onNav;
  final int current;
  final List<_Dest> destinations;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).extension<DsTokens>()!;
    final scheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);

    // Narrow: barra de navegação principal embaixo.
    if (!isWide) {
      return NavigationBar(
        selectedIndex: current,
        onDestinationSelected: onNav,
        destinations: [
          for (final d in destinations)
            NavigationDestination(
              icon: Icon(d.icon),
              selectedIcon: Icon(d.selectedIcon),
              label: d.label,
            ),
        ],
      );
    }

    // Desktop: barra de ações secundárias.
    final actions = <(_ShellAction, String, IconData)>[
      (_ShellAction.build, l10n.actionBuild, Icons.add_box_outlined),
      (_ShellAction.recruit, l10n.actionRecruit, Icons.groups_outlined),
      (_ShellAction.research, l10n.actionResearch, Icons.science_outlined),
      (_ShellAction.reports, l10n.actionReports, Icons.description_outlined),
      (_ShellAction.missions, l10n.actionMissions, Icons.flag_circle_outlined),
      (_ShellAction.messages, l10n.actionMessages, Icons.mail_outline),
    ];
    void onAction(_ShellAction kind, String label) {
      switch (kind) {
        case _ShellAction.messages:
          context.go('/map/messages');
        case _ShellAction.missions:
          context.go('/map/missions');
        default:
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.comingSoonAction(label)),
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 2),
            ),
          );
      }
    }

    return Container(
      height: 46,
      decoration: BoxDecoration(
        color: scheme.surface,
        border: Border(top: BorderSide(color: t.borderDefault)),
      ),
      padding: EdgeInsets.symmetric(horizontal: t.space4),
      child: Row(
        children: [
          for (final a in actions) ...[
            _ActionItem(label: a.$2, icon: a.$3, onTap: () => onAction(a.$1, a.$2)),
            SizedBox(width: t.space4),
          ],
          const Spacer(),
          const SizedBox(width: 8, height: 8, child: DecoratedBox(decoration: BoxDecoration(color: FwPalette.green500, shape: BoxShape.circle))),
          SizedBox(width: t.space2),
          Text(l10n.statusOnline, style: TextStyle(fontSize: 11, color: t.textSecondary)),
        ],
      ),
    );
  }
}

class _ActionItem extends StatelessWidget {
  const _ActionItem({required this.label, required this.icon, this.onTap});
  final String label;
  final IconData icon;
  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).extension<DsTokens>()!;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(t.radiusSm),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: t.space1, vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: FwPalette.gray700),
            SizedBox(width: t.space1),
            Text(label, style: const TextStyle(fontSize: 12, color: FwPalette.gray700, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}

class _Dest {
  const _Dest(this.label, this.icon, this.selectedIcon);
  final String label;
  final IconData icon;
  final IconData selectedIcon;
}

/// Ações da barra inferior (chave estável — o roteamento não depende do rótulo
/// traduzido).
enum _ShellAction { build, recruit, research, reports, missions, messages }
