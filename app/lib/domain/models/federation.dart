import 'package:flutter/foundation.dart';

/// Cargos dentro de uma federação (GDD v29 §4): Líder (com voto de Minerva,
/// desempate) + Diplomata; os demais são Membros.
enum FederationRole { leader, diplomat, member }

FederationRole _roleFrom(String? s) => switch (s) {
      'leader' => FederationRole.leader,
      'diplomat' => FederationRole.diplomat,
      _ => FederationRole.member,
    };

/// Um membro da federação (§4). `dailyContribution` = aporte ao fundo no dia
/// (Fert$); `online` para presença; `isYou` destaca o jogador.
@immutable
class FederationMember {
  const FederationMember({
    required this.id,
    required this.name,
    required this.sector,
    required this.role,
    required this.level,
    required this.dailyContribution,
    this.online = false,
    this.isYou = false,
  });

  final String id;
  final String name;
  final String sector;
  final FederationRole role;
  final int level;
  final int dailyContribution; // Fert$ aportados hoje
  final bool online;
  final bool isYou;

  factory FederationMember.fromJson(Map<String, dynamic> j) => FederationMember(
        id: j['id'] as String,
        name: j['name'] as String? ?? '',
        sector: j['sector'] as String? ?? '',
        role: _roleFrom(j['role'] as String?),
        level: (j['level'] as num?)?.toInt() ?? 1,
        dailyContribution: (j['dailyContribution'] as num?)?.toInt() ?? 0,
        online: j['online'] as bool? ?? false,
        isYou: j['isYou'] as bool? ?? false,
      );
}

/// Uma federação aliada (§4): troca entre aliadas tem **50% de desconto**.
@immutable
class FederationAlly {
  const FederationAlly({
    required this.name,
    required this.tag,
    required this.memberCount,
    required this.tradeDiscount,
  });

  final String name;
  final String tag;
  final int memberCount;
  final int tradeDiscount; // % de desconto entre aliadas (§4 = 50)

  factory FederationAlly.fromJson(Map<String, dynamic> j) => FederationAlly(
        name: j['name'] as String? ?? '',
        tag: j['tag'] as String? ?? '',
        memberCount: (j['memberCount'] as num?)?.toInt() ?? 0,
        tradeDiscount: (j['tradeDiscount'] as num?)?.toInt() ?? 50,
      );
}

/// Estado da federação do jogador (mock, GDD v29 §4).
///
/// Números do §4: máx **12** membros · fundo **1–10%** da produção diária
/// (padrão **3%**, mantido na Capital) · tributação interna **gratuita até 35%**
/// da produção diária, **35%** acima · **50%** de desconto entre aliadas ·
/// limite antimonopólio **dinâmico 20% → 10%**.
@immutable
class Federation {
  const Federation({
    this.inFederation = true,
    required this.name,
    required this.tag,
    required this.motto,
    required this.maxMembers,
    required this.fundBalance,
    required this.contributionRate,
    required this.contributionMin,
    required this.contributionMax,
    required this.fundLocation,
    required this.internalFreeThreshold,
    required this.internalTributeRate,
    required this.allyDiscount,
    required this.antiMonopolyMax,
    required this.antiMonopolyMin,
    required this.yourContributionToday,
    required this.members,
    required this.allies,
  });

  final bool inFederation; // false = colono sem federação (estado vazio §4)
  final String name;
  final String tag;
  final String motto;
  final int maxMembers; // §4 = 12
  final int fundBalance; // Fert$ no fundo (na Capital)
  final double contributionRate; // % da produção diária (1–10, padrão 3)
  final double contributionMin; // §4 = 1
  final double contributionMax; // §4 = 10
  final String fundLocation; // ex.: "Capital — Tesouro da Federação"
  final int internalFreeThreshold; // % grátis na tributação interna (§4 = 35)
  final int internalTributeRate; // % de tributo acima do limite (§4 = 35)
  final int allyDiscount; // % desconto entre aliadas (§4 = 50)
  final int antiMonopolyMax; // % limite antimonopólio inicial (§4 = 20)
  final int antiMonopolyMin; // % limite antimonopólio reduzido (§4 = 10)
  final int yourContributionToday; // Fert$ aportados por você hoje
  final List<FederationMember> members;
  final List<FederationAlly> allies;

  int get memberCount => members.length;

  FederationMember? get leader =>
      members.where((m) => m.role == FederationRole.leader).firstOrNull;

  FederationMember? get diplomat =>
      members.where((m) => m.role == FederationRole.diplomat).firstOrNull;

  factory Federation.fromJson(Map<String, dynamic> j) => Federation(
        inFederation: j['inFederation'] as bool? ?? true,
        name: j['name'] as String? ?? '',
        tag: j['tag'] as String? ?? '',
        motto: j['motto'] as String? ?? '',
        maxMembers: (j['maxMembers'] as num?)?.toInt() ?? 12,
        fundBalance: (j['fundBalance'] as num?)?.toInt() ?? 0,
        contributionRate: (j['contributionRate'] as num?)?.toDouble() ?? 3,
        contributionMin: (j['contributionMin'] as num?)?.toDouble() ?? 1,
        contributionMax: (j['contributionMax'] as num?)?.toDouble() ?? 10,
        fundLocation: j['fundLocation'] as String? ?? '',
        internalFreeThreshold: (j['internalFreeThreshold'] as num?)?.toInt() ?? 35,
        internalTributeRate: (j['internalTributeRate'] as num?)?.toInt() ?? 35,
        allyDiscount: (j['allyDiscount'] as num?)?.toInt() ?? 50,
        antiMonopolyMax: (j['antiMonopolyMax'] as num?)?.toInt() ?? 20,
        antiMonopolyMin: (j['antiMonopolyMin'] as num?)?.toInt() ?? 10,
        yourContributionToday: (j['yourContributionToday'] as num?)?.toInt() ?? 0,
        members: (j['members'] as List<dynamic>? ?? const [])
            .map((e) => FederationMember.fromJson(e as Map<String, dynamic>))
            .toList(),
        allies: (j['allies'] as List<dynamic>? ?? const [])
            .map((e) => FederationAlly.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}
