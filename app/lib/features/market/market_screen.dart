import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../app/theme/ds_colors.dart';
import '../../app/theme/ds_tokens.dart';
import '../../data/providers.dart';
import '../../domain/models/market.dart';
import 'resource_visual.dart';

/// Formata preço em Fert$ (frações do §22).
String _price(double v) => v >= 1 ? v.toStringAsFixed(2) : v.toStringAsFixed(4);

/// Mercado Central (GDD §13): ordens de compra/venda dos 5 recursos com sinais
/// de confiança do vendedor (avaliação 0–5, §8). Filtros por recurso e lado.
class MarketScreen extends ConsumerStatefulWidget {
  const MarketScreen({super.key});

  @override
  ConsumerState<MarketScreen> createState() => _MarketScreenState();
}

class _MarketScreenState extends ConsumerState<MarketScreen> {
  String? _resFilter; // null = todos
  MarketSide? _sideFilter; // null = ambos

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).extension<DsTokens>()!;
    final board = ref.watch(marketBoardProvider);

    return board.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, __) => Center(
        child: TextButton.icon(
          onPressed: () => ref.invalidate(marketBoardProvider),
          icon: const Icon(Icons.refresh),
          label: const Text('Não foi possível carregar o Mercado. Tocar para tentar de novo.'),
        ),
      ),
      data: (b) {
        final orders = b.orders
            .where((o) => _resFilter == null || o.resourceId == _resFilter)
            .where((o) => _sideFilter == null || o.side == _sideFilter)
            .toList();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(t.space4, t.space4, t.space4, t.space2),
              child: Row(
                children: [
                  const Icon(Icons.storefront_outlined, size: 22, color: FwPalette.rust600),
                  SizedBox(width: t.space2),
                  Text('Mercado Central',
                      style: GoogleFonts.rajdhani(fontWeight: FontWeight.w700, fontSize: 22, color: FwPalette.gray900)),
                  const Spacer(),
                  Text('${orders.length} ordens', style: TextStyle(fontSize: 12, color: t.textSecondary)),
                  SizedBox(width: t.space3),
                  OutlinedButton.icon(
                    onPressed: () => context.go('/market/informal'),
                    icon: const Icon(Icons.handshake_outlined, size: 17),
                    label: const Text('Comércio informal'),
                    style: OutlinedButton.styleFrom(
                      visualDensity: VisualDensity.compact,
                      side: const BorderSide(color: FwPalette.rust300),
                      foregroundColor: FwPalette.rust700,
                    ),
                  ),
                ],
              ),
            ),
            _Tickers(tickers: b.tickers),
            Padding(
              padding: EdgeInsets.fromLTRB(t.space4, t.space2, t.space4, 0),
              child: Row(
                children: [
                  Icon(Icons.functions_outlined, size: 13, color: t.textSecondary),
                  SizedBox(width: t.space1),
                  Expanded(
                    child: Text(
                      'Preço dos processados = custo de insumos × (1 + markup 30–40%); brutos seguem a escassez por produção/h (§24.8).',
                      style: TextStyle(fontSize: 11, color: t.textSecondary),
                      maxLines: 2,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(t.space4, t.space2, t.space4, t.space2),
              child: _Filters(
                tickers: b.tickers,
                resFilter: _resFilter,
                sideFilter: _sideFilter,
                onRes: (r) => setState(() => _resFilter = r),
                onSide: (s) => setState(() => _sideFilter = s),
              ),
            ),
            Expanded(
              child: orders.isEmpty
                  ? Center(child: Text('Nenhuma ordem com esse filtro.', style: TextStyle(color: t.textSecondary)))
                  : ListView.separated(
                      padding: EdgeInsets.fromLTRB(t.space4, t.space2, t.space4, t.space4),
                      itemCount: orders.length,
                      itemBuilder: (_, i) => _OrderCard(order: orders[i]),
                      separatorBuilder: (_, __) => SizedBox(height: t.space2),
                    ),
            ),
          ],
        );
      },
    );
  }
}

