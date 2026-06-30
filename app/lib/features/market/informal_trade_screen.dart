import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../app/theme/ds_colors.dart';
import '../../app/theme/ds_tokens.dart';
import '../../data/providers.dart';
import '../../domain/models/informal_trade.dart';
import 'resource_visual.dart';

/// Filtro da lista de ofertas.
enum _OfferFilter { all, trusted, federation }

/// Comércio Informal entre colonos (GDD §8): trocas diretas sem garantias do
/// sistema — o calote é mecânica real e o único sinal é a reputação (0–5★) e o
/// histórico do comerciante. Tributo cobrado na saída (§8.3). Drill-in do
/// Mercado, mantém HUD/nav.
class InformalTradeScreen extends ConsumerStatefulWidget {
  const InformalTradeScreen({super.key});

  @override
  ConsumerState<InformalTradeScreen> createState() => _InformalTradeScreenState();
}

class _InformalTradeScreenState extends ConsumerState<InformalTradeScreen> {
  int _tab = 0; // 0 = Ofertas, 1 = Histórico, 2 = Como funciona
  _OfferFilter _filter = _OfferFilter.all;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).extension<DsTokens>()!;
    final board = ref.watch(informalBoardProvider);

    return ColoredBox(
      color: t.surfacePage,
      child: board.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => Center(
          child: TextButton.icon(
            onPressed: () => ref.invalidate(informalBoardProvider),
            icon: const Icon(Icons.refresh),
            label: const Text('Não foi possível carregar. Tocar para tentar de novo.'),
          ),
        ),
        data: (b) => Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _Header(),
            _AntifraudBanner(),
            Padding(
              padding: EdgeInsets.fromLTRB(t.space4, t.space1, t.space4, t.space2),
              child: Row(
                children: [
                  for (final (i, label) in const [(0, 'Ofertas'), (1, 'Histórico'), (2, 'Como funciona')])
                    Padding(
                      padding: EdgeInsets.only(right: t.space2),
                      child: ChoiceChip(
                        label: Text(label),
                        selected: _tab == i,
                        onSelected: (_) => setState(() => _tab = i),
                      ),
                    ),
                ],
              ),
            ),
            Expanded(child: _tabBody(context, b)),
          ],
        ),
      ),
    );
  }

  Widget _tabBody(BuildContext context, InformalBoard b) {
    final t = Theme.of(context).extension<DsTokens>()!;
    switch (_tab) {
      case 1:
        return ListView(
          padding: EdgeInsets.fromLTRB(t.space4, t.space2, t.space4, t.space6),
          children: [for (final h in b.history) _HistoryCard(entry: h)],
        );
      case 2:
        return _HowItWorks(board: b);
      default:
        final offers = b.offers.where((o) {
          return switch (_filter) {
            _OfferFilter.all => true,
            _OfferFilter.trusted => !o.risky,
            _OfferFilter.federation => o.sameFederation,
          };
        }).toList();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(t.space4, 0, t.space4, t.space2),
              child: Wrap(
                spacing: t.space2,
                children: [
                  ChoiceChip(
                      label: const Text('Tudo'),
                      selected: _filter == _OfferFilter.all,
                      onSelected: (_) => setState(() => _filter = _OfferFilter.all)),
                  ChoiceChip(
                      avatar: Icon(Icons.verified_outlined, size: 15, color: t.success),
                      label: const Text('Confiáveis'),
                      selected: _filter == _OfferFilter.trusted,
                      onSelected: (_) => setState(() => _filter = _OfferFilter.trusted)),
                  ChoiceChip(
                      avatar: Icon(Icons.groups_outlined, size: 15, color: t.federation),
                      label: const Text('Federação'),
                      selected: _filter == _OfferFilter.federation,
                      onSelected: (_) => setState(() => _filter = _OfferFilter.federation)),
                ],
              ),
            ),
            Expanded(
              child: offers.isEmpty
                  ? Center(child: Text('Nenhuma oferta com esse filtro.', style: TextStyle(color: t.textSecondary)))
                  : ListView(
                      padding: EdgeInsets.fromLTRB(t.space4, 0, t.space4, t.space6),
                      children: [for (final o in offers) _OfferCard(offer: o, board: b)],
                    ),
            ),
          ],
        );
    }
  }
}

