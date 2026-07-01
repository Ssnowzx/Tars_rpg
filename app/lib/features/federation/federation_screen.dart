import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../app/theme/ds_colors.dart';
import '../../app/theme/ds_tokens.dart';
import '../../data/providers.dart';
import '../../domain/models/federation.dart';

({String label, IconData icon, Color color}) _roleMeta(FederationRole r, DsTokens t) => switch (r) {
      FederationRole.leader => (label: 'Líder', icon: Icons.workspace_premium_outlined, color: t.solar),
      FederationRole.diplomat => (label: 'Diplomata', icon: Icons.handshake_outlined, color: t.info),
      FederationRole.member => (label: 'Membro', icon: Icons.person_outline, color: t.textSecondary),
    };

/// Tela da Federação (GDD v29 §4): identidade, tesouro/contribuição, cargos
/// (Líder com voto de Minerva + Diplomata), regras de tributação interna e
/// antimonopólio, lista de até 12 membros, aliadas e atalho para o chat.
/// Drill-in do shell (mantém HUD/nav).
class FederationScreen extends ConsumerWidget {
  const FederationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = Theme.of(context).extension<DsTokens>()!;
    final federation = ref.watch(federationProvider);

    return ColoredBox(
      color: t.surfacePage,
      child: federation.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => Center(
          child: TextButton.icon(
            onPressed: () => ref.invalidate(federationProvider),
            icon: const Icon(Icons.refresh),
            label: const Text('Não foi possível carregar a federação. Tocar para tentar de novo.'),
          ),
        ),
        data: (fed) => Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const _Header(),
            Expanded(child: _Body(fed: fed)),
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
            onTap: () => context.go('/profile'),
            borderRadius: BorderRadius.circular(t.radiusSm),
            child: Padding(
              padding: const EdgeInsets.all(6),
              child: Icon(Icons.arrow_back, size: 20, color: t.textSecondary),
            ),
          ),
          SizedBox(width: t.space2),
          Icon(Icons.groups, size: 22, color: t.federation),
          SizedBox(width: t.space2),
          Text('Federação',
              style: GoogleFonts.rajdhani(fontWeight: FontWeight.w700, fontSize: 22, color: FwPalette.gray900)),
        ],
      ),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({required this.fed});
  final Federation fed;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).extension<DsTokens>()!;
    final money = NumberFormat.decimalPattern(Localizations.localeOf(context).languageCode);
    if (!fed.inFederation) return const _EmptyFederation();
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 840),
        child: ListView(
          padding: EdgeInsets.fromLTRB(t.space4, t.space2, t.space4, t.space6),
          children: [
            _IdentityCard(fed: fed),
            SizedBox(height: t.space3),
            _TreasuryCard(fed: fed, money: money),
            SizedBox(height: t.space3),
            _RulesCard(fed: fed),
            SizedBox(height: t.space3),
            _MembersCard(fed: fed, money: money),
            SizedBox(height: t.space3),
            if (fed.allies.isNotEmpty) ...[
              _AlliesCard(fed: fed),
              SizedBox(height: t.space3),
            ],
            const _CommunicationCard(),
          ],
        ),
      ),
    );
  }
}

