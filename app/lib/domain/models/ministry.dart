import 'package:flutter/foundation.dart';

/// Identidade estável de cada instituição da Capital (GDD §2.1). Liga o slot
/// tocado ao painel correto e à função descritiva fixa do GDD.
enum MinistryKind {
  administration,
  tributes,
  research,
  treasury,
  security,
  parking,
  reputation,
  transport,
  depot,
  centralTransport,
  unknown,
}

MinistryKind ministryKindFrom(String? s) => switch (s) {
      'administration' => MinistryKind.administration,
      'tributes' => MinistryKind.tributes,
      'research' => MinistryKind.research,
      'treasury' => MinistryKind.treasury,
      'security' => MinistryKind.security,
      'parking' => MinistryKind.parking,
      'reputation' => MinistryKind.reputation,
      'transport' => MinistryKind.transport,
      'depot' => MinistryKind.depot,
      'central_transport' => MinistryKind.centralTransport,
      _ => MinistryKind.unknown,
    };

extension MinistryKindMeta on MinistryKind {
  /// Função descritiva fixa (GDD §2.1) — não é mock, é texto canônico do GDD.
  String get function => switch (this) {
        MinistryKind.administration =>
          'Sede do governo: leis, punições e recompensas. Coordena cargos públicos neutros.',
        MinistryKind.tributes =>
          'Coleta e redistribuição de impostos sobre o comércio entre colonos.',
        MinistryKind.research =>
          'Descobertas, notícias do Telescópio Gagarin, eventos e comunicados oficiais.',
        MinistryKind.treasury =>
          'Gestão do Fert\$, PIB, todas as taxas e o painel financeiro central.',
        MinistryKind.security =>
          'Registro de guerras, tratados e validação de acordos entre colonos e federações.',
        MinistryKind.parking =>
          '20 vagas com cobrança por hora. Caminhões aguardam a retirada de carga.',
        MinistryKind.reputation =>
          'Denúncias, conciliação, avaliações e punições de reputação.',
        MinistryKind.transport =>
          'Registro de placas, depreciação e manutenção da frota civil do planeta.',
        MinistryKind.depot =>
          'Armazenamento central de recursos da Capital, com capacidade por recurso.',
        MinistryKind.centralTransport =>
          'Libera vagas de frota (10 níveis); veículos são fabricados/adquiridos à parte (§0).',
        MinistryKind.unknown => 'Instituição da Capital.',
      };
}

/// Linha de fluxo do Tesouro (entrada/saída).
@immutable
class TreasuryLine {
  const TreasuryLine({required this.label, required this.amount, required this.inflow});
  final String label;
  final double amount;
  final bool inflow;

  factory TreasuryLine.fromJson(Map<String, dynamic> j) => TreasuryLine(
        label: j['label'] as String,
        amount: (j['amount'] as num).toDouble(),
        inflow: j['inflow'] as bool? ?? false,
      );
}

/// Finanças e Tesouro (GDD §2.1 slot 4).
@immutable
class TreasuryData {
  const TreasuryData({
    required this.balanceFert,
    required this.pib,
    required this.dailyRevenue,
    required this.dailyExpense,
    required this.lines,
  });

  final double balanceFert;
  final double pib;
  final double dailyRevenue;
  final double dailyExpense;
  final List<TreasuryLine> lines;