class _Header extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).extension<DsTokens>()!;
    return Padding(
      padding: EdgeInsets.fromLTRB(t.space4, t.space4, t.space4, t.space2),
      child: Row(
        children: [
          InkWell(
            onTap: () => context.go('/market'),
            borderRadius: BorderRadius.circular(t.radiusSm),
            child: Padding(
              padding: const EdgeInsets.all(6),
              child: Icon(Icons.arrow_back, size: 20, color: t.textSecondary),
            ),
          ),
          SizedBox(width: t.space2),
          const Icon(Icons.handshake_outlined, size: 22, color: FwPalette.rust600),
          SizedBox(width: t.space2),
          Text('Comércio Informal',
              style: GoogleFonts.rajdhani(fontWeight: FontWeight.w700, fontSize: 22, color: FwPalette.gray900)),
        ],
      ),
    );
  }
}

class _AntifraudBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).extension<DsTokens>()!;
    return Container(
      margin: EdgeInsets.fromLTRB(t.space4, t.space1, t.space4, t.space2),
      padding: EdgeInsets.all(t.space3),
      decoration: BoxDecoration(
        color: FwPalette.solar500.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(t.radiusMd),
        border: Border.all(color: FwPalette.solar500.withValues(alpha: 0.35)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.gpp_maybe_outlined, size: 20, color: FwPalette.solar600),
          SizedBox(width: t.space2),
          const Expanded(
            child: Text(
              'Sem escrow nem árbitro automático: cada colono despacha seu próprio veículo (§25). '
              'O calote é real e visível — quem entrega e não recebe perde recurso, tempo e energia. '
              'A Confiança Comercial e o Acordo de Troca são sua proteção (§25/§26).',
              style: TextStyle(fontSize: 12, height: 1.3, color: FwPalette.gray800),
            ),
          ),
        ],
      ),
    );
  }
}

/// Estrelas 0–5 (cheia/meia/vazia), vermelhas quando arriscado.
class _Stars extends StatelessWidget {
  const _Stars({required this.rating, required this.risky});
  final double rating;
  final bool risky;

  @override
  Widget build(BuildContext context) {
    final color = risky ? FwPalette.red500 : FwPalette.solar500;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < 5; i++)
          Icon(
            rating >= i + 1
                ? Icons.star
                : rating >= i + 0.5
                    ? Icons.star_half
                    : Icons.star_border,
            size: 14,
            color: color,
          ),
      ],
    );
  }
}

/// Barra do índice de Confiança Comercial (0–1000, GDD §26.2).
class _TrustIndex extends StatelessWidget {
  const _TrustIndex({required this.value});
  final int value;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).extension<DsTokens>()!;
    final c = value >= 750 ? t.success : (value >= 500 ? t.warning : t.deltaDown);
    return Row(
      children: [
        Icon(Icons.verified_user_outlined, size: 13, color: c),
        SizedBox(width: t.space1),
        Text('Confiança Comercial', style: TextStyle(fontSize: 10.5, color: t.textSecondary)),
        SizedBox(width: t.space2),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(t.radiusSm),
            child: LinearProgressIndicator(
              value: value / 1000,
              minHeight: 6,
              backgroundColor: t.surfaceSunken,
              valueColor: AlwaysStoppedAnimation(c),
            ),
          ),
        ),
        SizedBox(width: t.space2),
        Text('$value',
            style: GoogleFonts.rajdhani(fontWeight: FontWeight.w700, fontSize: 12.5, color: c)),
        Text('/1000', style: TextStyle(fontSize: 9.5, color: t.textSecondary)),
      ],
    );
  }
}

/// Linha "ícone + conteúdo" reutilizável (logística, tributo).
class _InfoLine extends StatelessWidget {
  const _InfoLine({required this.icon, required this.child});
  final IconData icon;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).extension<DsTokens>()!;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 14, color: t.textSecondary),
        SizedBox(width: t.space1),
        Expanded(child: child),
      ],
    );
  }
}

class _OfferCard extends StatelessWidget {
  const _OfferCard({required this.offer, required this.board});
  final InformalOffer offer;
  final InformalBoard board;

