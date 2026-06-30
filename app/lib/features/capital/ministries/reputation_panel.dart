import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../app/theme/ds_colors.dart';
import '../../../app/theme/ds_tokens.dart';
import '../../../data/providers.dart';
import '../../../domain/models/dispute.dart';
import 'ministry_widgets.dart';

EdgeInsets _bodyPadding(DsTokens t) => EdgeInsets.fromLTRB(t.space4, 0, t.space4, t.space6);

({String label, Color color, IconData icon}) _statusMeta(DisputeStatus s, DsTokens t) => switch (s) {
      DisputeStatus.triage => (label: 'Em triagem', color: t.info, icon: Icons.hourglass_top_outlined),
      DisputeStatus.analyzing => (label: 'Em análise', color: t.warning, icon: Icons.search_outlined),
      DisputeStatus.judged => (label: 'Julgado', color: t.federation, icon: Icons.gavel_outlined),
      DisputeStatus.punished => (label: 'Punido', color: t.deltaDown, icon: Icons.block_outlined),
      DisputeStatus.appealed => (label: 'Apelado', color: t.solar, icon: Icons.replay_outlined),
      DisputeStatus.dismissed => (label: 'Improcedente', color: t.success, icon: Icons.check_circle_outline),
    };

({String label, Color color}) _severityMeta(DisputeSeverity s, DsTokens t) => s == DisputeSeverity.grave
    ? (label: 'Grave', color: t.deltaDown)
    : (label: 'Simples', color: t.textSecondary);

({String label, String detail, IconData icon}) _penaltyMeta(DisputePenalty p) => switch (p) {
      DisputePenalty.warning => (label: 'Advertência', detail: 'Registro formal no histórico.', icon: Icons.warning_amber_outlined),
      DisputePenalty.reputationCut => (label: 'Redução de reputação', detail: 'Corte no índice afetado (§26).', icon: Icons.trending_down_outlined),
      DisputePenalty.silence => (label: 'Silêncio temporário', detail: 'Bloqueio de chat por período.', icon: Icons.volume_off_outlined),
      DisputePenalty.tradeRestriction => (label: 'Restrição comercial', detail: 'Suspensão de negociações.', icon: Icons.no_accounts_outlined),
      DisputePenalty.auctionBan => (label: 'Bloqueio de leilões', detail: 'Persona Non Grata (§9.4).', icon: Icons.gavel_outlined),
      DisputePenalty.none => (label: 'Sem punição', detail: 'Nenhuma sanção aplicada.', icon: Icons.remove_outlined),
    };

({IconData icon, String tag}) _evidenceMeta(EvidenceKind k) => switch (k) {
      EvidenceKind.text => (icon: Icons.notes_outlined, tag: 'Texto'),
      EvidenceKind.screenshot => (icon: Icons.image_outlined, tag: 'Captura'),
      EvidenceKind.log => (icon: Icons.receipt_long_outlined, tag: 'Log'),
      EvidenceKind.history => (icon: Icons.history_outlined, tag: 'Histórico'),
    };

/// Passo do fluxo §9.2 alcançado por status (1 Abertura … 4 Decisão … 5 IA).
int _reachedStep(DisputeStatus s) => switch (s) {
      DisputeStatus.triage => 2,
      DisputeStatus.analyzing => 3,
      DisputeStatus.judged || DisputeStatus.punished || DisputeStatus.dismissed || DisputeStatus.appealed => 4,
    };

enum _Filter { open, resolved, appealed, all }

/// Painel do Ministério das Reputações / Justiça (GDD v29 §9). Lista de denúncias
/// com estados auditáveis + detalhe (fluxo de 5 passos, evidências, conciliador,
/// decisão/punição §9.4 e histórico). Drill inline dentro do ministério.
class ReputationPanel extends ConsumerStatefulWidget {
  const ReputationPanel({super.key});

  @override
  ConsumerState<ReputationPanel> createState() => _ReputationPanelState();
}

