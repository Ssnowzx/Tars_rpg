/// Categoria de instituição da Capital — dirige a codificação de cor
/// (sempre pareada com ícone + rótulo, nunca cor sozinha).
enum SlotCategory { administration, economy, military, research, reputation, transport, empty }

SlotCategory _categoryFrom(String s) => switch (s) {
      'administration' => SlotCategory.administration,
      'economy' => SlotCategory.economy,
      'military' => SlotCategory.military,
      'research' => SlotCategory.research,
      'reputation' => SlotCategory.reputation,
      'transport' => SlotCategory.transport,
      _ => SlotCategory.empty,
    };

/// Um dos 20 slots de instituição da Capital (GDD §2.1).
class InstitutionSlot {
  const InstitutionSlot({
    required this.index,
    required this.category,
    required this.installed,
    this.name,
    this.level = 0,
    this.kind,
  });

  final int index;
  final String? name;
  final SlotCategory category;
  final bool installed;
  final int level;

  /// Identidade estável da instituição (ex.: "treasury", "tributes") que liga
  /// o slot ao painel de ministério correto. Null para slots vagos.
  final String? kind;

  bool get isEmpty => !installed;

  factory InstitutionSlot.fromJson(Map<String, dynamic> json) => InstitutionSlot(
        index: json['index'] as int,
        name: json['name'] as String?,
        category: _categoryFrom(json['category'] as String? ?? 'empty'),
        installed: json['installed'] as bool? ?? false,
        level: json['level'] as int? ?? 0,
        kind: json['kind'] as String?,
      );
}
