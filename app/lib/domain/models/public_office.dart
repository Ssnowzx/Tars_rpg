import 'package:flutter/foundation.dart';

/// Os 5 cargos públicos neutros (GDD v29 §14).
enum OfficeKind { conciliator, marketInspector, spaceportClerk, reporter, treasuryAssistant }

OfficeKind _kindFrom(String? s) => switch (s) {
      'marketInspector' => OfficeKind.marketInspector,
      'spaceportClerk' => OfficeKind.spaceportClerk,
      'reporter' => OfficeKind.reporter,
      'treasuryAssistant' => OfficeKind.treasuryAssistant,
      _ => OfficeKind.conciliator,
    };

/// Um critério de elegibilidade (§14.3) e se o jogador o cumpre.
@immutable
class EligibilityCriterion {
  const EligibilityCriterion({required this.label, required this.met});
  final String label;
  final bool met;

  factory EligibilityCriterion.fromJson(Map<String, dynamic> j) => EligibilityCriterion(
        label: j['label'] as String? ?? '',
        met: j['met'] as bool? ?? false,
      );
}

/// Quem ocupa um cargo, desde quando e o desempenho (§14.4).
@immutable
class OfficeHolder {
  const OfficeHolder({required this.name, required this.since, required this.performance});
  final String name;
  final String since; // ex.: "Dia 3"
  final String performance; // ex.: "Aprovação 96%"

  factory OfficeHolder.fromJson(Map<String, dynamic> j) => OfficeHolder(
        name: j['name'] as String? ?? '',
        since: j['since'] as String? ?? '',
        performance: j['performance'] as String? ?? '',
      );
}

/// Um cargo público (§14). `salary` já vem formatado; `reputationIndex` = índice
/// de reputação ligado ao cargo (§26.6).
@immutable
class PublicOffice {
  const PublicOffice({
    required this.kind,
    required this.title,
    required this.institution,
    required this.description,
    required this.salary,
    required this.reputationIndex,
    required this.seats,
    required this.holders,
  });

  final OfficeKind kind;
  final String title;
  final String institution;
  final String description;
  final String salary;
  final String reputationIndex;
  final int seats;
  final List<OfficeHolder> holders;

  int get vacantSeats => (seats - holders.length).clamp(0, seats);
  bool get hasVacancy => vacantSeats > 0;

  factory PublicOffice.fromJson(Map<String, dynamic> j) => PublicOffice(
        kind: _kindFrom(j['kind'] as String?),
        title: j['title'] as String? ?? '',
        institution: j['institution'] as String? ?? '',
        description: j['description'] as String? ?? '',
        salary: j['salary'] as String? ?? '',
        reputationIndex: j['reputationIndex'] as String? ?? '',
        seats: (j['seats'] as num?)?.toInt() ?? 1,
        holders: (j['holders'] as List<dynamic>? ?? const [])
            .map((e) => OfficeHolder.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}

/// Uma candidatura pendente a um cargo (§14.4).
@immutable
class OfficeCandidate {
  const OfficeCandidate({
    required this.name,
    required this.officeTitle,
    required this.appliedDay,
    required this.eligible,
    this.note = '',
  });

  final String name;
  final String officeTitle;
  final String appliedDay;
  final bool eligible;
  final String note;

  factory OfficeCandidate.fromJson(Map<String, dynamic> j) => OfficeCandidate(
        name: j['name'] as String? ?? '',
        officeTitle: j['officeTitle'] as String? ?? '',
        appliedDay: j['appliedDay'] as String? ?? '',
        eligible: j['eligible'] as bool? ?? false,
        note: j['note'] as String? ?? '',
      );
}

/// Um pagamento de salário/bônus a um ocupante (§14.4).
@immutable
class OfficePayment {
  const OfficePayment({
    required this.holder,
    required this.officeTitle,
    required this.amount,
    required this.day,
  });

  final String holder;
  final String officeTitle;
  final int amount; // Fert$
  final String day;

  factory OfficePayment.fromJson(Map<String, dynamic> j) => OfficePayment(
        holder: j['holder'] as String? ?? '',
        officeTitle: j['officeTitle'] as String? ?? '',
        amount: (j['amount'] as num?)?.toInt() ?? 0,
        day: j['day'] as String? ?? '',
      );
}

/// Estado dos Cargos Públicos Neutros (mock, §14). Reúne a elegibilidade do
/// jogador (§14.3), os cargos, as candidaturas e os pagamentos (§14.4).
@immutable
class PublicOfficeBoard {
  const PublicOfficeBoard({
    required this.eligibility,
    required this.offices,
    required this.candidates,
    required this.payments,
  });

  final List<EligibilityCriterion> eligibility;
  final List<PublicOffice> offices;
  final List<OfficeCandidate> candidates;
  final List<OfficePayment> payments;

  bool get isEligible => eligibility.isNotEmpty && eligibility.every((c) => c.met);
  int get metCount => eligibility.where((c) => c.met).length;
  int get openSeats => offices.fold(0, (sum, o) => sum + o.vacantSeats);

  factory PublicOfficeBoard.fromJson(Map<String, dynamic> j) => PublicOfficeBoard(
        eligibility: (j['eligibility'] as List<dynamic>? ?? const [])
            .map((e) => EligibilityCriterion.fromJson(e as Map<String, dynamic>))
            .toList(),
        offices: (j['offices'] as List<dynamic>? ?? const [])
            .map((e) => PublicOffice.fromJson(e as Map<String, dynamic>))
            .toList(),
        candidates: (j['candidates'] as List<dynamic>? ?? const [])
            .map((e) => OfficeCandidate.fromJson(e as Map<String, dynamic>))
            .toList(),
        payments: (j['payments'] as List<dynamic>? ?? const [])
            .map((e) => OfficePayment.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}