class _ReputationPanelState extends ConsumerState<ReputationPanel> {
  String? _selectedId;
  _Filter _filter = _Filter.open;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).extension<DsTokens>()!;
    final async = ref.watch(disputesProvider);
    return async.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, __) => Center(
        child: TextButton.icon(
          onPressed: () => ref.invalidate(disputesProvider),
          icon: const Icon(Icons.refresh),
          label: const Text('Não foi possível carregar as denúncias. Tocar para tentar de novo.'),
        ),
      ),
      data: (board) {
        final selected = _selectedId == null
            ? null
            : board.disputes.where((d) => d.id == _selectedId).firstOrNull;
        if (selected != null) {
          return _DetailView(
            dispute: selected,
            onBack: () => setState(() => _selectedId = null),
          );
        }
        return ListView(
          padding: _bodyPadding(t),
          children: [
            _Kpis(board: board),
            MinistrySection(
              title: 'Denúncias',
              subtitle: 'Fila de casos com estados auditáveis (§9). Toque para ver o caso.',
              trailing: _FilterChips(value: _filter, onChanged: (f) => setState(() => _filter = f)),
              child: _DisputeList(
                board: board,
                filter: _filter,
                onOpen: (id) => setState(() => _selectedId = id),
              ),
            ),
            _ConciliatorsSection(board: board),
            const _FlowSection(),
            const _PenaltiesSection(),
          ],
        );
      },
    );
  }
}

// ── Dashboard ────────────────────────────────────────────────────────────────

class _Kpis extends StatelessWidget {
  const _Kpis({required this.board});
  final DisputeBoard board;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).extension<DsTokens>()!;
    final activeConciliators = board.conciliators.where((c) => !c.suspended).length;
    return Padding(
      padding: EdgeInsets.only(top: t.space2, bottom: t.space3),
      child: StatGrid(
        tiles: [
          StatTile(label: 'Em aberto', value: '${board.openCount}', icon: Icons.inbox_outlined, color: t.warning),
          StatTile(label: 'Resolvidas', value: '${board.resolvedCount}', icon: Icons.task_alt_outlined, color: t.success),
          StatTile(label: 'Apeladas', value: '${board.appealedCount}', icon: Icons.replay_outlined, color: t.solar),
          StatTile(label: 'Conciliadores', value: '$activeConciliators', icon: Icons.balance_outlined, color: t.federation),
        ],
      ),
    );
  }
}

class _FilterChips extends StatelessWidget {
  const _FilterChips({required this.value, required this.onChanged});
  final _Filter value;
  final ValueChanged<_Filter> onChanged;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).extension<DsTokens>()!;
    Widget chip(_Filter f, String label) => Padding(
          padding: EdgeInsets.only(left: t.space1),
          child: ChoiceChip(
            label: Text(label, style: const TextStyle(fontSize: 11.5)),
            selected: value == f,
            visualDensity: VisualDensity.compact,
            onSelected: (_) => onChanged(f),
          ),
        );
    return Wrap(
      children: [
        chip(_Filter.open, 'Abertas'),
        chip(_Filter.resolved, 'Resolvidas'),
        chip(_Filter.appealed, 'Apeladas'),
        chip(_Filter.all, 'Todas'),
      ],
    );
  }
}

class _DisputeList extends StatelessWidget {
  const _DisputeList({required this.board, required this.filter, required this.onOpen});
  final DisputeBoard board;
  final _Filter filter;
  final ValueChanged<String> onOpen;

  bool _matches(Dispute d) => switch (filter) {
        _Filter.open => d.status == DisputeStatus.triage || d.status == DisputeStatus.analyzing,
        _Filter.resolved => d.isResolved,
        _Filter.appealed => d.status == DisputeStatus.appealed,
        _Filter.all => true,
      };

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).extension<DsTokens>()!;
    final items = board.disputes.where(_matches).toList();
    if (items.isEmpty) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: t.space3),
        child: Text('Nenhuma denúncia neste filtro.', style: TextStyle(fontSize: 13, color: t.textSecondary)),
      );
    }
    return Column(
      children: [for (final d in items) _DisputeTile(dispute: d, onTap: () => onOpen(d.id))],
    );
  }
}

