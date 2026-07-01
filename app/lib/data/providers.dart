import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/models/auction.dart';
import '../domain/models/chat.dart';
import '../domain/models/colony_buildings.dart';
import '../domain/models/combat.dart';
import '../domain/models/dispute.dart';
import '../domain/models/federation.dart';
import '../domain/models/fleet.dart';
import '../domain/models/institution_slot.dart';
import '../domain/models/informal_trade.dart';
import '../domain/models/lunar.dart';
import '../domain/models/market.dart';
import '../domain/models/ministry.dart';
import '../domain/models/mission.dart';
import '../domain/models/notification.dart';
import '../domain/models/public_office.dart';
import '../domain/models/planet_models.dart';
import '../domain/models/player_profile.dart';
import '../domain/models/resources.dart';
import '../domain/models/spaceport.dart';
import '../domain/models/terraform.dart';
import '../domain/models/war_ranking.dart';
import '../domain/models/world_models.dart';
import '../domain/repositories/auction_repository.dart';
import '../domain/repositories/capital_repository.dart';
import '../domain/repositories/chat_repository.dart';
import '../domain/repositories/combat_repository.dart';
import '../domain/repositories/federation_repository.dart';
import '../domain/repositories/fleet_repository.dart';
import '../domain/repositories/lunar_repository.dart';
import '../domain/repositories/market_repository.dart';
import '../domain/repositories/ministry_repository.dart';
import '../domain/repositories/mission_repository.dart';
import '../domain/repositories/notification_repository.dart';
import '../domain/repositories/profile_repository.dart';
import '../domain/repositories/public_office_repository.dart';
import '../domain/repositories/ranking_repository.dart';
import '../domain/repositories/reputation_repository.dart';
import '../domain/repositories/spaceport_repository.dart';
import '../domain/repositories/terraform_repository.dart';
import '../domain/repositories/world_repository.dart';
import 'api/api_auction_repository.dart';
import 'api/api_capital_repository.dart';
import 'api/api_chat_repository.dart';
import 'api/api_client.dart';
import 'api/api_combat_repository.dart';
import 'api/api_federation_repository.dart';
import 'api/api_fleet_repository.dart';
import 'api/api_lunar_repository.dart';
import 'api/api_market_repository.dart';
import 'api/api_ministry_repository.dart';
import 'api/api_mission_repository.dart';
import 'api/api_notification_repository.dart';
import 'api/api_profile_repository.dart';
import 'api/api_public_office_repository.dart';
import 'api/api_ranking_repository.dart';
import 'api/api_reputation_repository.dart';
import 'api/api_spaceport_repository.dart';
import 'api/api_terraform_repository.dart';
import 'api/api_world_repository.dart';

/// Ponto único de binding interface → implementação. **Todos** os repositórios
/// usam implementações `Api...` (backend NestJS) — não há mais mock em runtime.
/// Dados dinâmicos vêm de endpoints próprios (/resources, /colony, /build-queue,
/// /me, /spaceport, /lunar, /terraform); a config canônica do jogo (Capital,
/// ministérios, mapa-planeta, boards de mercado/leilões/frota/etc.) vem de
/// /config/:key.
final capitalRepositoryProvider = Provider<CapitalRepository>(
  (ref) => ApiCapitalRepository(ref.watch(dioProvider)),
);

final worldRepositoryProvider = Provider<WorldRepository>(
  (ref) => ApiWorldRepository(ref.watch(dioProvider)),
);

final marketRepositoryProvider = Provider<MarketRepository>(
  (ref) => ApiMarketRepository(ref.watch(dioProvider)),
);

final rankingRepositoryProvider = Provider<RankingRepository>(
  (ref) => ApiRankingRepository(ref.watch(dioProvider)),
);

final spaceportRepositoryProvider = Provider<SpaceportRepository>(
  (ref) => ApiSpaceportRepository(ref.watch(dioProvider)),
);

final profileRepositoryProvider = Provider<ProfileRepository>(
  (ref) => ApiProfileRepository(ref.watch(dioProvider)),
);

final ministryRepositoryProvider = Provider<MinistryRepository>(
  (ref) => ApiMinistryRepository(ref.watch(dioProvider)),
);

final resourcesProvider = FutureProvider<Resources>(
  (ref) => ref.watch(capitalRepositoryProvider).loadResources(),
);

final slotsProvider = FutureProvider<List<InstitutionSlot>>(
  (ref) => ref.watch(capitalRepositoryProvider).loadSlots(),
);

