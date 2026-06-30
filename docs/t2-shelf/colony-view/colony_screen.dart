import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../app/theme/ds_colors.dart';
import '../../app/theme/ds_tokens.dart';
import '../../data/providers.dart';
import '../../domain/models/colony_lots.dart';
import 'colony_lot_panel.dart';
import 'game/colony_game.dart';

/// Nível Colônia: a base do jogador (lotes de recurso + lotes livres). Drill-in
/// a partir do mapa-planeta; daqui entra-se na Capital (instituições).
class ColonyScreen extends ConsumerWidget {
  const ColonyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final layout = ref.watch(colonyLayoutProvider);

    return layout.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, __) => Center(
        child: TextButton.icon(
          onPressed: () => ref.invalidate(colonyLayoutProvider),
          icon: const Icon(Icons.refresh),
          label: const Text('Não foi possível carregar a colônia. Tocar para tentar de novo.'),
        ),
      ),
      data: (data) => _ColonyView(layout: data),
    );
  }
}

class _ColonyView extends StatefulWidget {
  const _ColonyView({required this.layout});
  final ColonyLayout layout;

  @override
  State<_ColonyView> createState() => _ColonyViewState();
}

class _ColonyViewState extends State<_ColonyView> {
  ColonyLot? _selected;
  late final FertwaysColonyGame _game = FertwaysColonyGame(
    widget.layout,
    onLotTap: _select,
  );

  void _select(ColonyLot l) => setState(() {
        _selected = l;
        _game.selectedId = l.id;
      });

  void _deselect() => setState(() {
        _selected = null;
        _game.selectedId = null;
      });

  void _toast(String msg) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(msg),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );

  void _runAction(ColonyLot lot) {
    if (lot.isCapital) {
      context.go('/capital');
    } else if (lot.isFree) {
      _toast('Construir lote em ${lot.name} — em breve');
    } else {
      _toast('Melhorar ${lot.name} (Nv ${lot.level} → ${lot.level + 1}) — em breve');
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).extension<DsTokens>()!;
    return Stack(
      children: [
        Positioned.fill(child: GameWidget<FertwaysColonyGame>(game: _game)),
        Positioned(top: t.space4, left: t.space4, child: _Header(layout: widget.layout)),
        Positioned(top: t.space4, right: t.space4, child: const _CapitalButton()),
        Positioned(right: t.space4, bottom: t.space4, child: _ZoomControls(game: _game)),
        if (_selected != null)
          Positioned(
            left: t.space4,
            bottom: t.space4,
            child: ColonyLotPanel(
              lot: _selected!,
              onClose: _deselect,
              onAction: () => _runAction(_selected!),
            ),
          ),
      ],
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.layout});
  final ColonyLayout layout;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).extension<DsTokens>()!;
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: EdgeInsets.fromLTRB(t.space2, t.space2, t.space3, t.space2),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(t.radiusMd),
        border: Border.all(color: t.borderDefault),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          InkWell(
            onTap: () => context.go('/map'),
            borderRadius: BorderRadius.circular(t.radiusSm),
            child: const Padding(
              padding: EdgeInsets.all(4),
              child: Icon(Icons.arrow_back, size: 18, color: FwPalette.gray700),
            ),
          ),
          SizedBox(width: t.space2),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(layout.name,
                  style: GoogleFonts.rajdhani(fontWeight: FontWeight.w700, color: FwPalette.gray900)),
              Text('${layout.builtCount} lotes · ${layout.freeCount} livres',
                  style: TextStyle(fontSize: 11, color: t.textSecondary)),
            ],
          ),
        ],
      ),
    );
  }
}

class _CapitalButton extends StatelessWidget {
  const _CapitalButton();

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).extension<DsTokens>()!;
    return FilledButton.icon(
      onPressed: () => context.go('/capital'),
      icon: const Icon(Icons.account_balance_outlined, size: 18),
      label: const Text('Instituições'),
      style: FilledButton.styleFrom(
        backgroundColor: FwPalette.rust600,
        minimumSize: Size(0, t.controlLg),
      ),
    );
  }
}

class _ZoomControls extends StatelessWidget {
  const _ZoomControls({required this.game});
  final FertwaysColonyGame game;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).extension<DsTokens>()!;
    final scheme = Theme.of(context).colorScheme;
    Widget btn(IconData i, VoidCallback onTap, String tip) => Tooltip(
          message: tip,
          child: InkWell(
            onTap: onTap,
            child: SizedBox(width: 40, height: 40, child: Icon(i, size: 18, color: FwPalette.gray700)),
          ),
        );
    return Material(
      color: scheme.surface,
      borderRadius: BorderRadius.circular(t.radiusMd),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(t.radiusMd),
          border: Border.all(color: t.borderDefault),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            btn(Icons.add, () => game.zoomBy(1.25), 'Aproximar'),
            Divider(height: 1, color: t.borderDefault),
            btn(Icons.center_focus_strong_outlined, game.resetView, 'Centralizar'),
            Divider(height: 1, color: t.borderDefault),
            btn(Icons.remove, () => game.zoomBy(0.8), 'Afastar'),
          ],
        ),
      ),
    );
  }
}
