import 'package:flutter/foundation.dart';

/// Estados auditáveis de uma denúncia (GDD v29 §9.2). A ordem do enum segue o
/// avanço no fluxo de 5 passos; `dismissed`/`punished`/`appealed` são desfechos.
enum DisputeStatus { triage, analyzing, judged, punished, appealed, dismissed }

DisputeStatus _statusFrom(String? s) => switch (s) {
      'analyzing' => DisputeStatus.analyzing,
      'judged' => DisputeStatus.judged,
      'punished' => DisputeStatus.punished,
      'appealed' => DisputeStatus.appealed,
      'dismissed' => DisputeStatus.dismissed,
      _ => DisputeStatus.triage,
    };

/// Gravidade da denúncia (§9.2): simples → conciliador; grave → equipe.
enum DisputeSeverity { simple, grave }

DisputeSeverity _severityFrom(String? s) =>
    s == 'grave' ? DisputeSeverity.grave : DisputeSeverity.simple;

/// Punições previstas no §9.4 (`none` enquanto não decidido).
enum DisputePenalty { none, warning, reputationCut, silence, tradeRestriction, auctionBan }

DisputePenalty _penaltyFrom(String? s) => switch (s) {
      'warning' => DisputePenalty.warning,
      'reputationCut' => DisputePenalty.reputationCut,
      'silence' => DisputePenalty.silence,
      'tradeRestriction' => DisputePenalty.tradeRestriction,
      'auctionBan' => DisputePenalty.auctionBan,
      _ => DisputePenalty.none,
    };

/// Tipo de evidência anexada à denúncia (§9.2): texto, captura, log e histórico.
enum EvidenceKind { text, screenshot, log, history }

EvidenceKind _evidenceFrom(String? s) => switch (s) {
      'screenshot' => EvidenceKind.screenshot,
      'log' => EvidenceKind.log,
      'history' => EvidenceKind.history,
      _ => EvidenceKind.text,
    };

@immutable
class Evidence {
  const Evidence({required this.kind, required this.label});
  final EvidenceKind kind;
  final String label;

  factory Evidence.fromJson(Map<String, dynamic> j) => Evidence(
        kind: _evidenceFrom(j['kind'] as String?),
        label: j['label'] as String? ?? '',
      );
}

/// Um evento do histórico auditável da denúncia (§9.2).
@immutable
class DisputeEvent {
  const DisputeEvent({required this.label, required this.time, this.note = ''});
  final String label;
  final String time; // já formatado (ex.: "Dia 12 · 14:20")
  final String note;

  factory DisputeEvent.fromJson(Map<String, dynamic> j) => DisputeEvent(
        label: j['label'] as String? ?? '',
        time: j['time'] as String? ?? '',
        note: j['note'] as String? ?? '',
      );
}

/// Uma denúncia/disputa (§9). `fromExpiredAgreement` = pré-preenchida a partir
/// de um Acordo de Troca expirado (§26.5).
@immutable
class Dispute {
  const Dispute({
    required this.id,
    required this.code,
    required this.reporter,
    required this.accused,
    required this.summary,
    required this.severity,
    required this.status,
    required this.affectedIndex,
    required this.penalty,
    required this.openedDay,
    required this.deadline,
    required this.value,
    required this.conciliator,
    required this.fromExpiredAgreement,
    required this.evidence,
    required this.timeline,
  });

  final String id;
  final String code; // ex.: "DEN-0481"
  final String reporter;
  final String accused;
  final String summary;
  final DisputeSeverity severity;
  final DisputeStatus status;
  final String affectedIndex; // índice de reputação afetado (§26)
  final DisputePenalty penalty;
  final String openedDay; // ex.: "Dia 12"
  final String deadline; // prazo 48h (§26.8), já formatado
  final int value; // valor da transação envolvida (Fert$)
  final String conciliator; // nome ou '' se ainda não atribuído
  final bool fromExpiredAgreement;
  final List<Evidence> evidence;
  final List<DisputeEvent> timeline;

  bool get isResolved =>
      status == DisputeStatus.judged ||
      status == DisputeStatus.punished ||
      status == DisputeStatus.dismissed;

  factory Dispute.fromJson(Map<String, dynamic> j) => Dispute(
        id: j['id'] as String,
        code: j['code'] as String? ?? '',
        reporter: j['reporter'] as String? ?? '',
        accused: j['accused'] as String? ?? '',
        summary: j['summary'] as String? ?? '',
        severity: _severityFrom(j['severity'] as String?),
        status: _statusFrom(j['status'] as String?),
        affectedIndex: j['affectedIndex'] as String? ?? '',
        penalty: _penaltyFrom(j['penalty'] as String?),
        openedDay: j['openedDay'] as String? ?? '',
        deadline: j['deadline'] as String? ?? '',
        value: (j['value'] as num?)?.toInt() ?? 0,
        conciliator: j['conciliator'] as String? ?? '',
        fromExpiredAgreement: j['fromExpiredAgreement'] as bool? ?? false,
        evidence: (j['evidence'] as List<dynamic>? ?? const [])
            .map((e) => Evidence.fromJson(e as Map<String, dynamic>))
            .toList(),
        timeline: (j['timeline'] as List<dynamic>? ?? const [])
            .map((e) => DisputeEvent.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}

/// Um Conciliador — Neutro Registrado (§9.3 / §26.7). Pago 50 Fert$/dia + 3 por
/// denúncia (só se a decisão não for revertida); reversões levam a suspensão.
@immutable
class Conciliator {
  const Conciliator({
    required this.name,
    required this.casesResolved,
    required this.reversals,
    required this.openCases,
    required this.suspended,
  });

  final String name;
  final int casesResolved;
  final int reversals;
  final int openCases;
  final bool suspended;

  factory Conciliator.fromJson(Map<String, dynamic> j) => Conciliator(
        name: j['name'] as String? ?? '',
        casesResolved: (j['casesResolved'] as num?)?.toInt() ?? 0,
        reversals: (j['reversals'] as num?)?.toInt() ?? 0,
        openCases: (j['openCases'] as num?)?.toInt() ?? 0,
        suspended: j['suspended'] as bool? ?? false,
      );
}

/// Estado do Ministério das Reputações (mock, §9). Reúne a fila de denúncias e
/// os conciliadores registrados.
@immutable
class DisputeBoard {
  const DisputeBoard({required this.disputes, required this.conciliators});
  final List<Dispute> disputes;
  final List<Conciliator> conciliators;

  int get openCount => disputes
      .where((d) => d.status == DisputeStatus.triage || d.status == DisputeStatus.analyzing)
      .length;
  int get resolvedCount => disputes.where((d) => d.isResolved).length;
  int get appealedCount =>
      disputes.where((d) => d.status == DisputeStatus.appealed).length;

  factory DisputeBoard.fromJson(Map<String, dynamic> j) => DisputeBoard(
        disputes: (j['disputes'] as List<dynamic>? ?? const [])
            .map((e) => Dispute.fromJson(e as Map<String, dynamic>))
            .toList(),
        conciliators: (j['conciliators'] as List<dynamic>? ?? const [])
            .map((e) => Conciliator.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}