  factory TreasuryData.fromJson(Map<String, dynamic> j) => TreasuryData(
        balanceFert: (j['balanceFert'] as num).toDouble(),
        pib: (j['pib'] as num).toDouble(),
        dailyRevenue: (j['dailyRevenue'] as num).toDouble(),
        dailyExpense: (j['dailyExpense'] as num).toDouble(),
        lines: (j['lines'] as List<dynamic>? ?? const [])
            .map((e) => TreasuryLine.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}

/// Uma arrecadação recente do comércio informal.
@immutable
class TaxCollection {
  const TaxCollection({
    required this.trader,
    required this.resource,
    required this.tier,
    required this.rate,
    required this.volume,
    required this.tax,
  });

  final String trader;
  final String resource;
  final String tier;
  final int rate; // %
  final String volume; // já formatado
  final int tax;

  factory TaxCollection.fromJson(Map<String, dynamic> j) => TaxCollection(
        trader: j['trader'] as String,
        resource: j['resource'] as String,
        tier: j['tier'] as String,
        rate: j['rate'] as int,
        volume: j['volume'].toString(),
        tax: j['tax'] as int,
      );
}

/// Central de Tributos (GDD §2.1 slot 2 + §8.3).
@immutable
class TaxData {
  const TaxData({
    required this.primaryRate,
    required this.secondaryRate,
    required this.rareRate,
    required this.federationExemption,
    required this.collectedToday,
    required this.redistributedToday,
    required this.recent,
  });

  final int primaryRate;
  final int secondaryRate;
  final int rareRate;
  final String federationExemption;
  final double collectedToday;
  final double redistributedToday;
  final List<TaxCollection> recent;

  factory TaxData.fromJson(Map<String, dynamic> j) => TaxData(
        primaryRate: j['primaryRate'] as int,
        secondaryRate: j['secondaryRate'] as int,
        rareRate: j['rareRate'] as int,
        federationExemption: j['federationExemption'] as String,
        collectedToday: (j['collectedToday'] as num).toDouble(),
        redistributedToday: (j['redistributedToday'] as num).toDouble(),
        recent: (j['recent'] as List<dynamic>? ?? const [])
            .map((e) => TaxCollection.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}

/// Item do feed da Central de Pesquisas e Notícias.
@immutable
class NewsItem {
  const NewsItem({
    required this.category,
    required this.title,
    required this.body,
    required this.day,
  });

  final String category; // gagarin | event | official
  final String title;
  final String body;
  final String day;

  factory NewsItem.fromJson(Map<String, dynamic> j) => NewsItem(
        category: j['category'] as String? ?? 'official',
        title: j['title'] as String,
        body: j['body'] as String? ?? '',
        day: j['day'] as String? ?? '',
      );
}

/// Pesquisas e Notícias (GDD §2.1 slot 3 + §12.1 Gagarin).
@immutable
class ResearchData {
  const ResearchData({
    required this.gagarinActive,
    required this.gagarinTrigger,
    required this.gagarinFrequency,
    required this.feed,
  });

  final bool gagarinActive;
  final String gagarinTrigger;
  final String gagarinFrequency;
  final List<NewsItem> feed;

  factory ResearchData.fromJson(Map<String, dynamic> j) => ResearchData(
        gagarinActive: j['gagarinActive'] as bool? ?? false,
        gagarinTrigger: j['gagarinTrigger'] as String? ?? '',
        gagarinFrequency: j['gagarinFrequency'] as String? ?? '',
        feed: (j['feed'] as List<dynamic>? ?? const [])
            .map((e) => NewsItem.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}

/// Entrada genérica de três campos (lei/punição/recompensa/cargo).
@immutable
class AdminEntry {
  const AdminEntry({required this.primary, required this.secondary, required this.tertiary});
  final String primary;
  final String secondary;
  final String tertiary;

  factory AdminEntry.fromJson(Map<String, dynamic> j, List<String> keys) => AdminEntry(
        primary: j[keys[0]] as String? ?? '',
        secondary: j[keys[1]] as String? ?? '',
        tertiary: keys.length > 2 ? (j[keys[2]] as String? ?? '') : '',
      );
}

/// Administração Pública (GDD §2.1 slot 1 + §14 cargos).
@immutable
class AdminData {
  const AdminData({
    required this.laws,
    required this.punishments,
    required this.rewards,
    required this.offices,
  });

  final List<AdminEntry> laws;
  final List<AdminEntry> punishments;
  final List<AdminEntry> rewards;
  final List<AdminEntry> offices;

  static List<AdminEntry> _list(dynamic raw, List<String> keys) =>
      (raw as List<dynamic>? ?? const [])
          .map((e) => AdminEntry.fromJson(e as Map<String, dynamic>, keys))
          .toList();

  factory AdminData.fromJson(Map<String, dynamic> j) => AdminData(
        laws: _list(j['laws'], ['title', 'detail']),
        punishments: _list(j['punishments'], ['target', 'reason', 'penalty']),
        rewards: _list(j['rewards'], ['target', 'reason', 'reward']),
        offices: _list(j['offices'], ['title', 'institution', 'salary']),
      );
}

/// Guerra ou tratado registrado (GDD §2.1 slot 5).
@immutable
class SecurityEntry {
  const SecurityEntry({required this.primary, required this.secondary, required this.status, required this.meta});
  final String primary;
  final String secondary;
  final String status;
  final String meta;

  factory SecurityEntry.war(Map<String, dynamic> j) => SecurityEntry(
        primary: j['attacker'] as String? ?? '',
        secondary: j['defender'] as String? ?? '',
        status: j['status'] as String? ?? '',
        meta: j['day'] as String? ?? '',
      );

  factory SecurityEntry.treaty(Map<String, dynamic> j) => SecurityEntry(
        primary: j['parties'] as String? ?? '',
        secondary: j['type'] as String? ?? '',
        status: j['status'] as String? ?? '',
        meta: '',
      );
}

@immutable
class SecurityData {
  const SecurityData({required this.wars, required this.treaties});
  final List<SecurityEntry> wars;
  final List<SecurityEntry> treaties;

  factory SecurityData.fromJson(Map<String, dynamic> j) => SecurityData(
        wars: (j['wars'] as List<dynamic>? ?? const [])
            .map((e) => SecurityEntry.war(e as Map<String, dynamic>))
            .toList(),
        treaties: (j['treaties'] as List<dynamic>? ?? const [])
            .map((e) => SecurityEntry.treaty(e as Map<String, dynamic>))
            .toList(),
      );
}

/// Uma vaga ocupada no Estacionamento (GDD §2.1 slot 6).
@immutable
class ParkingSlot {
  const ParkingSlot({
    required this.plate,
    required this.owner,
    required this.cargo,
    required this.hoursWaiting,
    required this.fee,
  });

  final String plate;
  final String owner;
  final String cargo;
  final int hoursWaiting;
  final int fee;

  factory ParkingSlot.fromJson(Map<String, dynamic> j) => ParkingSlot(
        plate: j['plate'] as String,
        owner: j['owner'] as String,
        cargo: j['cargo'] as String? ?? '',
        hoursWaiting: j['hoursWaiting'] as int? ?? 0,
        fee: j['fee'] as int? ?? 0,
      );
}

@immutable
class ParkingData {
  const ParkingData({
    required this.totalSlots,
    required this.occupied,
    required this.hourlyFee,
    required this.slots,
  });

  final int totalSlots;
  final int occupied;
  final int hourlyFee;
  final List<ParkingSlot> slots;

  factory ParkingData.fromJson(Map<String, dynamic> j) => ParkingData(
        totalSlots: j['totalSlots'] as int? ?? 20,
        occupied: j['occupied'] as int? ?? 0,
        hourlyFee: j['hourlyFee'] as int? ?? 0,
        slots: (j['slots'] as List<dynamic>? ?? const [])
            .map((e) => ParkingSlot.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}

/// Registro de placa de um veículo civil (GDD §16.3/§16.4).
@immutable
class VehicleRecord {
  const VehicleRecord({
    required this.plate,
    required this.type,
    required this.owner,
    required this.buildDay,
    required this.activeHours,
    required this.condition,
    required this.maintenances,
    required this.resaleValue,
    required this.status,
  });

  final String plate;
  final String type;
  final String owner;
  final String buildDay;
  final int activeHours;
  final int condition; // %
  final int maintenances;
  final int resaleValue;
  final String status;

  factory VehicleRecord.fromJson(Map<String, dynamic> j) => VehicleRecord(
        plate: j['plate'] as String,
        type: j['type'] as String,
        owner: j['owner'] as String,
        buildDay: j['buildDay'] as String? ?? '',
        activeHours: j['activeHours'] as int? ?? 0,
        condition: j['condition'] as int? ?? 100,
        maintenances: j['maintenances'] as int? ?? 0,
        resaleValue: j['resaleValue'] as int? ?? 0,
        status: j['status'] as String? ?? '',
      );
}

@immutable
class TransportData {
  const TransportData({required this.registry});
  final List<VehicleRecord> registry;

  factory TransportData.fromJson(Map<String, dynamic> j) => TransportData(
        registry: (j['registry'] as List<dynamic>? ?? const [])
            .map((e) => VehicleRecord.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}

/// Linha de capacidade de um recurso no Depósito Central.
@immutable
class DepotLine {
  const DepotLine({required this.resource, required this.stored, required this.capacity});
  final String resource;
  final int stored;
  final int capacity;

  double get ratio => capacity == 0 ? 0 : (stored / capacity).clamp(0, 1);

  factory DepotLine.fromJson(Map<String, dynamic> j) => DepotLine(
        resource: j['resource'] as String,
        stored: j['stored'] as int? ?? 0,
        capacity: j['capacity'] as int? ?? 1,
      );
}

@immutable
class DepotData {
  const DepotData({required this.lines});
  final List<DepotLine> lines;

  factory DepotData.fromJson(Map<String, dynamic> j) => DepotData(
        lines: (j['lines'] as List<dynamic>? ?? const [])
            .map((e) => DepotLine.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}

/// Um nível da Central de Transportes. O nível libera VAGAS de frota (uma por
/// nível), não caminhões grátis — decisão vigente do §0 (supera "caminhões
/// base" de §19.5/§28.5); veículo é fabricado/adquirido à parte e ocupa a vaga.
@immutable
class TransportLevel {
  const TransportLevel({required this.level, required this.slots, required this.energy});
  final int level;

  /// Vagas de frota liberadas neste nível (capacidade de manter veículos ativos).
  final int slots;
  final int energy;

  factory TransportLevel.fromJson(Map<String, dynamic> j) => TransportLevel(
        level: j['level'] as int,
        slots: (j['slots'] ?? j['trucks']) as int,
        energy: j['energy'] as int,
      );
}

@immutable
class CentralTransportData {
  const CentralTransportData({required this.currentLevel, required this.levels});
  final int currentLevel;
  final List<TransportLevel> levels;

  factory CentralTransportData.fromJson(Map<String, dynamic> j) => CentralTransportData(
        currentLevel: j['currentLevel'] as int? ?? 1,
        levels: (j['levels'] as List<dynamic>? ?? const [])
            .map((e) => TransportLevel.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}

/// Pacote com os dados (mock) de todas as instituições da Capital (GDD §2.1).
@immutable
class MinistriesData {
  const MinistriesData({
    required this.treasury,
    required this.tributes,
    required this.research,
    required this.administration,
    required this.security,
    required this.parking,
    required this.transport,
    required this.depot,
    required this.centralTransport,
  });

  final TreasuryData treasury;
  final TaxData tributes;
  final ResearchData research;
  final AdminData administration;
  final SecurityData security;
  final ParkingData parking;
  final TransportData transport;
  final DepotData depot;
  final CentralTransportData centralTransport;

  factory MinistriesData.fromJson(Map<String, dynamic> j) => MinistriesData(
        treasury: TreasuryData.fromJson(j['treasury'] as Map<String, dynamic>),
        tributes: TaxData.fromJson(j['tributes'] as Map<String, dynamic>),
        research: ResearchData.fromJson(j['research'] as Map<String, dynamic>),
        administration: AdminData.fromJson(j['administration'] as Map<String, dynamic>),
        security: SecurityData.fromJson(j['security'] as Map<String, dynamic>),
        parking: ParkingData.fromJson(j['parking'] as Map<String, dynamic>),
        transport: TransportData.fromJson(j['transport'] as Map<String, dynamic>),
        depot: DepotData.fromJson(j['depot'] as Map<String, dynamic>),
        centralTransport:
            CentralTransportData.fromJson(j['centralTransport'] as Map<String, dynamic>),
      );
}