  String _trimNum(double v) => v == v.roundToDouble() ? v.toStringAsFixed(0) : v.toStringAsFixed(1);

  void _mock(BuildContext context, String msg) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg), behavior: SnackBarBehavior.floating, duration: const Duration(seconds: 2)),
      );

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).extension<DsTokens>()!;
    final scheme = Theme.of(context).colorScheme;
    final risky = offer.risky;
    final accent = risky ? FwPalette.red500 : t.borderDefault;
    final rate = board.rateFor(offer.want.tier);
    final taxUnits = offer.want.qty * rate / 100;

    return Container(
      margin: EdgeInsets.only(bottom: t.space3),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(t.radiusCard),
        border: Border.all(color: accent, width: risky ? 1.5 : 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: EdgeInsets.all(t.space3),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Identidade + reputação
                Row(
                  children: [
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: t.surfaceSunken,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.person_outline, size: 20, color: t.textSecondary),
                    ),
                    SizedBox(width: t.space2),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('${offer.trader} · ${offer.sector}',
                              style: const TextStyle(
                                  fontSize: 13.5, fontWeight: FontWeight.w700, color: FwPalette.gray900)),
                          SizedBox(height: t.space1),
                          Row(
                            children: [
                              _Stars(rating: offer.rating, risky: risky),
                              SizedBox(width: t.space1),
                              Text('${offer.rating.toStringAsFixed(1)} (${offer.ratingsCount})',
                                  style: TextStyle(fontSize: 11, color: t.textSecondary)),
                            ],
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: t.space2),
                    if (risky)
                      const _Tag(label: 'Risco de calote', color: FwPalette.red600, icon: Icons.warning_amber_outlined)
                    else if (offer.commercialTrust >= 850)
                      _Tag(label: 'Verificado', color: t.success, icon: Icons.verified_outlined),
                  ],
                ),
                SizedBox(height: t.space2),
                _TrustIndex(value: offer.commercialTrust),
                if (offer.sameFederation) ...[
                  SizedBox(height: t.space2),
                  Row(
                    children: [
                      Icon(Icons.groups_outlined, size: 14, color: t.federation),
                      SizedBox(width: t.space1),
                      Text('Mesma federação${offer.federation != null ? ' · ${offer.federation}' : ''}',
                          style: TextStyle(fontSize: 11.5, color: t.federation, fontWeight: FontWeight.w600)),
                    ],
                  ),
                ],
                SizedBox(height: t.space3),
                // Swap
                Row(
                  children: [
                    Expanded(child: _LegBox(label: 'Você recebe', leg: offer.give, positive: true)),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: t.space2),
                      child: Icon(Icons.swap_horiz, size: 22, color: t.textSecondary),
                    ),
                    Expanded(child: _LegBox(label: 'Você envia', leg: offer.want, positive: false)),
                  ],
                ),
                SizedBox(height: t.space2),
                // Logística (§25): despachar veículo físico
                _InfoLine(
                  icon: Icons.local_shipping_outlined,
                  child: Text.rich(
                    TextSpan(children: [
                      TextSpan(
                          text: '${offer.sendLogistics.vehicle.name} · ${offer.distanceSlots} slots · ',
                          style: TextStyle(fontSize: 11, color: t.textSecondary)),
                      TextSpan(
                          text: '~${_trimNum(offer.sendLogistics.minutes)} min · ~${_trimNum(offer.sendLogistics.energyKwh)} kWh',
                          style: const TextStyle(fontSize: 11, color: FwPalette.gray800, fontWeight: FontWeight.w600)),
                      TextSpan(text: '  (§25)', style: TextStyle(fontSize: 10, color: t.textSecondary)),
                    ]),
                  ),
                ),
                SizedBox(height: t.space1),
                // Tributo de transporte na entrega (§25)
                _InfoLine(
                  icon: Icons.receipt_long_outlined,
                  child: offer.sameFederation
                      ? Text('Tributo de transporte: isento (federação, até 35%/dia)',
                          style: TextStyle(fontSize: 11, color: t.success))
                      : Text(
                          'Tributo de transporte na entrega: ${_trimNum(taxUnits)} ${offer.want.label} ($rate% ${tierLabel(offer.want.tier).toLowerCase()}, §25)',
                          style: TextStyle(fontSize: 11, color: t.textSecondary)),
                ),
                if (offer.note.isNotEmpty) ...[
                  SizedBox(height: t.space2),
                  Text('"${offer.note}"',
                      style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic, color: t.textSecondary)),
                ],
              ],
            ),
          ),
          // Confiança/histórico + ações
          Container(
            padding: EdgeInsets.symmetric(horizontal: t.space3, vertical: t.space2),
            decoration: BoxDecoration(
              color: t.surfaceSunken,
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(t.radiusCard)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Wrap(
                    spacing: t.space3,
                    runSpacing: t.space1,
                    children: [
                      _TrustBit(icon: Icons.swap_horizontal_circle_outlined, text: '${offer.deals} negociações'),
                      _TrustBit(
                          icon: Icons.thumb_up_outlined,
                          text: '${offer.successRate}% sucesso',
                          color: offer.successRate >= 90 ? t.success : (offer.successRate >= 70 ? t.warning : t.deltaDown)),
                      _TrustBit(
                          icon: Icons.gavel_outlined,
                          text: '${offer.scams} calote${offer.scams == 1 ? '' : 's'}',
                          color: offer.scams == 0 ? t.textSecondary : t.deltaDown),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(t.space2, t.space2, t.space2, t.space3),
            child: Row(
              children: [
                TextButton.icon(
                  onPressed: () => _mock(context, 'Reputação de ${offer.trader} — em breve'),
                  icon: const Icon(Icons.shield_outlined, size: 16),
                  label: const Text('Reputação'),
                  style: TextButton.styleFrom(visualDensity: VisualDensity.compact),
                ),
                const Spacer(),
                OutlinedButton.icon(
                  onPressed: () => _mock(context, 'Acordo de Troca proposto a ${offer.trader} — aguarda o aperto de mão digital (§26.5)'),
                  icon: const Icon(Icons.handshake_outlined, size: 16),
                  label: const Text('Acordo'),
                  style: OutlinedButton.styleFrom(
                      visualDensity: VisualDensity.compact,
                      foregroundColor: FwPalette.rust700,
                      side: const BorderSide(color: FwPalette.rust300)),
                ),
                SizedBox(width: t.space2),
                FilledButton.icon(
                  onPressed: () => _mock(context, 'Proposta enviada a ${offer.trader} — despache seu veículo quando quiser (§25.7)'),
                  icon: const Icon(Icons.send_outlined, size: 16),
                  label: const Text('Negociar'),
                  style: FilledButton.styleFrom(
                      backgroundColor: risky ? FwPalette.gray600 : FwPalette.rust600,
                      visualDensity: VisualDensity.compact,
                      minimumSize: Size(0, t.controlMd)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LegBox extends StatelessWidget {
  const _LegBox({required this.label, required this.leg, required this.positive});
  final String label;
  final TradeLeg leg;
  final bool positive;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).extension<DsTokens>()!;
    final color = resourceColor(leg.resourceId);
    return Container(
      padding: EdgeInsets.all(t.space2),
      decoration: BoxDecoration(
        color: t.surfaceSunken,
        borderRadius: BorderRadius.circular(t.radiusMd),
        border: Border(left: BorderSide(color: positive ? t.success : t.warning, width: 3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontSize: 10.5, color: t.textSecondary)),
          SizedBox(height: t.space1),
          Row(
            children: [
              Icon(resourceIcon(leg.resourceId), size: 16, color: color),
              SizedBox(width: t.space1),
              Expanded(
                child: Text('${leg.qty} ${leg.label}',
                    style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: FwPalette.gray900),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TrustBit extends StatelessWidget {
  const _TrustBit({required this.icon, required this.text, this.color});
  final IconData icon;
  final String text;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).extension<DsTokens>()!;
    final c = color ?? t.textSecondary;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: c),
        SizedBox(width: t.space1),
        Text(text, style: TextStyle(fontSize: 11.5, color: c, fontWeight: FontWeight.w600)),
      ],
    );
  }
}

class _Tag extends StatelessWidget {
  const _Tag({required this.label, required this.color, required this.icon});
  final String label;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).extension<DsTokens>()!;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(t.radiusMd),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          SizedBox(width: t.space1),
          Text(label, style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: color)),
        ],
      ),
    );
  }
}

class _HistoryCard extends StatelessWidget {
  const _HistoryCard({required this.entry});
  final TradeHistoryEntry entry;

  void _mock(BuildContext context, String msg) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg), behavior: SnackBarBehavior.floating, duration: const Duration(seconds: 2)),
      );

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).extension<DsTokens>()!;
    final scheme = Theme.of(context).colorScheme;
    final scam = entry.outcome == TradeOutcome.scam;
    final color = scam ? t.deltaDown : t.success;

    return Container(
      margin: EdgeInsets.only(bottom: t.space2),
      padding: EdgeInsets.all(t.space3),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(t.radiusCard),
        border: Border(
          left: BorderSide(color: color, width: 3),
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
              Icon(scam ? Icons.cancel_outlined : Icons.check_circle_outline, size: 18, color: color),
              SizedBox(width: t.space2),
              Expanded(
                child: Text(entry.counterparty,
                    style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700, color: FwPalette.gray900)),
              ),
              Text(scam ? 'Calote' : 'Sucesso',
                  style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: color)),
            ],
          ),
          SizedBox(height: t.space2),
          Text(entry.summary, style: const TextStyle(fontSize: 12.5, height: 1.3, color: FwPalette.gray800)),
          if (entry.agreementExpired) ...[
            SizedBox(height: t.space2),
            _InfoLine(
              icon: Icons.gpp_bad_outlined,
              child: Text('Acordo de Troca expirado — denúncia pré-preenchida (§26.5)',
                  style: TextStyle(fontSize: 11, color: t.deltaDown, fontWeight: FontWeight.w600)),
            ),
          ],
          SizedBox(height: t.space2),
          Row(
            children: [
              _Stars(rating: entry.rating.toDouble(), risky: scam),
              SizedBox(width: t.space2),
              Text('Sua avaliação · ${entry.day}', style: TextStyle(fontSize: 11, color: t.textSecondary)),
              const Spacer(),
              if (scam)
                entry.reported
                    ? _Tag(label: 'Denunciado', color: t.deltaDown, icon: Icons.report_outlined)
                    : TextButton.icon(
                        onPressed: () => _mock(context, 'Denúncia ao Ministério das Reputações — Bloco B5'),
                        icon: const Icon(Icons.report_outlined, size: 16),
                        label: const Text('Denunciar'),
                        style: TextButton.styleFrom(foregroundColor: t.deltaDown),
                      ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HowItWorks extends StatelessWidget {
  const _HowItWorks({required this.board});
  final InformalBoard board;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).extension<DsTokens>()!;
    final success = _FlowCard(
      title: 'Negociação bem-sucedida',
      color: t.success,
      icon: Icons.check_circle_outline,
      steps: const [
        'Combinam via chat; cada um despacha o próprio veículo quando quiser (§25.7)',
        'Seu Furgão entrega 50 Água → tributo de transporte 3% na entrega',
        'O Furgão dele entrega 120 Ligas → tributo de transporte 2%',
        'Ambos avaliam (troca ≥ 500 Fert\$): 5★ → Confiança Comercial sobe',
      ],
    );
    final scam = _FlowCard(
      title: 'Calote',
      color: t.deltaDown,
      icon: Icons.cancel_outlined,
      steps: const [
        'Combinam via chat; você pode propor um Acordo de Troca antes',
        'Seu Furgão entrega 50 Água → tributo de transporte cobrado',
        'O veículo dele nunca é despachado — calote real e visível (perde recurso, tempo, energia)',
        'Acordo expirado vira denúncia pré-preenchida no Ministério das Reputações (§26.5)',
      ],
    );

    return ListView(
      padding: EdgeInsets.fromLTRB(t.space4, t.space2, t.space4, t.space6),
      children: [
        LayoutBuilder(builder: (context, c) {
          if (c.maxWidth >= 620) {
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: success),
                SizedBox(width: t.space3),
                Expanded(child: scam),
              ],
            );
          }
          return Column(children: [success, SizedBox(height: t.space3), scam]);
        }),
        SizedBox(height: t.space3),
        const _AgreementCard(),
        _TaxCard(board: board),
      ],
    );
  }
}

