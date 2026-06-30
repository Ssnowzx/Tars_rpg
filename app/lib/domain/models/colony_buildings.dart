import 'package:flutter/foundation.dart';

/// Categoria de construção da colônia (Slot) — GDD v21 §17.
/// Produção (água/metais/biomassa/energia/compostos) alimenta os 5 recursos do HUD.
enum BuildingCategory {
  habitat, // Estrutura de Sobrevivência (núcleo)
  oxygen, // Gerador de Atmosfera
  water, // Captação de Água
  metals, // Oficina → Ligas Metálicas
  rawmetal, // Mina Local → Metal Bruto (GDD v29 §24.4)
  biomass, // Fazenda
  energy, // Reator de Energia
  components, // Refinaria Química → Compostos Químicos
  biofuel, // Destilaria → Biocombustível (GDD v29 §24.6)
  military, // Quartel / Torre de Defesa
  research, // Laboratório
  transport, // Central de Transportes / Plataforma de Pouso
  special, // construção de especialização
  empty, // slot livre (construível)
}

BuildingCategory _categoryFrom(String s) => switch (s) {
      'habitat' => BuildingCategory.habitat,
      'oxygen' => BuildingCategory.oxygen,
      'water' => BuildingCategory.water,
      'metals' => BuildingCategory.metals,
      'rawmetal' => BuildingCategory.rawmetal,
      'biomass' => BuildingCategory.biomass,
      'energy' => BuildingCategory.energy,
      'components' => BuildingCategory.components,
      'biofuel' => BuildingCategory.biofuel,
      'military' => BuildingCategory.military,
      'research' => BuildingCategory.research,
      'transport' => BuildingCategory.transport,
      'special' => BuildingCategory.special,
      _ => BuildingCategory.empty,
    };

/// Uma construção no Slot (base) do colono.
@immutable
class ColonyBuilding {
  const ColonyBuilding({
    required this.id,
    required this.name,
    required this.category,
    required this.level,
    required this.dx,
    required this.dy,
    this.perHour = 0,
    this.built = true,
  });

  final String id;
  final String name;
  final BuildingCategory category;
  final int level;
  final double dx;
  final double dy;
  final int perHour; // produção líquida/h (só categorias de produção)
  final bool built;

  bool get isFree => !built || category == BuildingCategory.empty;
  bool get isHabitat => category == BuildingCategory.habitat;
  bool get isProduction => switch (category) {
        BuildingCategory.oxygen ||
        BuildingCategory.water ||
        BuildingCategory.metals ||
        BuildingCategory.rawmetal ||
        BuildingCategory.biomass ||
        BuildingCategory.energy ||
        BuildingCategory.components ||
        BuildingCategory.biofuel =>
          true,
        _ => false,
      };

  /// Construção essencial subsidiada pelo Governo Central até o nível 3 (§24.7).
  bool get isEssential => switch (category) {
        BuildingCategory.habitat ||
        BuildingCategory.oxygen ||
        BuildingCategory.water ||
        BuildingCategory.biomass ||
        BuildingCategory.energy =>
          true,
        _ => false,
      };

  /// Está dentro da faixa subsidiada (essencial até nível 3, §24.7).
  bool get isSubsidized => isEssential && level <= 3;

  factory ColonyBuilding.fromJson(Map<String, dynamic> j) => ColonyBuilding(
        id: j['id'] as String,
        name: j['name'] as String,
        category: _categoryFrom(j['category'] as String? ?? 'empty'),
        level: j['level'] as int? ?? 0,
        dx: (j['dx'] as num).toDouble(),
        dy: (j['dy'] as num).toDouble(),
        perHour: j['perHour'] as int? ?? 0,
        built: j['built'] as bool? ?? true,
      );
}

/// A base (Slot) do colono: nome, especialização e construções (GDD v21 §17).
@immutable
class ColonyBase {
  const ColonyBase({
    required this.name,
    required this.specialization,
    required this.buildings,
  });

  final String name;
  final String specialization; // ex.: "Hídrica"
  final List<ColonyBuilding> buildings;

  int get builtCount => buildings.where((b) => b.built && !b.isHabitat).length;
  int get freeCount => buildings.where((b) => b.isFree).length;

  factory ColonyBase.fromJson(Map<String, dynamic> j) => ColonyBase(
        name: j['name'] as String? ?? 'Colônia',
        specialization: j['specialization'] as String? ?? '',
        buildings: (j['buildings'] as List<dynamic>? ?? const [])
            .map((e) => ColonyBuilding.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}