/// Estado vazio: colono ainda não pertence a uma federação (§4). Fundar exige
/// Status Cívico + Honra Militar; entrar depende de convite.
class _EmptyFederation extends StatelessWidget {
  const _EmptyFederation();

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).extension<DsTokens>()!;
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 460),
        child: Padding(
          padding: EdgeInsets.all(t.space6),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.groups_outlined, size: 56, color: t.textSecondary.withValues(alpha: 0.5)),
              SizedBox(height: t.space4),
              Text(
                'Você ainda não está em uma federação',
                textAlign: TextAlign.center,
                style: GoogleFonts.rajdhani(fontWeight: FontWeight.w700, fontSize: 20, color: FwPalette.gray900),
              ),
              SizedBox(height: t.space2),
              Text(
                'Federações (§4) reúnem até 12 colonos: fundo comum, tributação interna com isenção e alianças com 50% de desconto. '
                'Funde uma (exige Status Cívico e Honra Militar) ou aguarde um convite de vizinhos.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, height: 1.4, color: t.textSecondary),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Container de seção padrão: cabeçalho (ícone + título + nota opcional) + corpo.
class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.icon, required this.title, required this.child, this.trailing});
  final IconData icon;
  final String title;
  final Widget child;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).extension<DsTokens>()!;
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: EdgeInsets.all(t.space4),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(t.radiusCard),
        border: Border.all(color: t.borderDefault),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 17, color: t.textSecondary),
              SizedBox(width: t.space2),
              Expanded(
                child: Text(title,
                    style: GoogleFonts.rajdhani(
                        fontWeight: FontWeight.w700, fontSize: 13.5, letterSpacing: 0.4, color: FwPalette.gray800)),
              ),
              if (trailing != null) trailing!,
            ],
          ),
          SizedBox(height: t.space3),
          child,
        ],
      ),
    );
  }
}

class _IdentityCard extends StatelessWidget {
  const _IdentityCard({required this.fed});
  final Federation fed;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).extension<DsTokens>()!;
    final scheme = Theme.of(context).colorScheme;
    final initial = fed.name.isNotEmpty ? fed.name[0].toUpperCase() : '?';
    return Container(
      padding: EdgeInsets.all(t.space4),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(t.radiusCard),
        border: Border.all(color: t.borderDefault),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 52,
                height: 52,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: t.federation.withValues(alpha: 0.12),
                  border: Border.all(color: t.federation.withValues(alpha: 0.45), width: 1.5),
                ),
                child: Text(initial,
                    style: GoogleFonts.rajdhani(fontWeight: FontWeight.w700, fontSize: 24, color: t.federation)),
              ),
              SizedBox(width: t.space3),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Flexible(
                          child: Text(fed.name,
                              style: GoogleFonts.rajdhani(
                                  fontWeight: FontWeight.w700, fontSize: 22, color: FwPalette.gray900, height: 1.1)),
                        ),
                        SizedBox(width: t.space2),
                        Text('[${fed.tag}]',
                            style: GoogleFonts.rajdhani(
                                fontWeight: FontWeight.w700, fontSize: 14, color: t.federation)),
                      ],
                    ),
                    if (fed.motto.isNotEmpty) ...[
                      SizedBox(height: t.space1),
                      Text(fed.motto,
                          style: TextStyle(fontSize: 12.5, fontStyle: FontStyle.italic, color: t.textSecondary)),
                    ],
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: t.space3),
          Wrap(
            spacing: t.space2,
            runSpacing: t.space1,
            children: [
              _MetaChip(
                  icon: Icons.group_outlined,
                  color: t.federation,
                  text: '${fed.memberCount}/${fed.maxMembers} membros'),
              for (final m in fed.members.where((m) => m.role != FederationRole.member))
                _MetaChip(
                    icon: _roleMeta(m.role, t).icon,
                    color: _roleMeta(m.role, t).color,
                    text: '${_roleMeta(m.role, t).label}: ${m.name}'),
            ],
          ),
        ],
      ),
    );
  }
}