/// Explica o Acordo de Troca — "aperto de mão digital" (GDD §26.5).
class _AgreementCard extends StatelessWidget {
  const _AgreementCard();

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).extension<DsTokens>()!;
    final scheme = Theme.of(context).colorScheme;
    return Container(
      margin: EdgeInsets.only(bottom: t.space3),
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
              const Icon(Icons.handshake_outlined, size: 18, color: FwPalette.rust600),
              SizedBox(width: t.space2),
              Text('Acordo de Troca — aperto de mão digital (§26.5)',
                  style: GoogleFonts.rajdhani(
                      fontWeight: FontWeight.w700, fontSize: 14.5, color: FwPalette.gray900)),
            ],
          ),
          SizedBox(height: t.space2),
          Text(
            'Sem escrow: o risco do calote continua real, mas agora há prova. Os dois lados registram '
            'o que prometem e o prazo; o acordo só vale como evidência após ambos confirmarem. Se o '
            'prazo expira sem cumprimento, vira denúncia pré-preenchida no Ministério das Reputações — '
            'o prejudicado só confirma o envio.',
            style: TextStyle(fontSize: 12.5, height: 1.35, color: t.textSecondary),
          ),
        ],
      ),
    );
  }
}

class _FlowCard extends StatelessWidget {
  const _FlowCard({required this.title, required this.color, required this.icon, required this.steps});
  final String title;
  final Color color;
  final IconData icon;
  final List<String> steps;

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
              Icon(icon, size: 20, color: color),
              SizedBox(width: t.space2),
              Text(title,
                  style: GoogleFonts.rajdhani(fontWeight: FontWeight.w700, fontSize: 16, color: color)),
            ],
          ),
          SizedBox(height: t.space3),
          for (var i = 0; i < steps.length; i++)
            Padding(
              padding: EdgeInsets.only(bottom: t.space2),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 20,
                    height: 20,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(color: color.withValues(alpha: 0.14), shape: BoxShape.circle),
                    child: Text('${i + 1}',
                        style: GoogleFonts.rajdhani(fontWeight: FontWeight.w700, fontSize: 11, color: color)),
                  ),
                  SizedBox(width: t.space2),
                  Expanded(
                    child: Text(steps[i],
                        style: const TextStyle(fontSize: 12.5, height: 1.3, color: FwPalette.gray800)),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _TaxCard extends StatelessWidget {
  const _TaxCard({required this.board});
  final InformalBoard board;

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
          Text('TRIBUTO DE TRANSPORTE (§25)',
              style: GoogleFonts.rajdhani(
                  fontWeight: FontWeight.w700, fontSize: 12, letterSpacing: 1.1, color: FwPalette.gray500)),
          SizedBox(height: t.space1),
          Text('Cobrado uma única vez, na entrega física pelo veículo. Não se sobrepõe ao Fert\$ '
              'movimentado no Mercado — o volume já foi tributado na entrada.',
              style: TextStyle(fontSize: 12, color: t.textSecondary)),
          SizedBox(height: t.space3),
          Wrap(
            spacing: t.space2,
            runSpacing: t.space2,
            children: [
              _RatePill(label: 'Primários', rate: board.primaryRate, color: t.success),
              _RatePill(label: 'Secundários', rate: board.secondaryRate, color: t.info),
              _RatePill(label: 'Raros', rate: board.rareRate, color: t.federation),
            ],
          ),
          SizedBox(height: t.space3),
          Row(
            children: [
              Icon(Icons.groups_outlined, size: 16, color: t.federation),
              SizedBox(width: t.space2),
              Expanded(
                child: Text(board.federationExemption, style: TextStyle(fontSize: 12, color: t.textSecondary)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RatePill extends StatelessWidget {
  const _RatePill({required this.label, required this.rate, required this.color});
  final String label;
  final int rate;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).extension<DsTokens>()!;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: t.space3, vertical: t.space2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(t.radiusMd),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('$rate%',
              style: GoogleFonts.rajdhani(fontWeight: FontWeight.w700, fontSize: 15, color: color)),
          SizedBox(width: t.space2),
          Text(label, style: const TextStyle(fontSize: 12, color: FwPalette.gray800)),
        ],
      ),
    );
  }
}
