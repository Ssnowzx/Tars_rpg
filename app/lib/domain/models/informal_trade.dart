import 'package:flutter/foundation.dart';

/// Camada (tier) do recurso — define a alíquota de tributo na saída (§8.3).
enum ResourceTier { primary, secondary, rare }

ResourceTier _tierFrom(String? s) => switch (s) {
      'secondary' => ResourceTier.secondary,
      'rare' => ResourceTier.rare,
      _ => ResourceTier.primary,
    };

String tierLabel(ResourceTier t) => switch (t) {
      ResourceTier.primary => 'Primário',
      ResourceTier.secondary => 'Secundário',
      ResourceTier.rare => 'Raro',
    };

/// Desfecho de uma troca informal (GDD §8.2).
enum TradeOutcome { success, scam }

TradeOutcome _outcomeFrom(String? s) => s == 'scam' ? TradeOutcome.scam : TradeOutcome.success;

/// Um lado da troca: recurso + quantidade + camada (para o tributo).
@immutable
class TradeLeg {
  const TradeLeg({
    required this.resourceId,
    required this.label,
    required this.qty,
    required this.tier,
  });

  final String resourceId;
  final String label;
  final int qty;
  final ResourceTier tier;

  factory TradeLeg.fromJson(Map<String, dynamic> j) => TradeLeg(
        resourceId: j['resourceId'] as String,
        label: j['label'] as String,
        qty: j['qty'] as int? ?? 0,
        tier: _tierFrom(j['tier'] as String?),
      );
}

/// Especificação física de um veículo de carga (GDD §25.4/§25.6). Tempo e
/// energia são proporcionais à distância (slots) percorrida no mapa.
@immutable
class VehicleSpec {
  const VehicleSpec(this.name, this.capacityUnits, this.minPerSlot, this.kwhPerSlot);
  final String name;
  final int capacityUnits; // 1.000 un = 1 m³
  final double minPerSlot; // min de viagem por slot de distância
  final double kwhPerSlot; // energia por slot de distância
}

const VehicleSpec kFurgao = VehicleSpec('Furgão', 6000, 0.25, 0.25);
const VehicleSpec kCaminhao = VehicleSpec('Caminhão de Carga', 30000, 0.667, 2.0);

/// Resultado do cálculo de logística de uma movimentação (§25).
@immutable
class Logistics {
  const Logistics({
    required this.vehicle,
    required this.trips,
    required this.minutes,
    required this.energyKwh,
  });
  final VehicleSpec vehicle;
  final int trips;
  final double minutes; // por viagem
  final double energyKwh; // total (todas as viagens)
}

/// Escolhe o veículo e calcula tempo/energia para mover [qty] unidades por
/// [distanceSlots] slots (GDD §25.4/§25.6). Furgão até 6.000 un; acima, Caminhão.
Logistics computeLogistics(int qty, int distanceSlots) {
  final v = qty <= kFurgao.capacityUnits ? kFurgao : kCaminhao;
  final trips = (qty / v.capacityUnits).ceil().clamp(1, 999);
  return Logistics(
    vehicle: v,
    trips: trips,
    minutes: distanceSlots * v.minPerSlot,
    energyKwh: distanceSlots * v.kwhPerSlot * trips,
  );
}

/// Oferta de troca direta entre colonos (GDD §8 + §25). O sistema não dá
/// garantias: o sinal de confiança é o índice de Confiança Comercial (0–1000,
/// §26.2), as avaliações 0–5★ e o histórico do comerciante.
@immutable
class InformalOffer {
  const InformalOffer({
    required this.id,
    required this.trader,
    required this.sector,
    required this.rating,
    required this.ratingsCount,
    required this.commercialTrust,
    required this.distanceSlots,
    required this.deals,
    required this.successRate,
    required this.scams,
    required this.give,
    required this.want,
    this.federation,
    this.sameFederation = false,
    this.note = '',
  });

  final String id;
  final String trader;
  final String sector;
  final double rating; // 0–5 (média das avaliações de comércio)
  final int ratingsCount;
  final int commercialTrust; // Confiança Comercial 0–1000 (§26.2)
  final int distanceSlots; // distância no mapa até o slot do ofertante (§25.6)
  final int deals; // negociações concluídas
  final int successRate; // %
  final int scams; // calotes registrados
  final TradeLeg give; // o que o ofertante entrega (você recebe)
  final TradeLeg want; // o que o ofertante quer (você envia)
  final String? federation;
  final bool sameFederation;
  final String note;

