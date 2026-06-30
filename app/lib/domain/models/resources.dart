/// Tiers de recurso do Fertways (taxas de transferência: 3% / 2% / 1% — GDD §8.3).
enum ResourceTier { primary, secondary, rare }

ResourceTier _tierFrom(String s) => switch (s) {
      'primary' => ResourceTier.primary,
      'secondary' => ResourceTier.secondary,
      'rare' => ResourceTier.rare,
      _ => ResourceTier.primary,
    };

/// Estoque de um recurso nomeado (Água, Metais Ferrosos, Biomassa, …).
class ResourceStock {
  const ResourceStock({
    required this.id,
    required this.label,
    required this.amount,
    required this.tier,
    this.capacity,
    this.perHour = 0,
  });

  final String id;
  final String label;
  final int amount;
  final ResourceTier tier;
  final int? capacity; // capacidade de armazenamento (depósito)
  final int perHour; // produção líquida por hora (pode ser negativa)

  factory ResourceStock.fromJson(Map<String, dynamic> json) => ResourceStock(
        id: json['id'] as String,
        label: json['label'] as String,
        amount: json['amount'] as int,
        tier: _tierFrom(json['tier'] as String),
        capacity: json['capacity'] as int?,
        perHour: json['perHour'] as int? ?? 0,
      );
}

/// Saldo do colono: moeda mole Fert$ + estoques por tier.
class Resources {
  const Resources({required this.fertCoins, this.fertPerHour = 0, required this.stocks});

  final int fertCoins;
  final int fertPerHour;
  final List<ResourceStock> stocks;

  factory Resources.fromJson(Map<String, dynamic> json) => Resources(
        fertCoins: json['fertCoins'] as int,
        fertPerHour: json['fertPerHour'] as int? ?? 0,
        stocks: (json['stocks'] as List<dynamic>)
            .map((e) => ResourceStock.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}