final colonyProvider = FutureProvider<ColonyState>(
  (ref) => ref.watch(worldRepositoryProvider).loadColony(),
);

final planetProvider = FutureProvider<PlanetState>(
  (ref) => ref.watch(worldRepositoryProvider).loadPlanet(),
);

final colonyBaseProvider = FutureProvider<ColonyBase>(
  (ref) => ref.watch(worldRepositoryProvider).loadColonyBase(),
);

final marketBoardProvider = FutureProvider<MarketBoard>(
  (ref) => ref.watch(marketRepositoryProvider).loadBoard(),
);

final informalBoardProvider = FutureProvider<InformalBoard>(
  (ref) => ref.watch(marketRepositoryProvider).loadInformalBoard(),
);

final warRankingsProvider = FutureProvider<WarRankings>(
  (ref) => ref.watch(rankingRepositoryProvider).loadWarRankings(),
);

final spaceportProvider = FutureProvider<SpaceportState>(
  (ref) => ref.watch(spaceportRepositoryProvider).loadSpaceport(),
);

final profileProvider = FutureProvider<PlayerProfile>(
  (ref) => ref.watch(profileRepositoryProvider).loadProfile(),
);

final ministriesProvider = FutureProvider<MinistriesData>(
  (ref) => ref.watch(ministryRepositoryProvider).loadMinistries(),
);

final combatRepositoryProvider = Provider<CombatRepository>(
  (ref) => ApiCombatRepository(ref.watch(dioProvider)),
);

final combatProvider = FutureProvider<CombatState>(
  (ref) => ref.watch(combatRepositoryProvider).loadCombat(),
);

final chatRepositoryProvider = Provider<ChatRepository>(
  (ref) => ApiChatRepository(ref.watch(dioProvider)),
);

final chatProvider = FutureProvider<ChatState>(
  (ref) => ref.watch(chatRepositoryProvider).loadChat(),
);

final federationRepositoryProvider = Provider<FederationRepository>(
  (ref) => ApiFederationRepository(ref.watch(dioProvider)),
);

final federationProvider = FutureProvider<Federation>(
  (ref) => ref.watch(federationRepositoryProvider).loadFederation(),
);

final reputationRepositoryProvider = Provider<ReputationRepository>(
  (ref) => ApiReputationRepository(ref.watch(dioProvider)),
);

final disputesProvider = FutureProvider<DisputeBoard>(
  (ref) => ref.watch(reputationRepositoryProvider).loadDisputes(),
);

final missionRepositoryProvider = Provider<MissionRepository>(
  (ref) => ApiMissionRepository(ref.watch(dioProvider)),
);

final missionBoardProvider = FutureProvider<MissionBoard>(
  (ref) => ref.watch(missionRepositoryProvider).loadBoard(),
);

final fleetRepositoryProvider = Provider<FleetRepository>(
  (ref) => ApiFleetRepository(ref.watch(dioProvider)),
);

final fleetProvider = FutureProvider<FleetBoard>(
  (ref) => ref.watch(fleetRepositoryProvider).loadFleet(),
);

final publicOfficeRepositoryProvider = Provider<PublicOfficeRepository>(
  (ref) => ApiPublicOfficeRepository(ref.watch(dioProvider)),
);

final publicOfficeProvider = FutureProvider<PublicOfficeBoard>(
  (ref) => ref.watch(publicOfficeRepositoryProvider).loadOffices(),
);

final auctionRepositoryProvider = Provider<AuctionRepository>(
  (ref) => ApiAuctionRepository(ref.watch(dioProvider)),
);

final auctionHouseProvider = FutureProvider<AuctionHouse>(
  (ref) => ref.watch(auctionRepositoryProvider).loadAuctions(),
);

final notificationRepositoryProvider = Provider<NotificationRepository>(
  (ref) => ApiNotificationRepository(ref.watch(dioProvider)),
);

final notificationsProvider = FutureProvider<NotificationCenter>(
  (ref) => ref.watch(notificationRepositoryProvider).loadNotifications(),
);

final lunarRepositoryProvider = Provider<LunarRepository>(
  (ref) => ApiLunarRepository(ref.watch(dioProvider)),
);

final lunarProvider = FutureProvider<LunarExploration>(
  (ref) => ref.watch(lunarRepositoryProvider).loadLunar(),
);

final terraformRepositoryProvider = Provider<TerraformRepository>(
  (ref) => ApiTerraformRepository(ref.watch(dioProvider)),
);

final terraformProvider = FutureProvider<TerraformState>(
  (ref) => ref.watch(terraformRepositoryProvider).loadTerraform(),
);

