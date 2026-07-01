import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../app/theme/ds_colors.dart';
import '../../app/theme/ds_tokens.dart';
import '../../data/providers.dart';
import '../../domain/models/public_office.dart';

({IconData icon, Color color}) _kindMeta(OfficeKind k, DsTokens t) => switch (k) {
      OfficeKind.conciliator => (icon: Icons.balance_outlined, color: t.federation),
      OfficeKind.marketInspector => (icon: Icons.fact_check_outlined, color: t.info),
      OfficeKind.spaceportClerk => (icon: Icons.rocket_launch_outlined, color: t.solar),
      OfficeKind.reporter => (icon: Icons.campaign_outlined, color: t.teal),
      OfficeKind.treasuryAssistant => (icon: Icons.account_balance_wallet_outlined, color: t.success),
    };

enum _Tab { offices, admin }

/// Cargos Públicos Neutros (GDD v29 §14). Lista os 5 cargos com elegibilidade
/// (§14.3), índice de reputação por cargo (§26.6) e candidatura; aba de
/// Administração (§14.4) com candidatos, ocupantes e pagamentos. Drill-in da
/// Capital (mantém HUD/nav).
class PublicOfficesScreen extends ConsumerStatefulWidget {
  const PublicOfficesScreen({super.key});

  @override
  ConsumerState<PublicOfficesScreen> createState() => _PublicOfficesScreenState();
}

class _PublicOfficesScreenState extends ConsumerState<PublicOfficesScreen> {
  _Tab _tab = _Tab.offices;

  void _toast(String m) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(m), behavior: SnackBarBehavior.floating, duration: const Duration(seconds: 2)),
      );

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).extension<DsTokens>()!;
    final board = ref.watch(publicOfficeProvider);

    return ColoredBox(
      color: t.surfacePage,
      child: board.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => Center(
          child: TextButton.icon(
            onPressed: () => ref.invalidate(publicOfficeProvider),
            icon: const Icon(Icons.refresh),
            label: const Text('Não foi possível carregar os cargos. Tocar para tentar de novo.'),
          ),
        ),
        data: (data) => Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const _Header(),
            _Tabs(value: _tab, onChanged: (v) => setState(() => _tab = v)),
            Expanded(
              child: Align(
                alignment: Alignment.topCenter,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 840),
                  child: switch (_tab) {
                    _Tab.offices => _OfficesTab(board: data, onApply: _toast),
                    _Tab.admin => _AdminTab(board: data, onAction: _toast),
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).extension<DsTokens>()!;
    return Padding(
      padding: EdgeInsets.fromLTRB(t.space4, t.space4, t.space4, t.space2),
      child: Row(
        children: [
          InkWell(
            onTap: () => context.go('/capital'),
            borderRadius: BorderRadius.circular(t.radiusSm),
            child: Padding(
              padding: const EdgeInsets.all(6),
              child: Icon(Icons.arrow_back, size: 20, color: t.textSecondary),
            ),
          ),
          SizedBox(width: t.space2),
          const Icon(Icons.badge_outlined, size: 22, color: FwPalette.rust600),
          SizedBox(width: t.space2),
          Text('Cargos Públicos',
              style: GoogleFonts.rajdhani(fontWeight: FontWeight.w700, fontSize: 22, color: FwPalette.gray900)),
        ],
      ),
    );
  }
}

class _Tabs extends StatelessWidget {
  const _Tabs({required this.value, required this.onChanged});
  final _Tab value;
  final ValueChanged<_Tab> onChanged;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).extension<DsTokens>()!;
    Widget chip(_Tab tab, String label, IconData icon) => Padding(
          padding: EdgeInsets.only(right: t.space2),
          child: ChoiceChip(
            avatar: Icon(icon, size: 15, color: value == tab ? FwPalette.rust600 : t.textSecondary),
            label: Text(label),
            selected: value == tab,
            onSelected: (_) => onChanged(tab),
          ),
        );
    return Padding(
      padding: EdgeInsets.fromLTRB(t.space4, 0, t.space4, t.space2),
      child: Row(
        children: [
          chip(_Tab.offices, 'Cargos', Icons.badge_outlined),
          chip(_Tab.admin, 'Administração', Icons.admin_panel_settings_outlined),
        ],
      ),
    );
  }
}

