import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../data/auth/auth_controller.dart';
import '../domain/models/institution_slot.dart';
import '../domain/models/planet_models.dart';
import '../features/auth/login_screen.dart';
import '../features/capital/capital_screen.dart';
import '../features/capital/ministries/ministry_screen.dart';
import '../features/capital/public_offices_screen.dart';
import '../features/colony/colony_screen.dart';
import '../features/federation/federation_screen.dart';
import '../features/fleet/fleet_screen.dart';
import '../features/lunar/lunar_screen.dart';
import '../features/market/auctions_screen.dart';
import '../features/market/informal_trade_screen.dart';
import '../features/market/market_screen.dart';
import '../features/messages/messages_screen.dart';
import '../features/missions/missions_screen.dart';
import '../features/notifications/notifications_screen.dart';
import '../features/profile/profile_screen.dart';
import '../features/rankings/rankings_screen.dart';
import '../features/shell/app_shell.dart';
import '../features/terraform/terraform_screen.dart';
import '../features/spaceport/spaceport_screen.dart';
import '../features/world_map/view/world_map_screen.dart';
import '../features/zone/zone_screen.dart';

final GlobalKey<NavigatorState> _rootKey = GlobalKey<NavigatorState>();

/// Redireciona para /login sem sessão; sai do /login quando autenticado.
class _AuthRefresh extends ChangeNotifier {
  _AuthRefresh(this._ref) {
    _ref.listen(authProvider, (_, __) => notifyListeners());
  }
  final Ref _ref;

  String? redirect(BuildContext context, GoRouterState state) {
    final authed = _ref.read(authProvider).isAuthenticated;
    final atLogin = state.matchedLocation == '/login';
    if (!authed) return atLogin ? null : '/login';
    if (atLogin) return '/map';
    return null;
  }
}

/// Roteador com gate de autenticação. Sub-rotas (colony, zone, rankings) são
/// drill-ins que mantêm o HUD/nav do shell.
final routerProvider = Provider<GoRouter>((ref) {
  final auth = _AuthRefresh(ref);
  return GoRouter(
    navigatorKey: _rootKey,
    initialLocation: '/map',
    refreshListenable: auth,
    redirect: auth.redirect,
    routes: [
      GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
      StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) => AppShell(navigationShell: navigationShell),
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/map',
              builder: (_, __) => const WorldMapScreen(),
              routes: [
                GoRoute(path: 'colony', builder: (_, __) => const ColonyScreen()),
                GoRoute(
                  path: 'zone',
                  builder: (_, state) => ZoneScreen(zone: state.extra as MapNode?),
                ),
                GoRoute(path: 'messages', builder: (_, __) => const MessagesScreen()),
                GoRoute(path: 'missions', builder: (_, __) => const MissionsScreen()),
                GoRoute(path: 'fleet', builder: (_, __) => const FleetScreen()),
                GoRoute(path: 'notifications', builder: (_, __) => const NotificationsScreen()),
                GoRoute(path: 'terraform', builder: (_, __) => const TerraformScreen()),
              ],
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/capital',
              builder: (_, __) => const CapitalScreen(),
              routes: [
                GoRoute(path: 'rankings', builder: (_, __) => const RankingsScreen()),
                GoRoute(path: 'offices', builder: (_, __) => const PublicOfficesScreen()),
                GoRoute(
                  path: 'ministry',
                  builder: (_, state) => MinistryScreen(slot: state.extra as InstitutionSlot?),
                ),
              ],
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/market',
              builder: (_, __) => const MarketScreen(),
              routes: [
                GoRoute(path: 'informal', builder: (_, __) => const InformalTradeScreen()),
                GoRoute(path: 'auctions', builder: (_, __) => const AuctionsScreen()),
              ],
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/spaceport',
              builder: (_, __) => const SpaceportScreen(),
              routes: [
                GoRoute(path: 'lunar', builder: (_, __) => const LunarScreen()),
              ],
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/profile',
              builder: (_, __) => const ProfileScreen(),
              routes: [
                GoRoute(path: 'federation', builder: (_, __) => const FederationScreen()),
              ],
            ),
          ],
        ),
        ],
      ),
    ],
  );
});
