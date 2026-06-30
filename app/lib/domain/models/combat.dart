import 'package:flutter/foundation.dart';

/// Atributos da Sentinela por nível (GDD v29 §27.1). Robô Minerador como
/// defensor improvisado tem 25% da defesa da Sentinela do mesmo nível (§27.2).
class SentinelSpec {
  const SentinelSpec(this.level, this.def, this.atk);
  final int level;
  final int def;
  final int atk;
}

const List<SentinelSpec> kSentinelSpecs = [
  SentinelSpec(1, 100, 80),
  SentinelSpec(2, 150, 120),
  SentinelSpec(3, 225, 180),
  SentinelSpec(4, 338, 270),
  SentinelSpec(5, 506, 405),
];

SentinelSpec _specFor(int level) =>
    kSentinelSpecs[(level.clamp(1, kSentinelSpecs.length) - 1)];

int sentinelDef(int level) => _specFor(level).def;
int sentinelAtk(int level) => _specFor(level).atk;
int roboDef(int level) => (sentinelDef(level) * 0.25).round();

/// Custo de construção da Sentinela por nível — curva 1.65× (GDD §27.1).
class SentinelCost {
  const SentinelCost(this.alloys, this.electronics, this.metalore, this.niobium);
  final int alloys;
  final int electronics;
  final int metalore;
  final int niobium; // Nióbio Alienígena (raro)
}

const List<SentinelCost> kSentinelCosts = [
  SentinelCost(100, 50, 20, 3),
  SentinelCost(165, 82, 33, 5),
  SentinelCost(272, 136, 54, 8),
  SentinelCost(449, 225, 90, 13),
  SentinelCost(741, 371, 148, 22),
];

/// Tipo de unidade em combate.
enum UnitType { sentinel, robo }

UnitType _unitFrom(String? s) => s == 'robo' ? UnitType.robo : UnitType.sentinel;

/// Uma pilha de unidades (tipo + nível + quantidade).
@immutable
class UnitStack {
  const UnitStack({required this.type, required this.level, required this.count});
  final UnitType type;
  final int level;
  final int count;

  String get label => type == UnitType.sentinel ? 'Sentinela' : 'Robô Minerador';
  int get unitDef => type == UnitType.sentinel ? sentinelDef(level) : roboDef(level);
  int get unitAtk => type == UnitType.sentinel ? sentinelAtk(level) : 0; // robô não ataca (§27.2)
  int get totalDef => unitDef * count;
  int get totalAtk => unitAtk * count;

  factory UnitStack.fromJson(Map<String, dynamic> j) => UnitStack(
        type: _unitFrom(j['type'] as String?),
        level: j['level'] as int? ?? 1,
        count: j['count'] as int? ?? 0,
      );
}

/// Custo diário de manutenção territorial (GDD §27.12).
@immutable
class MaintenanceCost {
  const MaintenanceCost({this.biomass = 0, this.energy = 0, this.alloys = 0, this.components = 0});
  final int biomass;
  final int energy;
  final int alloys;
  final int components;

  factory MaintenanceCost.fromJson(Map<String, dynamic> j) => MaintenanceCost(
        biomass: j['biomass'] as int? ?? 0,
        energy: j['energy'] as int? ?? 0,
        alloys: j['alloys'] as int? ?? 0,
        components: j['components'] as int? ?? 0,
      );

  List<(String, int)> get lines => [
        if (biomass > 0) ('Biomassa', biomass),
        if (energy > 0) ('Energia', energy),
        if (alloys > 0) ('Ligas Metálicas', alloys),
        if (components > 0) ('Componentes', components),
      ];
}

/// Desfecho estimado de um ataque, conforme os cenários do GDD §27.5.
enum CombatForecast { attackerAdvantage, balanced, defenderAdvantage }

/// Classifica a estimativa pela razão Força Ofensiva ÷ Força Defensiva (§27.5):
/// muito superior → ~4 rodadas; equilibrado → ~12 rodadas; inferior → destruído.
CombatForecast forecastFor(double attack, double defense) {
  if (defense <= 0) return CombatForecast.attackerAdvantage;
  final ratio = attack / defense;
  if (ratio >= 1.6) return CombatForecast.attackerAdvantage;
  if (ratio >= 0.7) return CombatForecast.balanced;
  return CombatForecast.defenderAdvantage;
}

/// Estado de combate de uma zona (mock, GDD §27).
@immutable
class CombatState {
  const CombatState({
    required this.zoneLevel,
    required this.garrison,
    required this.yourUnits,
    required this.constructionBonusPct,
    required this.maintenance,
    required this.maintenancePaid,
    required this.noviceProtected,
    required this.noviceDaysLeft,
    required this.cooldownHours,
    required this.lootPct,
  });

  final int zoneLevel;
  final List<UnitStack> garrison; // unidades defendendo a zona
  final List<UnitStack> yourUnits; // suas Sentinelas disponíveis p/ atacar
  final double constructionBonusPct; // bônus de Muralha/Bastião/Torre (§27.3)
  final MaintenanceCost maintenance;
  final bool maintenancePaid;
  final bool noviceProtected; // dono nos primeiros 20 dias (§27.11)
  final int noviceDaysLeft;
  final int cooldownHours; // 0 = pode atacar; >0 = cooldown ativo (§27.10)
  final int lootPct; // saque ao vencer (§27.8)

  /// Força Defensiva Total = Σ defesa × (1 + bônus de construção) — §27.3.
  double get defenseTotal {
    final base = garrison.fold<int>(0, (a, u) => a + u.totalDef);
    return base * (1 + constructionBonusPct / 100);
  }

  /// Força Ofensiva Total = Σ ataque das Sentinelas enviadas — §27.3.
  double get attackTotal => yourUnits.fold<int>(0, (a, u) => a + u.totalAtk).toDouble();

  CombatForecast get forecast => forecastFor(attackTotal, defenseTotal);

  factory CombatState.fromJson(Map<String, dynamic> j) => CombatState(
        zoneLevel: j['zoneLevel'] as int? ?? 1,
        garrison: (j['garrison'] as List<dynamic>? ?? const [])
            .map((e) => UnitStack.fromJson(e as Map<String, dynamic>))
            .toList(),
        yourUnits: (j['yourUnits'] as List<dynamic>? ?? const [])
            .map((e) => UnitStack.fromJson(e as Map<String, dynamic>))
            .toList(),
        constructionBonusPct: (j['constructionBonusPct'] as num?)?.toDouble() ?? 0,
        maintenance: MaintenanceCost.fromJson(j['maintenance'] as Map<String, dynamic>? ?? const {}),
        maintenancePaid: j['maintenancePaid'] as bool? ?? true,
        noviceProtected: j['noviceProtected'] as bool? ?? false,
        noviceDaysLeft: j['noviceDaysLeft'] as int? ?? 0,
        cooldownHours: j['cooldownHours'] as int? ?? 0,
        lootPct: j['lootPct'] as int? ?? 50,
      );
}
