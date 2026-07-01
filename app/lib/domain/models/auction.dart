import 'package:flutter/foundation.dart';

/// Raridade de uma peça leiloada (§13 — "leilões de peças únicas").
enum AuctionRarity { unique, legendary, rare }

AuctionRarity _rarityFrom(String? s) => switch (s) {
      'legendary' => AuctionRarity.legendary,
      'rare' => AuctionRarity.rare,
      _ => AuctionRarity.unique,
    };

/// Situação do lote no leilão.
enum AuctionStatus { live, endingSoon, ended }

AuctionStatus _statusFrom(String? s) => switch (s) {
      'endingSoon' => AuctionStatus.endingSoon,
      'ended' => AuctionStatus.ended,
      _ => AuctionStatus.live,
    };

/// Um lote em leilão (§13). `currentBid`/`minIncrement` em Fert$; `timeLeft` já
/// vem formatado (ex.: "Termina em 2h14"); `youAreTop` destaca quando o lance
/// líder é seu.
@immutable
class AuctionItem {
  const AuctionItem({
    required this.id,
    required this.name,
    required this.description,
    required this.rarity,
    required this.currentBid,
    required this.minIncrement,
    required this.bidCount,
    required this.topBidder,
    required this.timeLeft,
    required this.status,
    this.youAreTop = false,
  });

  final String id;
  final String name;
  final String description;
  final AuctionRarity rarity;
  final int currentBid;
  final int minIncrement;
  final int bidCount;
  final String topBidder;
  final String timeLeft;
  final AuctionStatus status;
  final bool youAreTop;

  int get nextBid => currentBid + minIncrement;

  factory AuctionItem.fromJson(Map<String, dynamic> j) => AuctionItem(
        id: j['id'] as String,
        name: j['name'] as String? ?? '',
        description: j['description'] as String? ?? '',
        rarity: _rarityFrom(j['rarity'] as String?),
        currentBid: (j['currentBid'] as num?)?.toInt() ?? 0,
        minIncrement: (j['minIncrement'] as num?)?.toInt() ?? 0,
        bidCount: (j['bidCount'] as num?)?.toInt() ?? 0,
        topBidder: j['topBidder'] as String? ?? '',
        timeLeft: j['timeLeft'] as String? ?? '',
        status: _statusFrom(j['status'] as String?),
        youAreTop: j['youAreTop'] as bool? ?? false,
      );
}

/// Um leilão encerrado (histórico).
@immutable
class AuctionRecord {
  const AuctionRecord({
    required this.name,
    required this.winner,
    required this.finalPrice,
    required this.day,
  });

  final String name;
  final String winner;
  final int finalPrice;
  final String day;

  factory AuctionRecord.fromJson(Map<String, dynamic> j) => AuctionRecord(
        name: j['name'] as String? ?? '',
        winner: j['winner'] as String? ?? '',
        finalPrice: (j['finalPrice'] as num?)?.toInt() ?? 0,
        day: j['day'] as String? ?? '',
      );
}

/// Estado da Casa de Leilões (mock, §13). Os leilões desbloqueiam no Nível 100
/// (Lenda de Fertways); `blocked` cobre Persona Non Grata (§9.4) ou Confiança
/// Comercial baixa (§26.2).
@immutable
class AuctionHouse {
  const AuctionHouse({
    required this.unlocked,
    required this.unlockLevel,
    required this.unlockTitle,
    required this.playerLevel,
    required this.blocked,
    required this.blockReason,
    required this.items,
    required this.history,
  });

  final bool unlocked;
  final int unlockLevel; // §13 = 100
  final String unlockTitle; // "Lenda de Fertways"
  final int playerLevel;
  final bool blocked;
  final String blockReason;
  final List<AuctionItem> items;
  final List<AuctionRecord> history;

  /// Pode dar lances? Só com leilões desbloqueados e sem bloqueio.
  bool get canBid => unlocked && !blocked;

  factory AuctionHouse.fromJson(Map<String, dynamic> j) => AuctionHouse(
        unlocked: j['unlocked'] as bool? ?? false,
        unlockLevel: (j['unlockLevel'] as num?)?.toInt() ?? 100,
        unlockTitle: j['unlockTitle'] as String? ?? 'Lenda de Fertways',
        playerLevel: (j['playerLevel'] as num?)?.toInt() ?? 1,
        blocked: j['blocked'] as bool? ?? false,
        blockReason: j['blockReason'] as String? ?? '',
        items: (j['items'] as List<dynamic>? ?? const [])
            .map((e) => AuctionItem.fromJson(e as Map<String, dynamic>))
            .toList(),
        history: (j['history'] as List<dynamic>? ?? const [])
            .map((e) => AuctionRecord.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}