class _TreasuryCard extends StatelessWidget {
  const _TreasuryCard({required this.fed, required this.money});
  final Federation fed;
  final NumberFormat money;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).extension<DsTokens>()!;
    return _SectionCard(
      icon: Icons.account_balance_outlined,
      title: 'TESOURO DA FEDERAÇÃO',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Icon(Icons.paid_outlined, size: 22, color: t.solar),
              SizedBox(width: t.space2),
              Text(money.format(fed.fundBalance),
                  style: GoogleFonts.rajdhani(fontWeight: FontWeight.w700, fontSize: 28, color: FwPalette.gray900, height: 1)),
              SizedBox(width: t.space2),
              Padding(
                padding: const EdgeInsets.only(bottom: 3),
                child: Text('Fert\$', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: t.textSecondary)),
              ),
            ],
          ),
          SizedBox(height: t.space1),
          Row(
            children: [
              Icon(Icons.location_on_outlined, size: 13, color: t.textSecondary),
              SizedBox(width: t.space1),
              Text('${fed.fundLocation} (§4)', style: TextStyle(fontSize: 11.5, color: t.textSecondary)),
            ],
          ),
          SizedBox(height: t.space3),
          _ContributionBar(fed: fed),
          SizedBox(height: t.space3),
          Row(
            children: [
              Expanded(
                child: _Stat(
                    label: 'Contribuição diária',
                    value: '${fed.contributionRate.toStringAsFixed(fed.contributionRate % 1 == 0 ? 0 : 1)}%',
                    hint: 'da produção · faixa ${fed.contributionMin.toStringAsFixed(0)}–${fed.contributionMax.toStringAsFixed(0)}%'),
              ),
              Container(width: 1, height: 34, color: t.borderDefault),
              Expanded(
                child: _Stat(
                    label: 'Seu aporte hoje',
                    value: '${money.format(fed.yourContributionToday)} Fert\$',
                    hint: 'creditado ao fundo'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Barra mostrando a taxa de contribuição (padrão 3%) dentro da faixa 1–10% (§4).
class _ContributionBar extends StatelessWidget {
  const _ContributionBar({required this.fed});
  final Federation fed;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).extension<DsTokens>()!;
    final span = (fed.contributionMax - fed.contributionMin).clamp(0.0001, 100);
    final frac = ((fed.contributionRate - fed.contributionMin) / span).clamp(0.0, 1.0);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LayoutBuilder(
          builder: (context, c) => Stack(
            children: [
              Container(
                height: 8,
                decoration: BoxDecoration(color: t.surfaceSunken, borderRadius: BorderRadius.circular(4)),
              ),
              Container(
                height: 8,
                width: c.maxWidth * frac,
                decoration: BoxDecoration(color: t.federation, borderRadius: BorderRadius.circular(4)),
              ),
            ],
          ),
        ),
        SizedBox(height: t.space1),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('${fed.contributionMin.toStringAsFixed(0)}% mín.', style: TextStyle(fontSize: 10, color: t.textSecondary)),
            Text('${fed.contributionMax.toStringAsFixed(0)}% máx.', style: TextStyle(fontSize: 10, color: t.textSecondary)),
          ],
        ),
      ],
    );
  }
}

class _RulesCard extends StatelessWidget {
  const _RulesCard({required this.fed});
  final Federation fed;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).extension<DsTokens>()!;
    return _SectionCard(
      icon: Icons.gavel_outlined,
      title: 'TRIBUTAÇÃO & MERCADO (§4)',
      child: Column(
        children: [
          _RuleRow(
            icon: Icons.swap_horiz_outlined,
            color: t.success,
            title: 'Tributação interna',
            value: 'Grátis até ${fed.internalFreeThreshold}%',
            detail: 'Movimentação entre membros é isenta até ${fed.internalFreeThreshold}% da produção diária; acima disso, ${fed.internalTributeRate}% de tributo.',
          ),
          Divider(height: t.space4 * 1.4, color: t.borderDefault),
          _RuleRow(
            icon: Icons.handshake_outlined,
            color: t.federation,
            title: 'Entre aliadas',
            value: '${fed.allyDiscount}% de desconto',
            detail: 'Trocas com federações aliadas têm ${fed.allyDiscount}% de desconto na tributação.',
          ),
          Divider(height: t.space4 * 1.4, color: t.borderDefault),
          _RuleRow(
            icon: Icons.shield_outlined,
            color: t.warning,
            title: 'Limite antimonopólio',
            value: 'Dinâmico ${fed.antiMonopolyMax}% → ${fed.antiMonopolyMin}%',
            detail: 'O teto de participação de mercado por federação cai de ${fed.antiMonopolyMax}% para ${fed.antiMonopolyMin}% conforme a concentração aumenta.',
          ),
        ],
      ),
    );
  }
}

