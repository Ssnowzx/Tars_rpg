import 'package:flutter/foundation.dart';

/// Tipos de missão (GDD v29 §6): Tutoria, Diária, Semanal, Narrativa, Federação,
/// Guerra e Evento.
enum MissionCategory { tutorial, daily, weekly, narrative, federation, war, event }

MissionCategory _categoryFrom(String? s) => switch (s) {
      'tutorial' => MissionCategory.tutorial,
      'weekly' => MissionCategory.weekly,
      'narrative' => MissionCategory.narrative,
      'federation' => MissionCategory.federation,
      'war' => MissionCategory.war,
      'event' => MissionCategory.event,
      _ => MissionCategory.daily,
    };

/// Estado de uma missão. `completed` = pronta para resgatar; `claimed` = já
/// resgatada; `locked` = ainda bloqueada (divulgação progressiva §6).
enum MissionStatus { available, inProgress, completed, claimed, locked }

MissionStatus _statusFrom(String? s) => switch (s) {
      'inProgress' => MissionStatus.inProgress,
      'completed' => MissionStatus.completed,
      'claimed' => MissionStatus.claimed,
      'locked' => MissionStatus.locked,
      _ => MissionStatus.available,
    };

/// Uma missão (§6). `current`/`target` alimentam a barra de progresso; `reward`
/// já vem formatado (ex.: "+800 Fert\$ · +120 XP"); `timeLabel` traz a janela
/// (ex.: "Expira em 6h", "Dias 1–3", "Qua → Ter"); `rejectable` = pode ser
/// trocada (diárias têm 1 rejeição por dia, §6).
@immutable
class Mission {
  const Mission({
    required this.id,
    required this.category,
    required this.title,
    required this.description,
    required this.current,
    required this.target,
    required this.reward,
    required this.status,
    required this.timeLabel,
    this.rejectable = false,
  });

  final String id;
  final MissionCategory category;
  final String title;
  final String description;
  final int current;
  final int target;
  final String reward;
  final MissionStatus status;
  final String timeLabel;
  final bool rejectable;

  double get progress {
    if (status == MissionStatus.claimed || status == MissionStatus.completed) return 1;
    if (target <= 0) return 0;
    return (current / target).clamp(0, 1);
  }

  factory Mission.fromJson(Map<String, dynamic> j) => Mission(
        id: j['id'] as String,
        category: _categoryFrom(j['category'] as String?),
        title: j['title'] as String? ?? '',
        description: j['description'] as String? ?? '',
        current: (j['current'] as num?)?.toInt() ?? 0,
        target: (j['target'] as num?)?.toInt() ?? 0,
        reward: j['reward'] as String? ?? '',
        status: _statusFrom(j['status'] as String?),
        timeLabel: j['timeLabel'] as String? ?? '',
        rejectable: j['rejectable'] as bool? ?? false,
      );
}

/// Medalhas das conquistas (§6): Bronze, Prata, Ouro e Platina.
enum AchievementTier { bronze, silver, gold, platinum }

AchievementTier _tierFrom(String? s) => switch (s) {
      'silver' => AchievementTier.silver,
      'gold' => AchievementTier.gold,
      'platinum' => AchievementTier.platinum,
      _ => AchievementTier.bronze,
    };

/// Uma conquista (§6). `unlocked` = já obtida; senão `current`/`target` mostram
/// o quanto falta.
@immutable
class Achievement {
  const Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.tier,
    required this.current,
    required this.target,
    required this.unlocked,
  });

  final String id;
  final String title;
  final String description;
  final AchievementTier tier;
  final int current;
  final int target;
  final bool unlocked;

  double get progress {
    if (unlocked) return 1;
    if (target <= 0) return 0;
    return (current / target).clamp(0, 1);
  }

  factory Achievement.fromJson(Map<String, dynamic> j) => Achievement(
        id: j['id'] as String,
        title: j['title'] as String? ?? '',
        description: j['description'] as String? ?? '',
        tier: _tierFrom(j['tier'] as String?),
        current: (j['current'] as num?)?.toInt() ?? 0,
        target: (j['target'] as num?)?.toInt() ?? 0,
        unlocked: j['unlocked'] as bool? ?? false,
      );
}

/// Um evento ativo no servidor (§6/§12.1). `type` define ícone/cor (gagarin ·
/// war · market · storm · federation); `timeLabel` = tempo restante.
@immutable
class GameEvent {
  const GameEvent({
    required this.id,
    required this.type,
    required this.title,
    required this.description,
    required this.timeLabel,
    required this.active,
  });

  final String id;
  final String type;
  final String title;
  final String description;
  final String timeLabel;
  final bool active;

  factory GameEvent.fromJson(Map<String, dynamic> j) => GameEvent(
        id: j['id'] as String,
        type: j['type'] as String? ?? 'event',
        title: j['title'] as String? ?? '',
        description: j['description'] as String? ?? '',
        timeLabel: j['timeLabel'] as String? ?? '',
        active: j['active'] as bool? ?? true,
      );
}

/// Estado da central de Missões/Conquistas/Eventos (mock, §6). `dailyDone`/
/// `dailyTotal` e `streak` alimentam o resumo do topo.
@immutable
class MissionBoard {
  const MissionBoard({
    required this.dailyDone,
    required this.dailyTotal,
    required this.streak,
    required this.missions,
    required this.achievements,
    required this.events,
  });

  final int dailyDone;
  final int dailyTotal;
  final int streak; // dias consecutivos
  final List<Mission> missions;
  final List<Achievement> achievements;
  final List<GameEvent> events;

  int get claimable => missions.where((m) => m.status == MissionStatus.completed).length;
  int get unlockedAchievements => achievements.where((a) => a.unlocked).length;

  factory MissionBoard.fromJson(Map<String, dynamic> j) => MissionBoard(
        dailyDone: (j['dailyDone'] as num?)?.toInt() ?? 0,
        dailyTotal: (j['dailyTotal'] as num?)?.toInt() ?? 0,
        streak: (j['streak'] as num?)?.toInt() ?? 0,
        missions: (j['missions'] as List<dynamic>? ?? const [])
            .map((e) => Mission.fromJson(e as Map<String, dynamic>))
            .toList(),
        achievements: (j['achievements'] as List<dynamic>? ?? const [])
            .map((e) => Achievement.fromJson(e as Map<String, dynamic>))
            .toList(),
        events: (j['events'] as List<dynamic>? ?? const [])
            .map((e) => GameEvent.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}