class _DisputeTile extends StatelessWidget {
  const _DisputeTile({required this.dispute, required this.onTap});
  final Dispute dispute;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).extension<DsTokens>()!;
    final status = _statusMeta(dispute.status, t);
    final severity = _severityMeta(dispute.severity, t);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(t.radiusMd),
      child: MinistryTile(
        accent: status.color,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(dispute.code,
                    style: GoogleFonts.rajdhani(fontWeight: FontWeight.w700, fontSize: 13, color: FwPalette.gray900)),
                SizedBox(width: t.space2),
                if (dispute.severity == DisputeSeverity.grave)
                  StatusPill(label: severity.label, color: severity.color, icon: Icons.priority_high),
                const Spacer(),
                StatusPill(label: status.label, color: status.color, icon: status.icon),
              ],
            ),
            SizedBox(height: t.space2),
            Row(
              children: [
                Icon(Icons.person_outline, size: 14, color: t.textSecondary),
                SizedBox(width: t.space1),
                Flexible(
                  child: Text(dispute.reporter,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: FwPalette.gray800)),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: t.space1),
                  child: Icon(Icons.arrow_forward, size: 12, color: t.textSecondary),
                ),
                Flexible(
                  child: Text(dispute.accused,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: t.deltaDown)),
                ),
              ],
            ),
            SizedBox(height: t.space1),
            Text(dispute.summary,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 12, height: 1.3, color: t.textSecondary)),
            SizedBox(height: t.space2),
            Row(
              children: [
                Icon(Icons.shield_outlined, size: 12, color: t.textSecondary),
                SizedBox(width: t.space1),
                Text(dispute.affectedIndex, style: TextStyle(fontSize: 11, color: t.textSecondary)),
                const Spacer(),
                if (dispute.fromExpiredAgreement) ...[
                  Icon(Icons.handshake_outlined, size: 12, color: t.info),
                  SizedBox(width: t.space1),
                  Text('Acordo §26.5', style: TextStyle(fontSize: 10.5, color: t.info)),
                  SizedBox(width: t.space2),
                ],
                Text(dispute.deadline,
                    style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w600,
                        color: dispute.deadline.startsWith('Resta') ? t.warning : t.textSecondary)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ConciliatorsSection extends StatelessWidget {
  const _ConciliatorsSection({required this.board});
  final DisputeBoard board;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).extension<DsTokens>()!;
    return MinistrySection(
      title: 'Conciliadores (§9.3)',
      subtitle: 'Neutros Registrados · 50 Fert\$/dia + 3 por denúncia se a decisão não for revertida (§26.7).',
      trailing: TextButton(
        onPressed: () => mockMinistryAction(context, 'Gestão de conciliadores — em breve'),
        child: const Text('Gerir'),
      ),
      child: Column(
        children: [
          for (final c in board.conciliators)
            MinistryTile(
              accent: c.suspended ? t.deltaDown : t.federation,
              child: Row(
                children: [
                  Icon(Icons.balance_outlined, size: 18, color: c.suspended ? t.deltaDown : t.federation),
                  SizedBox(width: t.space3),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(c.name,
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: FwPalette.gray900)),
                        Text('${c.casesResolved} casos · ${c.openCases} em aberto · ${c.reversals} reversões',
                            style: TextStyle(fontSize: 11.5, color: t.textSecondary)),
                      ],
                    ),
                  ),
                  if (c.suspended)
                    StatusPill(label: 'Suspenso', color: t.deltaDown, icon: Icons.pause_circle_outline)
                  else
                    StatusPill(label: 'Ativo', color: t.success, icon: Icons.check_circle_outline),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _FlowSection extends StatelessWidget {
  const _FlowSection();

  @override
  Widget build(BuildContext context) {
    return const MinistrySection(
      title: 'Fluxo de justiça (§9.2)',
      subtitle: 'Cinco passos: da abertura à decisão. Casos graves vão direto à equipe Fertways.',
      child: _FlowStepper(reached: 0),
    );
  }
}

class _PenaltiesSection extends StatelessWidget {
  const _PenaltiesSection();

  static const _all = [
    DisputePenalty.warning,
    DisputePenalty.reputationCut,
    DisputePenalty.silence,
    DisputePenalty.tradeRestriction,
    DisputePenalty.auctionBan,
  ];

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).extension<DsTokens>()!;
    return MinistrySection(
      title: 'Punições previstas (§9.4)',
      child: Column(
        children: [
          for (final p in _all) ...[
            Padding(
              padding: EdgeInsets.symmetric(vertical: t.space1),
              child: Row(
                children: [
                  Icon(_penaltyMeta(p).icon, size: 16, color: t.deltaDown),
                  SizedBox(width: t.space2),
                  Expanded(
                    child: RichText(
                      text: TextSpan(
                        style: const TextStyle(fontSize: 12.5, color: FwPalette.gray900),
                        children: [
                          TextSpan(text: _penaltyMeta(p).label, style: const TextStyle(fontWeight: FontWeight.w700)),
                          TextSpan(text: ' — ${_penaltyMeta(p).detail}', style: TextStyle(color: t.textSecondary)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ── Detalhe da denúncia ──────────────────────────────────────────────────────

class _DetailView extends StatelessWidget {
  const _DetailView({required this.dispute, required this.onBack});
  final Dispute dispute;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).extension<DsTokens>()!;
    final status = _statusMeta(dispute.status, t);
    final severity = _severityMeta(dispute.severity, t);
    final penalty = _penaltyMeta(dispute.penalty);
    return ListView(
      padding: _bodyPadding(t),
      children: [
        Padding(
          padding: EdgeInsets.symmetric(vertical: t.space2),
          child: InkWell(
            onTap: onBack,
            borderRadius: BorderRadius.circular(t.radiusSm),
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: t.space1),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.arrow_back, size: 18, color: t.textSecondary),
                  SizedBox(width: t.space1),
                  Text('Todas as denúncias', style: TextStyle(fontSize: 13, color: t.textSecondary)),
                ],
              ),
            ),
          ),
        ),
        // Cabeçalho do caso.
        MinistrySection(
          title: dispute.code,
          trailing: StatusPill(label: status.label, color: status.color, icon: status.icon),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: t.space2,
                runSpacing: t.space1,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  StatusPill(
                      label: 'Gravidade: ${severity.label}',
                      color: severity.color,
                      icon: dispute.severity == DisputeSeverity.grave ? Icons.priority_high : Icons.flag_outlined),
                  StatusPill(label: dispute.affectedIndex, color: t.federation, icon: Icons.shield_outlined),
                  if (dispute.value > 0)
                    StatusPill(label: 'Fert\$ ${dispute.value}', color: t.solar, icon: Icons.paid_outlined),
                  if (dispute.fromExpiredAgreement)
                    StatusPill(label: 'Acordo de Troca §26.5', color: t.info, icon: Icons.handshake_outlined),
                ],
              ),
              SizedBox(height: t.space3),
              Row(
                children: [
                  Expanded(child: _Party(label: 'Denunciante', name: dispute.reporter, color: t.textSecondary)),
                  Icon(Icons.arrow_forward, size: 16, color: t.textSecondary),
                  Expanded(child: _Party(label: 'Denunciado', name: dispute.accused, color: t.deltaDown, alignEnd: true)),
                ],
              ),
              SizedBox(height: t.space3),
              Text(dispute.summary,
                  style: const TextStyle(fontSize: 13.5, height: 1.4, color: FwPalette.gray900)),
              SizedBox(height: t.space2),
              Row(
                children: [
                  Icon(Icons.event_outlined, size: 13, color: t.textSecondary),
                  SizedBox(width: t.space1),
                  Text('Aberta no ${dispute.openedDay}', style: TextStyle(fontSize: 11.5, color: t.textSecondary)),
                  const Spacer(),
                  Icon(Icons.timer_outlined, size: 13, color: t.textSecondary),
                  SizedBox(width: t.space1),
                  Text('Prazo: ${dispute.deadline} (§26.8)',
                      style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                          color: dispute.deadline.startsWith('Resta') ? t.warning : t.textSecondary)),
                ],
              ),
            ],
          ),
        ),
        // Fluxo de 5 passos com a posição atual.
        MinistrySection(
          title: 'Fluxo do caso (§9.2)',
          child: _FlowStepper(reached: _reachedStep(dispute.status)),
        ),
        // Evidências.
        MinistrySection(
          title: 'Evidências (§9.2)',
          subtitle: 'Evidência mínima obrigatória para prosseguir (§26.8).',
          child: dispute.evidence.isEmpty
              ? Text('Sem evidências anexadas.', style: TextStyle(fontSize: 12.5, color: t.textSecondary))
              : Column(
                  children: [
                    for (final e in dispute.evidence)
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: t.space1),
                        child: Row(
                          children: [
                            Container(
                              width: 30,
                              height: 30,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                  color: t.surfaceSunken, borderRadius: BorderRadius.circular(t.radiusSm)),
                              child: Icon(_evidenceMeta(e.kind).icon, size: 15, color: t.textSecondary),
                            ),
                            SizedBox(width: t.space3),
                            Expanded(
                              child: Text(e.label,
                                  style: const TextStyle(fontSize: 12.5, color: FwPalette.gray900)),
                            ),
                            SizedBox(width: t.space2),
                            Text(_evidenceMeta(e.kind).tag,
                                style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w600, color: t.textSecondary)),
                          ],
                        ),
                      ),
                  ],
                ),
        ),
        // Conciliador.
        MinistrySection(
          title: 'Conciliador (§9.3)',
          child: Row(
            children: [
              Icon(Icons.balance_outlined, size: 18,
                  color: dispute.conciliator.isEmpty ? t.textSecondary : t.federation),
              SizedBox(width: t.space2),
              Expanded(
                child: Text(
                  dispute.conciliator.isEmpty
                      ? 'Não atribuído — aguardando triagem.'
                      : dispute.conciliator,
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: dispute.conciliator.isEmpty ? FontWeight.w400 : FontWeight.w700,
                      color: dispute.conciliator.isEmpty ? t.textSecondary : FwPalette.gray900),
                ),
              ),
              if (dispute.severity == DisputeSeverity.grave)
                StatusPill(label: 'Equipe Fertways', color: t.deltaDown, icon: Icons.groups_outlined),
            ],
          ),
        ),
        // Decisão / punição.
        MinistrySection(
          title: 'Decisão (§9.4)',
          child: dispute.penalty == DisputePenalty.none
              ? Row(
                  children: [
                    Icon(Icons.hourglass_top_outlined, size: 16, color: t.textSecondary),
                    SizedBox(width: t.space2),
                    Expanded(
                      child: Text(
                          dispute.status == DisputeStatus.dismissed
                              ? 'Improcedente — nenhuma sanção aplicada.'
                              : 'Aguardando decisão do conciliador.',
                          style: TextStyle(fontSize: 12.5, color: t.textSecondary)),
                    ),
                  ],
                )
              : MinistryTile(
                  accent: t.deltaDown,
                  child: Row(
                    children: [
                      Icon(penalty.icon, size: 18, color: t.deltaDown),
                      SizedBox(width: t.space3),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(penalty.label,
                                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: FwPalette.gray900)),
                            Text(penalty.detail, style: TextStyle(fontSize: 11.5, color: t.textSecondary)),
                          ],
                        ),
                      ),
                      if (dispute.status == DisputeStatus.appealed)
                        StatusPill(label: 'Em apelação', color: t.solar, icon: Icons.replay_outlined),
                    ],
                  ),
                ),
        ),
        // Histórico auditável.
        MinistrySection(
          title: 'Histórico auditável',
          child: Column(
            children: [
              for (var i = 0; i < dispute.timeline.length; i++)
                _TimelineRow(event: dispute.timeline[i], last: i == dispute.timeline.length - 1),
            ],
          ),
        ),
        // Ações administrativas (mock).
        _AdminActions(dispute: dispute),
      ],
    );
  }
}

