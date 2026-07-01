import 'package:flutter/foundation.dart';

/// Atmosfera de cada lua (§12.2).
enum MoonAtmosphere { similar, none, toxic }

MoonAtmosphere _atmosphereFrom(String? s) => switch (s) {
      'similar' => MoonAtmosphere.similar,
      'toxic' => MoonAtmosphere.toxic,
      _ => MoonAtmosphere.none,
    };

/// Categoria de um boletim do Telescópio Gagarin (§12.1).
enum BulletinKind { moon, atmosphere, resource, anomaly }

BulletinKind _bulletinKindFrom(String? s) => switch (s) {
      'atmosphere' => BulletinKind.atmosphere,
      'resource' => BulletinKind.resource,
      'anomaly' => BulletinKind.anomaly,
      _ => BulletinKind.moon,
    };

/// Uma das 8 luas de Fertways (§12.2 / §28.2). Homenageia um pioneiro da
/// exploração espacial e está associada a um recurso raro, explorável apenas
/// na Temporada 2.
@immutable
class Moon {
  const Moon({
    required this.id,
    required this.name,
    required this.honoree,
    required this.honoreeNote,
    required this.atmosphere,
    required this.rareResourceId,
    required this.rareResource,
    required this.profile,
    required this.t2Reading,
    this.mystery = false,
  });

  final String id;
  final String name;
  final String honoree;
  final String honoreeNote;
  final MoonAtmosphere atmosphere;

  /// Id do recurso raro para `resourceColor`/`resourceIcon`.
  final String rareResourceId;

  /// Nome exibido do recurso raro associado.
  final String rareResource;
  final String profile;
  final String t2Reading;

  /// Laika — mistério narrativo (§12.2).
  final bool mystery;

  factory Moon.fromJson(Map<String, dynamic> j) => Moon(
        id: j['id'] as String,
        name: j['name'] as String? ?? '',
        honoree: j['honoree'] as String? ?? '',
        honoreeNote: j['honoreeNote'] as String? ?? '',
        atmosphere: _atmosphereFrom(j['atmosphere'] as String?),
        rareResourceId: j['rareResourceId'] as String? ?? '',
        rareResource: j['rareResource'] as String? ?? '',
        profile: j['profile'] as String? ?? '',
        t2Reading: j['t2Reading'] as String? ?? '',
        mystery: j['mystery'] as bool? ?? false,
      );
}

/// Boletim publicado pelo Telescópio Gagarin na Central de Pesquisas e
/// Notícias (§12.1) a cada 2–4 dias.
@immutable
class GagarinBulletin {
  const GagarinBulletin({
    required this.id,
    required this.cycle,
    required this.kind,
    required this.title,
    required this.body,
    required this.time,
    this.moonId = '',
  });

  final String id;
  final String cycle;
  final BulletinKind kind;
  final String title;
  final String body;
  final String time;
  final String moonId;

  factory GagarinBulletin.fromJson(Map<String, dynamic> j) => GagarinBulletin(
        id: j['id'] as String,
        cycle: j['cycle'] as String? ?? '',
        kind: _bulletinKindFrom(j['kind'] as String?),
        title: j['title'] as String? ?? '',
        body: j['body'] as String? ?? '',
        time: j['time'] as String? ?? '',
        moonId: j['moonId'] as String? ?? '',
      );
}

/// Estado da Exploração Lunar (§12): status do Telescópio Gagarin, boletins,
/// catálogo das 8 luas e progresso dos gatilhos da Temporada 2. Fundação
/// narrativa — a exploração lunar em si só abre na T2 (§12.4).
@immutable
class LunarExploration {
  const LunarExploration({
    required this.gagarinActive,
    required this.playersRegistered,
    required this.playersTrigger,
    required this.daysElapsed,
    required this.daysTrigger,
    required this.bulletinFrequency,
    required this.terraformPercent,
    required this.terraformTrigger,
    required this.orbitWindowActive,
    required this.bulletins,
    required this.moons,
  });

  final bool gagarinActive;
  final int playersRegistered;
  final int playersTrigger;
  final int daysElapsed;
  final int daysTrigger;
  final String bulletinFrequency;

  /// Progresso da terraformação global (0–100). Atinge o [terraformTrigger]
  /// para disparar o gatilho oficial da Temporada 2 (§12.3).
  final int terraformPercent;
  final int terraformTrigger;

  /// Evento "Janela de Órbita Lunar" ativo (§12.3).
  final bool orbitWindowActive;

  final List<GagarinBulletin> bulletins;
  final List<Moon> moons;

  /// Fração de progresso até o gatilho de ativação do Gagarin — o que vier
  /// primeiro: jogadores cadastrados OU dias de servidor (§12.1).
  double get activationFraction {
    final byPlayers = playersTrigger == 0 ? 0.0 : playersRegistered / playersTrigger;
    final byDays = daysTrigger == 0 ? 0.0 : daysElapsed / daysTrigger;
    return (byPlayers > byDays ? byPlayers : byDays).clamp(0.0, 1.0);
  }

  double get terraformFraction =>
      terraformTrigger == 0 ? 0.0 : (terraformPercent / terraformTrigger).clamp(0.0, 1.0);

  bool get season2Unlocked => terraformPercent >= terraformTrigger;

  factory LunarExploration.fromJson(Map<String, dynamic> j) => LunarExploration(
        gagarinActive: j['gagarinActive'] as bool? ?? false,
        playersRegistered: j['playersRegistered'] as int? ?? 0,
        playersTrigger: j['playersTrigger'] as int? ?? 50,
        daysElapsed: j['daysElapsed'] as int? ?? 0,
        daysTrigger: j['daysTrigger'] as int? ?? 45,
        bulletinFrequency: j['bulletinFrequency'] as String? ?? 'a cada 2–4 dias',
        terraformPercent: j['terraformPercent'] as int? ?? 0,
        terraformTrigger: j['terraformTrigger'] as int? ?? 75,
        orbitWindowActive: j['orbitWindowActive'] as bool? ?? false,
        bulletins: (j['bulletins'] as List<dynamic>? ?? const [])
            .map((e) => GagarinBulletin.fromJson(e as Map<String, dynamic>))
            .toList(),
        moons: (j['moons'] as List<dynamic>? ?? const [])
            .map((e) => Moon.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}