  /// Sinal de risco de calote: Confiança Comercial baixa bloqueia/alerta (§26).
  bool get risky => commercialTrust < 500;

  /// Logística do envio (você despacha o lado [want]) — §25.
  Logistics get sendLogistics => computeLogistics(want.qty, distanceSlots);

  factory InformalOffer.fromJson(Map<String, dynamic> j) => InformalOffer(
        id: j['id'] as String,
        trader: j['trader'] as String,
        sector: j['sector'] as String? ?? '',
        rating: ((j['rating'] as num?)?.toDouble() ?? 5).clamp(0, 5).toDouble(),
        ratingsCount: j['ratings'] as int? ?? 0,
        commercialTrust: (j['commercialTrust'] as int? ?? 500).clamp(0, 1000),
        distanceSlots: j['distanceSlots'] as int? ?? 0,
        deals: j['deals'] as int? ?? 0,
        successRate: j['successRate'] as int? ?? 0,
        scams: j['scams'] as int? ?? 0,
        give: TradeLeg.fromJson(j['give'] as Map<String, dynamic>),
        want: TradeLeg.fromJson(j['want'] as Map<String, dynamic>),
        federation: j['federation'] as String?,
        sameFederation: j['sameFederation'] as bool? ?? false,
        note: j['note'] as String? ?? '',
      );
}

/// Uma troca já ocorrida — sucesso ou calote — vinda do log de comércio (§8.2).
@immutable
class TradeHistoryEntry {
  const TradeHistoryEntry({
    required this.id,
    required this.counterparty,
    required this.outcome,
    required this.summary,
    required this.rating,
    required this.day,
    this.reported = false,
    this.agreementExpired = false,
  });

  final String id;
  final String counterparty;
  final TradeOutcome outcome;
  final String summary;
  final int rating; // estrelas dadas (0–5)
  final String day;
  final bool reported; // denúncia aberta no Ministério das Reputações
  final bool agreementExpired; // Acordo de Troca expirou → denúncia pré-preenchida (§26.5)

  factory TradeHistoryEntry.fromJson(Map<String, dynamic> j) => TradeHistoryEntry(
        id: j['id'] as String,
        counterparty: j['counterparty'] as String,
        outcome: _outcomeFrom(j['outcome'] as String?),
        summary: j['summary'] as String? ?? '',
        rating: j['rating'] as int? ?? 0,
        day: j['day'] as String? ?? '',
        reported: j['reported'] as bool? ?? false,
        agreementExpired: j['agreementExpired'] as bool? ?? false,
      );
}

/// Estado do Comércio Informal (mock). Alíquotas §8.3 vêm aqui para manter o
/// seam como fonte única (sem números cravados na UI).
@immutable
class InformalBoard {
  const InformalBoard({
    required this.primaryRate,
    required this.secondaryRate,
    required this.rareRate,
    required this.federationExemption,
    required this.offers,
    required this.history,
  });

  final int primaryRate;
  final int secondaryRate;
  final int rareRate;
  final String federationExemption;
  final List<InformalOffer> offers;
  final List<TradeHistoryEntry> history;

  /// Alíquota (%) para a camada de um recurso (§8.3).
  int rateFor(ResourceTier tier) => switch (tier) {
        ResourceTier.primary => primaryRate,
        ResourceTier.secondary => secondaryRate,
        ResourceTier.rare => rareRate,
      };

  factory InformalBoard.fromJson(Map<String, dynamic> j) {
    final tax = j['taxRates'] as Map<String, dynamic>? ?? const {};
    return InformalBoard(
      primaryRate: tax['primary'] as int? ?? 3,
      secondaryRate: tax['secondary'] as int? ?? 2,
      rareRate: tax['rare'] as int? ?? 1,
      federationExemption: j['federationExemption'] as String? ?? '',
      offers: (j['offers'] as List<dynamic>? ?? const [])
          .map((e) => InformalOffer.fromJson(e as Map<String, dynamic>))
          .toList(),
      history: (j['history'] as List<dynamic>? ?? const [])
          .map((e) => TradeHistoryEntry.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