class _Party extends StatelessWidget {
  const _Party({required this.label, required this.name, required this.color, this.alignEnd = false});
  final String label;
  final String name;
  final Color color;
  final bool alignEnd;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).extension<DsTokens>()!;
    return Column(
      crossAxisAlignment: alignEnd ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Text(label.toUpperCase(),
            style: GoogleFonts.rajdhani(fontWeight: FontWeight.w700, fontSize: 10, letterSpacing: 0.5, color: t.textSecondary)),
        SizedBox(height: t.space1),
        Text(name,
            textAlign: alignEnd ? TextAlign.end : TextAlign.start,
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: color)),
      ],
    );
  }
}

class _TimelineRow extends StatelessWidget {
  const _TimelineRow({required this.event, required this.last});
  final DisputeEvent event;
  final bool last;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).extension<DsTokens>()!;
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 12,
                height: 12,
                margin: const EdgeInsets.only(top: 3),
                decoration: BoxDecoration(
                  color: t.federation.withValues(alpha: 0.18),
                  shape: BoxShape.circle,
                  border: Border.all(color: t.federation, width: 1.5),
                ),
              ),
              if (!last) Expanded(child: Container(width: 2, color: t.borderDefault)),
            ],
          ),
          SizedBox(width: t.space3),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: last ? 0 : t.space3),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(event.label,
                            style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: FwPalette.gray900)),
                      ),
                      Text(event.time, style: TextStyle(fontSize: 10.5, color: t.textSecondary)),
                    ],
                  ),
                  if (event.note.isNotEmpty) ...[
                    const SizedBox(height: 1),
                    Text(event.note, style: TextStyle(fontSize: 11.5, height: 1.3, color: t.textSecondary)),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AdminActions extends StatelessWidget {
  const _AdminActions({required this.dispute});
  final Dispute dispute;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).extension<DsTokens>()!;
    final canAssign = dispute.conciliator.isEmpty;
    final canDecide = !dispute.isResolved;
    return MinistrySection(
      title: 'Ações do ministério',
      subtitle: 'Painel administrativo (§9). Ações são simuladas nesta versão.',
      child: Wrap(
        spacing: t.space2,
        runSpacing: t.space2,
        children: [
          OutlinedButton.icon(
            onPressed: canAssign ? () => mockMinistryAction(context, 'Conciliador atribuído — em breve') : null,
            icon: const Icon(Icons.person_add_alt_outlined, size: 16),
            label: const Text('Atribuir conciliador'),
          ),
          OutlinedButton.icon(
            onPressed: canDecide ? () => mockMinistryAction(context, 'Registrar decisão — em breve') : null,
            icon: const Icon(Icons.gavel_outlined, size: 16),
            label: const Text('Registrar decisão'),
          ),
          FilledButton.icon(
            onPressed: canDecide
                ? () => mockMinistryAction(context, 'Aplicar punição (§9.4) — em breve')
                : null,
            style: FilledButton.styleFrom(backgroundColor: t.deltaDown),
            icon: const Icon(Icons.block_outlined, size: 16),
            label: const Text('Aplicar punição'),
          ),
        ],
      ),
    );
  }
}

