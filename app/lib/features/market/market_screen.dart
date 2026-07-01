import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../app/theme/ds_colors.dart';
import '../../app/theme/ds_tokens.dart';
import '../../data/providers.dart';
import '../../domain/models/market.dart';
import 'resource_visual.dart';

/// Extrai a mensagem de erro amigável de uma resposta do backend (Nest).
String _dioMessage(DioException e) {
  final data = e.response?.data;
  if (data is Map && data['message'] != null) {
    final m = data['message'];
    return m is List ? m.join(' · ') : '$m';
  }
  return 'falha de conexão';
}

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

  /// Compra de um anúncio aberto (§13): escolhe a quantidade e fecha no backend
  /// (transfere recurso + Fert$ com taxa). Atualiza board e HUD de recursos.
  Future<void> _buy(MarketOrder order) async {
    final messenger = ScaffoldMessenger.of(context);
    final qty = await _askQuantity(order);
    if (qty == null) return;
    try {
      final res = await ref.read(marketRepositoryProvider).buyOrder(order.id, qty);
      ref.invalidate(marketBoardProvider);
      ref.invalidate(resourcesProvider);
      if (!mounted) return;
      messenger.showSnackBar(SnackBar(
        content: Text('Compra concluída: $qty ${order.resourceLabel} · '
            '${_price(res.total)} Fert\$ (taxa ${_price(res.tax)}).'),
        behavior: SnackBarBehavior.floating,
      ));
    } on DioException catch (e) {
      if (!mounted) return;
      messenger.showSnackBar(SnackBar(
        content: Text('Não foi possível comprar: ${_dioMessage(e)}'),
        behavior: SnackBarBehavior.floating,
      ));
    }
  }

  Future<int?> _askQuantity(MarketOrder order) {
    final controller = TextEditingController(text: order.quantity.toString());
    return showDialog<int>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Comprar ${order.resourceLabel}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('De ${order.trader} · ${_price(order.unitPrice)} Fert\$/un · '
                'disponível ${order.quantity} un'),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              autofocus: true,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Quantidade', border: OutlineInputBorder()),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          FilledButton(
            onPressed: () {
              final q = int.tryParse(controller.text) ?? 0;
              if (q < 1 || q > order.quantity) return;
              Navigator.pop(ctx, q);
            },
            child: const Text('Comprar'),
          ),
        ],
      ),
    );
  }

  /// Cria um anúncio de venda (escrow, §13) a partir do estoque do jogador.
  Future<void> _sell(List<MarketTicker> tickers) async {
    if (tickers.isEmpty) return;
    final messenger = ScaffoldMessenger.of(context);
    final spec = await showDialog<({String key, int qty, double price})>(
      context: context,
      builder: (ctx) => _SellDialog(tickers: tickers),
    );
    if (spec == null) return;
    try {
      await ref.read(marketRepositoryProvider).createListing(
            resourceKey: spec.key,
            quantity: spec.qty,
            unitPrice: spec.price,
          );
      ref.invalidate(marketBoardProvider);
      ref.invalidate(resourcesProvider);
      if (!mounted) return;
      messenger.showSnackBar(const SnackBar(
        content: Text('Anúncio criado. Recurso reservado em escrow até a venda.'),
        behavior: SnackBarBehavior.floating,
      ));
    } on DioException catch (e) {
      if (!mounted) return;
      messenger.showSnackBar(SnackBar(
        content: Text('Não foi possível anunciar: ${_dioMessage(e)}'),
        behavior: SnackBarBehavior.floating,
      ));
    }
  }

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
                  FilledButton.icon(
                    onPressed: () => _sell(b.tickers),
                    icon: const Icon(Icons.sell_outlined, size: 17),
                    label: const Text('Vender'),
                    style: FilledButton.styleFrom(
                      visualDensity: VisualDensity.compact,
                      backgroundColor: FwPalette.rust600,
                    ),
                  ),
                  SizedBox(width: t.space2),
                  OutlinedButton.icon(
                    onPressed: () => context.go('/market/auctions'),
                    icon: const Icon(Icons.gavel_outlined, size: 17),
                    label: const Text('Leilões'),
                    style: OutlinedButton.styleFrom(
                      visualDensity: VisualDensity.compact,
                      side: const BorderSide(color: FwPalette.rust300),
                      foregroundColor: FwPalette.rust700,
                    ),
                  ),
                  SizedBox(width: t.space2),
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
                      itemBuilder: (_, i) => _OrderCard(order: orders[i], onBuy: _buy),
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
  const _OrderCard({required this.order, this.onBuy});
  final MarketOrder order;
  final ValueChanged<MarketOrder>? onBuy;

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
            onPressed: isBuy
                ? () => ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Responder a ordens de compra sai pela ação "Vender" no topo.'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    )
                : () => onBuy?.call(order),
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

/// Diálogo de criação de anúncio de venda (§13): recurso + quantidade + preço.
class _SellDialog extends StatefulWidget {
  const _SellDialog({required this.tickers});
  final List<MarketTicker> tickers;

  @override
  State<_SellDialog> createState() => _SellDialogState();
}

class _SellDialogState extends State<_SellDialog> {
  late String _key = widget.tickers.first.resourceId;
  final _qty = TextEditingController(text: '100');
  late final _price = TextEditingController(
    text: _price0(widget.tickers.first.lastPrice),
  );

  static String _price0(double v) => v >= 1 ? v.toStringAsFixed(2) : v.toStringAsFixed(4);

  @override
  void dispose() {
    _qty.dispose();
    _price.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Anunciar venda'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DropdownButtonFormField<String>(
            initialValue: _key,
            isExpanded: true,
            decoration: const InputDecoration(labelText: 'Recurso', border: OutlineInputBorder()),
            items: [
              for (final tk in widget.tickers)
                DropdownMenuItem(
                  value: tk.resourceId,
                  child: Row(children: [
                    Icon(resourceIcon(tk.resourceId), size: 16, color: resourceColor(tk.resourceId)),
                    const SizedBox(width: 8),
                    Flexible(child: Text(tk.resourceLabel, overflow: TextOverflow.ellipsis)),
                  ]),
                ),
            ],
            onChanged: (v) {
              if (v == null) return;
              final tk = widget.tickers.firstWhere((t) => t.resourceId == v);
              setState(() {
                _key = v;
                _price.text = _price0(tk.lastPrice);
              });
            },
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _qty,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Quantidade', border: OutlineInputBorder()),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _price,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(labelText: 'Preço unitário (Fert\$)', border: OutlineInputBorder()),
          ),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
        FilledButton(
          onPressed: () {
            final q = int.tryParse(_qty.text) ?? 0;
            final p = double.tryParse(_price.text.replaceAll(',', '.')) ?? 0;
            if (q < 1 || p <= 0) return;
            Navigator.pop(context, (key: _key, qty: q, price: p));
          },
          child: const Text('Anunciar'),
        ),
      ],
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
