/// Tipo de lote no mapa-mundo (dirige icone + cor de categoria).
enum PlotKind { capital, water, metals, biomass, energy, factory, ally, hostile, empty }

PlotKind _plotKindFrom(String s) => switch (s) {
      'capital' => PlotKind.capital,
      'water' => PlotKind.water,
      'metals' => PlotKind.metals,
      'biomass' => PlotKind.biomass,
      'energy' => PlotKind.energy,
      'factory' => PlotKind.factory,
      'ally' => PlotKind.ally,
      'hostile' => PlotKind.hostile,
      _ => PlotKind.empty,
    };

/// Um no de lote no mapa. dx/dy sao deslocamentos logicos a partir do centro
/// (Capital em 0,0) no espaco do mundo Flame.
class PlotNode {
  const PlotNode({
    required this.id,
    required this.name,
    required this.kind,
    required this.level,
    required this.dx,
    required this.dy,
    this.connected = true,
  });

  final String id;
  final String name;
  final PlotKind kind;
  final int level;
  final double dx;
  final double dy;
  final bool connected; // tem estrada ligando a Capital

  factory PlotNode.fromJson(Map<String, dynamic> j) => PlotNode(
        id: j['id'] as String,
        name: j['name'] as String,
        kind: _plotKindFrom(j['kind'] as String? ?? 'empty'),
        level: j['level'] as int? ?? 0,
        dx: (j['dx'] as num).toDouble(),
        dy: (j['dy'] as num).toDouble(),
        connected: j['connected'] as bool? ?? true,
      );
}

/// Cabecalho da colonia (barra superior).
class ColonyHeader {
  const ColonyHeader({
    required this.name,
    required this.sector,
    required this.level,
    required this.xp,
    required this.xpMax,
  });

  final String name;
  final String sector;
  final int level;
  final int xp;
  final int xpMax;

  double get xpFraction => xpMax == 0 ? 0 : (xp / xpMax).clamp(0, 1).toDouble();

  factory ColonyHeader.fromJson(Map<String, dynamic> j) => ColonyHeader(
        name: j['name'] as String,
        sector: j['sector'] as String? ?? '',
        level: j['level'] as int? ?? 0,
        xp: j['xp'] as int? ?? 0,
        xpMax: j['xpMax'] as int? ?? 1,
      );
}

/// Item da fila de construcao (painel "Construcao em andamento").
class BuildItem {
  const BuildItem({
    required this.id,
    required this.name,
    required this.kind,
    required this.fromLevel,
    required this.toLevel,
    required this.remaining,
    required this.progress,
  });

  final String id;
  final String name;
  final PlotKind kind;
  final int fromLevel;
  final int toLevel;
  final String remaining; // ex.: "00:00:31"
  final double progress; // 0..1

  factory BuildItem.fromJson(Map<String, dynamic> j) => BuildItem(
        id: j['id'] as String,
        name: j['name'] as String,
        kind: _plotKindFrom(j['kind'] as String? ?? 'empty'),
        fromLevel: j['fromLevel'] as int? ?? 0,
        toLevel: j['toLevel'] as int? ?? 0,
        remaining: j['remaining'] as String? ?? '',
        progress: ((j['progress'] as num?)?.toDouble() ?? 0).clamp(0, 1).toDouble(),
      );
}

/// Estado completo do mundo (mock).
class ColonyState {
  const ColonyState({required this.header, required this.plots, required this.construction});

  final ColonyHeader header;
  final List<PlotNode> plots;
  final List<BuildItem> construction;

  factory ColonyState.fromJson(Map<String, dynamic> j) => ColonyState(
        header: ColonyHeader.fromJson(j['colony'] as Map<String, dynamic>),
        plots: (j['plots'] as List<dynamic>)
            .map((e) => PlotNode.fromJson(e as Map<String, dynamic>))
            .toList(),
        construction: (j['construction'] as List<dynamic>? ?? [])
            .map((e) => BuildItem.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}