// ── Fluxo de 5 passos (§9.2) ─────────────────────────────────────────────────

class _FlowStepper extends StatelessWidget {
  /// [reached] = índice do passo alcançado (1..5); 0 = só informativo (nenhum
  /// destacado como atual).
  const _FlowStepper({required this.reached});
  final int reached;

  static const _steps = <({String label, IconData icon})>[
    (label: 'Abertura (texto, capturas e denunciado)', icon: Icons.report_outlined),
    (label: 'Triagem automática (logs · simples vs grave)', icon: Icons.rule_outlined),
    (label: 'Conciliador analisa (texto, logs, histórico)', icon: Icons.search_outlined),
    (label: 'Decisão (improcedente · advertência · punição)', icon: Icons.gavel_outlined),
    (label: 'Futuro: triagem assistida por IA', icon: Icons.smart_toy_outlined),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var i = 0; i < _steps.length; i++)
          _FlowRow(
            step: _steps[i],
            index: i + 1,
            state: reached == 0
                ? _StepState.neutral
                : (i + 1 < reached)
                    ? _StepState.done
                    : (i + 1 == reached)
                        ? _StepState.current
                        : _StepState.pending,
            last: i == _steps.length - 1,
            future: i == _steps.length - 1,
          ),
      ],
    );
  }
}