class _RuleRow extends StatelessWidget {
  const _RuleRow({required this.icon, required this.color, required this.title, required this.value, required this.detail});
  final IconData icon;
  final Color color;
  final String title;
  final String value;
  final String detail;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).extension<DsTokens>()!;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 30,
          height: 30,
          alignment: Alignment.center,
          decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(t.radiusSm)),
          child: Icon(icon, size: 16, color: color),
        ),
        SizedBox(width: t.space3),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(title,
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: FwPalette.gray900)),
                  ),
                  SizedBox(width: t.space2),
                  Text(value, style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: color)),
                ],
              ),
              SizedBox(height: t.space1),
              Text(detail, style: TextStyle(fontSize: 11.5, height: 1.35, color: t.textSecondary)),
            ],
          ),
        ),
      ],
    );
  }
}

class _MembersCard extends StatelessWidget {
  const _MembersCard({required this.fed, required this.money});
  final Federation fed;
  final NumberFormat money;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).extension<DsTokens>()!;
    final online = fed.members.where((m) => m.online).length;
    // Cargos primeiro (Líder, Diplomata), depois membros por aporte desc.
    final sorted = [...fed.members]..sort((a, b) {
        final ra = a.role.index, rb = b.role.index;
        if (ra != rb) return ra.compareTo(rb);
        return b.dailyContribution.compareTo(a.dailyContribution);
      });
    return _SectionCard(
      icon: Icons.group_outlined,
      title: 'MEMBROS  ${fed.memberCount}/${fed.maxMembers}',
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(width: 7, height: 7, child: DecoratedBox(decoration: BoxDecoration(color: FwPalette.green500, shape: BoxShape.circle))),
          SizedBox(width: t.space1),
          Text('$online online', style: TextStyle(fontSize: 11, color: t.textSecondary)),
        ],
      ),
      child: Column(
        children: [
          for (var i = 0; i < sorted.length; i++) ...[
            if (i > 0) Divider(height: t.space3 * 1.6, color: t.borderDefault),
            _MemberRow(member: sorted[i], money: money),
          ],
        ],
      ),
    );
  }
}

class _MemberRow extends StatelessWidget {
  const _MemberRow({required this.member, required this.money});
  final FederationMember member;
  final NumberFormat money;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).extension<DsTokens>()!;
    final role = _roleMeta(member.role, t);
    final initial = member.name.isNotEmpty ? member.name[0].toUpperCase() : '?';
    return Row(
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: 34,
              height: 34,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: t.surfaceSunken,
                shape: BoxShape.circle,
                border: Border.all(color: member.isYou ? t.federation : t.borderDefault, width: member.isYou ? 1.5 : 1),
              ),
              child: Text(initial,
                  style: GoogleFonts.rajdhani(fontWeight: FontWeight.w700, fontSize: 15, color: FwPalette.gray700)),
            ),
            if (member.online)
              Positioned(
                right: -1,
                bottom: -1,
                child: Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: FwPalette.green500,
                    shape: BoxShape.circle,
                    border: Border.all(color: Theme.of(context).colorScheme.surface, width: 1.5),
                  ),
                ),
              ),
          ],
        ),
        SizedBox(width: t.space3),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Flexible(
                    child: Text(member.name,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: FwPalette.gray900)),
                  ),
                  if (member.isYou) ...[
                    SizedBox(width: t.space1),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                      decoration: BoxDecoration(color: t.federation.withValues(alpha: 0.14), borderRadius: BorderRadius.circular(4)),
                      child: Text('VOCÊ',
                          style: GoogleFonts.rajdhani(fontWeight: FontWeight.w700, fontSize: 9, letterSpacing: 0.5, color: t.federation)),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 1),
              Text('Setor ${member.sector} · Nível ${member.level}',
                  style: TextStyle(fontSize: 11, color: t.textSecondary)),
            ],
          ),
        ),
        SizedBox(width: t.space2),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(role.icon, size: 12, color: role.color),
                SizedBox(width: t.space1),
                Text(role.label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: role.color)),
              ],
            ),
            const SizedBox(height: 1),
            Text('+${money.format(member.dailyContribution)} Fert\$',
                style: TextStyle(fontSize: 10.5, color: t.textSecondary)),
          ],
        ),
      ],
    );
  }
}