class _Tickers extends StatelessWidget {
  const _Tickers({required this.tickers});
  final List<MarketTicker> tickers;
  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).extension<DsTokens>()!;
    return SizedBox(
      height: 58,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: t.space4),
        itemCount: tickers.length,
        separatorBuilder: (_, __) => SizedBox(width: t.space2),
        itemBuilder: (_, i) {
          final tk = tickers[i];
          final up = tk.changePct >= 0;
          return Container(
            padding: EdgeInsets.symmetric(horizontal: t.space3, vertical: t.space2),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(t.radiusMd),
              border: Border.all(color: t.borderDefault),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(resourceIcon(tk.resourceId), size: 16, color: resourceColor(tk.resourceId)),
                SizedBox(width: t.space2),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(tk.resourceLabel, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
                    Row(
                      children: [
                        Text('${_price(tk.lastPrice)} Fert\$',
                            style: GoogleFonts.rajdhani(
                                fontWeight: FontWeight.w700, fontSize: 13, color: FwPalette.gray900)),
                        SizedBox(width: t.space1),
                        Icon(up ? Icons.arrow_drop_up : Icons.arrow_drop_down,
                            size: 16, color: up ? t.deltaUp : t.deltaDown),
                        Text('${tk.changePct.abs().toStringAsFixed(1)}%',
                            style: TextStyle(fontSize: 11, color: up ? t.deltaUp : t.deltaDown)),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _Filters extends StatelessWidget {
  const _Filters({
    required this.tickers,
    required this.resFilter,
    required this.sideFilter,
    required this.onRes,
    required this.onSide,
  });
  final List<MarketTicker> tickers;
  final String? resFilter;
  final MarketSide? sideFilter;
  final ValueChanged<String?> onRes;
  final ValueChanged<MarketSide?> onSide;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).extension<DsTokens>()!;
    return Wrap(
      spacing: t.space2,
      runSpacing: t.space2,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        ChoiceChip(label: const Text('Tudo'), selected: resFilter == null, onSelected: (_) => onRes(null)),
        for (final tk in tickers)
          ChoiceChip(
            avatar: Icon(resourceIcon(tk.resourceId), size: 15, color: resourceColor(tk.resourceId)),
            label: Text(tk.resourceLabel),
            selected: resFilter == tk.resourceId,
            onSelected: (_) => onRes(tk.resourceId),
          ),
        Container(width: 1, height: 22, color: t.borderDefault, margin: EdgeInsets.symmetric(horizontal: t.space1)),
        ChoiceChip(label: const Text('Comprar'), selected: sideFilter == MarketSide.buy, onSelected: (_) => onSide(sideFilter == MarketSide.buy ? null : MarketSide.buy)),
        ChoiceChip(label: const Text('Vender'), selected: sideFilter == MarketSide.sell, onSelected: (_) => onSide(sideFilter == MarketSide.sell ? null : MarketSide.sell)),
      ],
    );
  }
}

class _OrderCard extends StatelessWidget {
  const _OrderCard({required this.order});
  final MarketOrder order;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).extension<DsTokens>()!;
    final scheme = Theme.of(context).colorScheme;
    final color = resourceColor(order.resourceId);
    final isBuy = order.side == MarketSide.buy;

    return Container(
      padding: EdgeInsets.all(t.space3),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(t.radiusCard),
        border: Border.all(color: t.borderDefault),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(color: color.withValues(alpha: 0.14), borderRadius: BorderRadius.circular(t.radiusMd)),
            child: Icon(resourceIcon(order.resourceId), color: color, size: 24),
          ),
          SizedBox(width: t.space3),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(order.resourceLabel,
                        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14.5)),
                    SizedBox(width: t.space2),
                    _SideBadge(isBuy: isBuy),
                  ],
                ),
                const SizedBox(height: 3),
                Row(
                  children: [
                    Icon(Icons.person_outline, size: 13, color: t.textSecondary),
                    const SizedBox(width: 3),
                    Flexible(
                      child: Text('${order.trader} · ${order.traderSector}',
                          style: TextStyle(fontSize: 11.5, color: t.textSecondary),
                          overflow: TextOverflow.ellipsis),
                    ),
                    SizedBox(width: t.space2),
                    Icon(Icons.star, size: 13, color: order.risky ? FwPalette.red500 : FwPalette.solar500),
                    const SizedBox(width: 2),
                    Text(order.traderRating.toStringAsFixed(1),
                        style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: order.risky ? FwPalette.red600 : FwPalette.gray700)),
                    if (order.risky) ...[
                      SizedBox(width: t.space2),
                      _RiskChip(),
                    ],
                  ],
                ),
              ],
            ),
          ),
          SizedBox(width: t.space2),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('${order.quantity} un',
                  style: const TextStyle(fontSize: 11.5, color: FwPalette.gray700)),
              Text('${_price(order.unitPrice)} Fert\$/un',
                  style: GoogleFonts.rajdhani(fontWeight: FontWeight.w700, fontSize: 15, color: FwPalette.gray900)),
              Text('Total ${_price(order.total)} Fert\$', style: TextStyle(fontSize: 10.5, color: t.textSecondary)),
            ],
          ),
          SizedBox(width: t.space3),
          FilledButton(
            onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('${isBuy ? 'Vender para' : 'Comprar de'} ${order.trader}: ${order.quantity} ${order.resourceLabel} por ${_price(order.total)} Fert\$ — em breve'),
                behavior: SnackBarBehavior.floating,
                duration: const Duration(seconds: 3),
              ),
            ),
            style: FilledButton.styleFrom(
              backgroundColor: isBuy ? FwPalette.teal600 : FwPalette.rust600,
              minimumSize: Size(0, t.controlLg),
            ),
            child: Text(isBuy ? 'Vender' : 'Comprar'),
          ),
        ],
      ),
    );
  }
}

class _SideBadge extends StatelessWidget {
  const _SideBadge({required this.isBuy});
  final bool isBuy;
  @override
  Widget build(BuildContext context) {
    final c = isBuy ? FwPalette.teal600 : FwPalette.rust600;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(color: c.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(6)),
      child: Text(isBuy ? 'Compra' : 'Venda',
          style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: c)),
    );
  }
}

class _RiskChip extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(color: FwPalette.red500.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(6)),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.warning_amber_outlined, size: 11, color: FwPalette.red600),
            SizedBox(width: 3),
            Text('Risco', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: FwPalette.red600)),
          ],
        ),
      );
}