enum _StepState { neutral, done, current, pending }

class _FlowRow extends StatelessWidget {
  const _FlowRow({
    required this.step,
    required this.index,
    required this.state,
    required this.last,
    required this.future,
  });
  final ({String label, IconData icon}) step;
  final int index;
  final _StepState state;
  final bool last;
  final bool future;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).extension<DsTokens>()!;
    final (Color color, Color bg) = switch (state) {
      _StepState.done => (t.success, t.success.withValues(alpha: 0.14)),
      _StepState.current => (t.federation, t.federation.withValues(alpha: 0.16)),
      _StepState.pending => (t.textSecondary, t.surfaceSunken),
      _StepState.neutral => (future ? t.textSecondary : FwPalette.gray700, t.surfaceSunken),
    };
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 30,
                height: 30,
                alignment: Alignment.center,
                decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
                child: Icon(
                  state == _StepState.done ? Icons.check : step.icon,
                  size: 15,
                  color: color,
                ),
              ),
              if (!last) Expanded(child: Container(width: 2, color: t.borderDefault)),
            ],
          ),
          SizedBox(width: t.space3),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(top: 6, bottom: last ? 0 : t.space4),
              child: Row(
                children: [
                  Expanded(
                    child: Text(step.label,
                        style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: state == _StepState.current ? FontWeight.w700 : FontWeight.w500,
                            color: future && state != _StepState.current ? t.textSecondary : FwPalette.gray900)),
                  ),
                  if (state == _StepState.current) ...[
                    SizedBox(width: t.space2),
                    StatusPill(label: 'Atual', color: t.federation),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