class _AlliesCard extends StatelessWidget {
  const _AlliesCard({required this.fed});
  final Federation fed;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).extension<DsTokens>()!;
    return _SectionCard(
      icon: Icons.handshake_outlined,
      title: 'FEDERAÇÕES ALIADAS',
      child: Column(
        children: [
          for (var i = 0; i < fed.allies.length; i++) ...[
            if (i > 0) Divider(height: t.space3 * 1.6, color: t.borderDefault),
            Builder(builder: (context) {
              final a = fed.allies[i];
              return Row(
                children: [
                  Container(
                    width: 30,
                    height: 30,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: t.federation.withValues(alpha: 0.10),
                      border: Border.all(color: t.federation.withValues(alpha: 0.35)),
                    ),
                    child: Text(a.name.isNotEmpty ? a.name[0].toUpperCase() : '?',
                        style: GoogleFonts.rajdhani(fontWeight: FontWeight.w700, fontSize: 14, color: t.federation)),
                  ),
                  SizedBox(width: t.space3),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${a.name}  [${a.tag}]',
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: FwPalette.gray900)),
                        Text('${a.memberCount} membros', style: TextStyle(fontSize: 11, color: t.textSecondary)),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(color: t.success.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(6)),
                    child: Text('−${a.tradeDiscount}% troca',
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: t.success)),
                  ),
                ],
              );
            }),
          ],
        ],
      ),
    );
  }
}

class _CommunicationCard extends StatelessWidget {
  const _CommunicationCard();

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).extension<DsTokens>()!;
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: EdgeInsets.all(t.space4),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(t.radiusCard),
        border: Border.all(color: t.borderDefault),
      ),
      child: Row(
        children: [
          Icon(Icons.forum_outlined, size: 20, color: t.federation),
          SizedBox(width: t.space3),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Canal da federação',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: FwPalette.gray900)),
                Text('Privado entre membros · sem moderação automática (§10).',
                    style: TextStyle(fontSize: 11.5, color: t.textSecondary)),
              ],
            ),
          ),
          SizedBox(width: t.space2),
          FilledButton.icon(
            onPressed: () => context.go('/map/messages'),
            style: FilledButton.styleFrom(backgroundColor: t.federation),
            icon: const Icon(Icons.chat_bubble_outline, size: 16),
            label: const Text('Abrir chat'),
          ),
        ],
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  const _MetaChip({required this.icon, required this.color, required this.text});
  final IconData icon;
  final Color color;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(6)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 4),
          Text(text, style: GoogleFonts.rajdhani(fontWeight: FontWeight.w700, fontSize: 11.5, color: color)),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.label, required this.value, required this.hint});
  final String label;
  final String value;
  final String hint;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).extension<DsTokens>()!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label.toUpperCase(),
            style: GoogleFonts.rajdhani(fontWeight: FontWeight.w700, fontSize: 10, letterSpacing: 0.5, color: t.textSecondary)),
        SizedBox(height: t.space1),
        Text(value, style: GoogleFonts.rajdhani(fontWeight: FontWeight.w700, fontSize: 17, color: FwPalette.gray900)),
        Text(hint, style: TextStyle(fontSize: 10.5, color: t.textSecondary)),
      ],
    );
  }
}