// ── Aba Cargos ───────────────────────────────────────────────────────────────

class _OfficesTab extends StatelessWidget {
  const _OfficesTab({required this.board, required this.onApply});
  final PublicOfficeBoard board;
  final ValueChanged<String> onApply;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).extension<DsTokens>()!;
    return ListView(
      padding: EdgeInsets.fromLTRB(t.space4, t.space2, t.space4, t.space6),
      children: [
        _EligibilityCard(board: board),
        SizedBox(height: t.space3),
        for (final o in board.offices)
          _OfficeCard(
            office: o,
            canApply: board.isEligible,
            onApply: () => onApply(board.isEligible
                ? 'Candidatura a ${o.title} enviada — em breve'
                : 'Cumpra todos os critérios (§14.3) para se candidatar'),
          ),
      ],
    );
  }
}

class _EligibilityCard extends StatelessWidget {
  const _EligibilityCard({required this.board});
  final PublicOfficeBoard board;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).extension<DsTokens>()!;
    final scheme = Theme.of(context).colorScheme;
    final ok = board.isEligible;
    final color = ok ? t.success : t.warning;
    return Container(
      padding: EdgeInsets.all(t.space4),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(t.radiusCard),
        border: Border.all(color: color.withValues(alpha: 0.45)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(ok ? Icons.verified_outlined : Icons.pending_outlined, size: 20, color: color),
              SizedBox(width: t.space2),
              Expanded(
                child: Text(ok ? 'Você está elegível (§14.3)' : 'Quase lá — critérios pendentes',
                    style: GoogleFonts.rajdhani(fontWeight: FontWeight.w700, fontSize: 16, color: FwPalette.gray900)),
              ),
              Text('${board.metCount}/${board.eligibility.length}',
                  style: GoogleFonts.rajdhani(fontWeight: FontWeight.w700, fontSize: 16, color: color)),
            ],
          ),
          SizedBox(height: t.space1),
          Text('Critérios únicos para qualquer cargo público neutro (§14.3).',
              style: TextStyle(fontSize: 12, color: t.textSecondary)),
          SizedBox(height: t.space3),
          for (final c in board.eligibility)
            Padding(
              padding: EdgeInsets.symmetric(vertical: t.space1),
              child: Row(
                children: [
                  Icon(c.met ? Icons.check_circle : Icons.radio_button_unchecked,
                      size: 16, color: c.met ? t.success : t.textSecondary),
                  SizedBox(width: t.space2),
                  Expanded(
                    child: Text(c.label,
                        style: TextStyle(
                            fontSize: 12.5,
                            color: c.met ? FwPalette.gray900 : t.textSecondary)),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _OfficeCard extends StatelessWidget {
  const _OfficeCard({required this.office, required this.canApply, required this.onApply});
  final PublicOffice office;
  final bool canApply;
  final VoidCallback onApply;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).extension<DsTokens>()!;
    final scheme = Theme.of(context).colorScheme;
    final meta = _kindMeta(office.kind, t);
    return Container(
      margin: EdgeInsets.only(bottom: t.space2),
      padding: EdgeInsets.all(t.space3),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(t.radiusCard),
        border: Border(
          left: BorderSide(color: meta.color, width: 3),
          top: BorderSide(color: t.borderDefault),
          right: BorderSide(color: t.borderDefault),
          bottom: BorderSide(color: t.borderDefault),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                alignment: Alignment.center,
                decoration: BoxDecoration(color: meta.color.withValues(alpha: 0.14), borderRadius: BorderRadius.circular(t.radiusMd)),
                child: Icon(meta.icon, size: 20, color: meta.color),
              ),
              SizedBox(width: t.space3),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(office.title,
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: FwPalette.gray900)),
                    Text(office.institution, style: TextStyle(fontSize: 11.5, color: t.textSecondary)),
                  ],
                ),
              ),
              SizedBox(width: t.space2),
              _Pill(
                label: office.hasVacancy ? '${office.vacantSeats} vaga(s)' : 'Ocupado ${office.holders.length}/${office.seats}',
                color: office.hasVacancy ? t.success : t.textSecondary,
                icon: office.hasVacancy ? Icons.how_to_reg_outlined : Icons.people_outline,
              ),
            ],
          ),
          SizedBox(height: t.space2),
          Text(office.description, style: TextStyle(fontSize: 12, height: 1.3, color: t.textSecondary)),
          SizedBox(height: t.space2),
          Row(
            children: [
              Icon(Icons.paid_outlined, size: 13, color: t.solar),
              SizedBox(width: t.space1),
              Expanded(
                child: Text(office.salary,
                    style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: t.solar)),
              ),
            ],
          ),
          SizedBox(height: t.space1),
          Row(
            children: [
              Icon(Icons.shield_outlined, size: 13, color: t.federation),
              SizedBox(width: t.space1),
              Expanded(
                child: Text('Índice: ${office.reputationIndex} (§26.6)',
                    style: TextStyle(fontSize: 11.5, color: t.textSecondary)),
              ),
            ],
          ),
          if (office.holders.isNotEmpty) ...[
            SizedBox(height: t.space2),
            for (final h in office.holders)
              Padding(
                padding: EdgeInsets.only(top: t.space1),
                child: Row(
                  children: [
                    Icon(Icons.person_outline, size: 14, color: t.textSecondary),
                    SizedBox(width: t.space1),
                    Text(h.name,
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: FwPalette.gray800)),
                    SizedBox(width: t.space2),
                    Expanded(
                      child: Text('desde ${h.since} · ${h.performance}',
                          style: TextStyle(fontSize: 11, color: t.textSecondary)),
                    ),
                  ],
                ),
              ),
          ],
          if (office.hasVacancy) ...[
            SizedBox(height: t.space3),
            Align(
              alignment: Alignment.centerLeft,
              child: FilledButton.icon(
                onPressed: onApply,
                style: FilledButton.styleFrom(
                  backgroundColor: canApply ? meta.color : t.surfaceSunken,
                  foregroundColor: canApply ? Colors.white : t.textSecondary,
                  visualDensity: VisualDensity.compact,
                ),
                icon: Icon(canApply ? Icons.how_to_reg_outlined : Icons.lock_outline, size: 16),
                label: const Text('Candidatar-se'),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ── Aba Administração (§14.4) ────────────────────────────────────────────────

class _AdminTab extends StatelessWidget {
  const _AdminTab({required this.board, required this.onAction});
  final PublicOfficeBoard board;
  final ValueChanged<String> onAction;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).extension<DsTokens>()!;
    final holders = [
      for (final o in board.offices)
        for (final h in o.holders) (office: o.title, holder: h),
    ];
    return ListView(
      padding: EdgeInsets.fromLTRB(t.space4, t.space2, t.space4, t.space6),
      children: [
        _SectionTitle(title: 'Candidaturas pendentes', count: board.candidates.length),
        for (final c in board.candidates)
          _CandidateRow(
            candidate: c,
            onApprove: () => onAction('Candidatura de ${c.name} aprovada — em breve'),
            onReject: () => onAction('Candidatura de ${c.name} recusada — em breve'),
          ),
        SizedBox(height: t.space4),
        _SectionTitle(title: 'Ocupantes atuais', count: holders.length),
        for (final h in holders)
          _HolderRow(
            office: h.office,
            holder: h.holder,
            onSuspend: () => onAction('${h.holder.name} suspenso(a) de ${h.office} — em breve'),
            onDismiss: () => onAction('${h.holder.name} demitido(a) de ${h.office} — em breve'),
          ),
        SizedBox(height: t.space4),
        _SectionTitle(title: 'Pagamentos recentes', count: board.payments.length),
        for (final p in board.payments) _PaymentRow(payment: p),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title, required this.count});
  final String title;
  final int count;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).extension<DsTokens>()!;
    return Padding(
      padding: EdgeInsets.only(bottom: t.space2),
      child: Row(
        children: [
          Text(title.toUpperCase(),
              style: GoogleFonts.rajdhani(
                  fontWeight: FontWeight.w700, fontSize: 12, letterSpacing: 1.1, color: FwPalette.gray500)),
          SizedBox(width: t.space2),
          Text('$count', style: TextStyle(fontSize: 11, color: t.textSecondary)),
        ],
      ),
    );
  }
}

class _Tile extends StatelessWidget {
  const _Tile({required this.child, this.accent});
  final Widget child;
  final Color? accent;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).extension<DsTokens>()!;
    final scheme = Theme.of(context).colorScheme;
    return Container(
      margin: EdgeInsets.only(bottom: t.space2),
      padding: EdgeInsets.all(t.space3),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(t.radiusMd),
        border: Border(
          left: BorderSide(color: accent ?? t.borderDefault, width: accent != null ? 3 : 1),
          top: BorderSide(color: t.borderDefault),
          right: BorderSide(color: t.borderDefault),
          bottom: BorderSide(color: t.borderDefault),
        ),
      ),
      child: child,
    );
  }
}

class _CandidateRow extends StatelessWidget {
  const _CandidateRow({required this.candidate, required this.onApprove, required this.onReject});
  final OfficeCandidate candidate;
  final VoidCallback onApprove;
  final VoidCallback onReject;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).extension<DsTokens>()!;
    return _Tile(
      accent: candidate.eligible ? t.success : t.warning,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text('${candidate.name} → ${candidate.officeTitle}',
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: FwPalette.gray900)),
              ),
              _Pill(
                label: candidate.eligible ? 'Elegível' : 'Não elegível',
                color: candidate.eligible ? t.success : t.warning,
                icon: candidate.eligible ? Icons.check_circle_outline : Icons.error_outline,
              ),
            ],
          ),
          SizedBox(height: t.space1),
          Text('Inscrição no ${candidate.appliedDay}${candidate.note.isNotEmpty ? ' · ${candidate.note}' : ''}',
              style: TextStyle(fontSize: 11.5, color: t.textSecondary)),
          SizedBox(height: t.space2),
          Row(
            children: [
              FilledButton.icon(
                onPressed: candidate.eligible ? onApprove : null,
                style: FilledButton.styleFrom(backgroundColor: t.success, visualDensity: VisualDensity.compact),
                icon: const Icon(Icons.check, size: 15),
                label: const Text('Aprovar'),
              ),
              SizedBox(width: t.space2),
              OutlinedButton.icon(
                onPressed: onReject,
                style: OutlinedButton.styleFrom(visualDensity: VisualDensity.compact, foregroundColor: t.textSecondary),
                icon: const Icon(Icons.close, size: 15),
                label: const Text('Recusar'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HolderRow extends StatelessWidget {
  const _HolderRow({required this.office, required this.holder, required this.onSuspend, required this.onDismiss});
  final String office;
  final OfficeHolder holder;
  final VoidCallback onSuspend;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).extension<DsTokens>()!;
    return _Tile(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.person_outline, size: 16, color: t.textSecondary),
              SizedBox(width: t.space2),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${holder.name} · $office',
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: FwPalette.gray900)),
                    Text('desde ${holder.since} · ${holder.performance}',
                        style: TextStyle(fontSize: 11, color: t.textSecondary)),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: t.space2),
          Row(
            children: [
              OutlinedButton.icon(
                onPressed: onSuspend,
                style: OutlinedButton.styleFrom(visualDensity: VisualDensity.compact, foregroundColor: t.warning),
                icon: const Icon(Icons.pause_circle_outline, size: 15),
                label: const Text('Suspender'),
              ),
              SizedBox(width: t.space2),
              TextButton.icon(
                onPressed: onDismiss,
                style: TextButton.styleFrom(visualDensity: VisualDensity.compact, foregroundColor: t.deltaDown),
                icon: const Icon(Icons.person_remove_outlined, size: 15),
                label: const Text('Demitir'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PaymentRow extends StatelessWidget {
  const _PaymentRow({required this.payment});
  final OfficePayment payment;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).extension<DsTokens>()!;
    return _Tile(
      child: Row(
        children: [
          Icon(Icons.paid_outlined, size: 16, color: t.solar),
          SizedBox(width: t.space2),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(payment.holder,
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: FwPalette.gray900)),
                Text('${payment.officeTitle} · ${payment.day}',
                    style: TextStyle(fontSize: 11, color: t.textSecondary)),
              ],
            ),
          ),
          Text('+${payment.amount} Fert\$',
              style: GoogleFonts.rajdhani(fontWeight: FontWeight.w700, fontSize: 15, color: t.solar)),
        ],
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.label, required this.color, this.icon});
  final String label;
  final Color color;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[Icon(icon, size: 11, color: color), const SizedBox(width: 4)],
          Text(label, style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w600, color: color)),
        ],
      ),
    );
  }
}
