import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../app/theme/ds_colors.dart';
import '../../app/theme/ds_tokens.dart';
import '../../data/providers.dart';
import '../../domain/models/colony_buildings.dart';
import 'colony_building_panel.dart';
import 'game/colony_game.dart';

/// Colônia = Slot do colono (GDD v21 §17): base com construções de produção,
/// estrutura, militar e transporte + slots livres. Drill-in a partir do planeta;
/// a Capital (governo) é separada, alcançada pelo botão "Capital".
class ColonyScreen extends ConsumerWidget {
  const ColonyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final base = ref.watch(colonyBaseProvider);

    return base.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, __) => Center(
        child: TextButton.icon(
          onPressed: () => ref.invalidate(colonyBaseProvider),
          icon: const Icon(Icons.refresh),
          label: const Text('Não foi possível carregar a colônia. Tocar para tentar de novo.'),
        ),
      ),
      data: (data) => _ColonyView(base: data),
    );
  }
}

class _ColonyView extends StatefulWidget {
  const _ColonyView({required this.base});
  final ColonyBase base;

  @override
  State<_ColonyView> createState() => _ColonyViewState();
}

class _ColonyViewState extends State<_ColonyView> {
  ColonyBuilding? _selected;
  late final FertwaysColonyGame _game = FertwaysColonyGame(widget.base, onTap: _select);

  void _select(ColonyBuilding b) => setState(() {
        _selected = b;
        _game.selectedId = b.id;
      });

  void _deselect() => setState(() {
        _selected = null;
        _game.selectedId = null;
      });

  void _toast(String msg) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg), behavior: SnackBarBehavior.floating, duration: const Duration(seconds: 2)),
      );

  void _runAction(ColonyBuilding b) {
    if (b.isHabitat) {
      context.go('/capital');
    } else if (b.isFree) {
      _showBuildSheet();
    } else {
      _toast('Melhorar ${b.name} (Nv ${b.level} → ${b.level + 1}) — em breve');
    }
  }

  /// Fluxo de construir: escolher a estrutura para o slot livre (GDD v21 §17).
  void _showBuildSheet() {
    const options = <(String, IconData)>[
      ('Fazenda', Icons.eco_outlined),
      ('Captação de Água', Icons.water_drop_outlined),
      ('Reator de Energia', Icons.bolt_outlined),
      ('Oficina', Icons.build_outlined),
      ('Refinaria Química', Icons.science_outlined),
      ('Laboratório', Icons.biotech_outlined),
      ('Quartel', Icons.shield_outlined),
      ('Plataforma de Pouso', Icons.flight_land_outlined),
      ('Torre de Defesa', Icons.security_outlined),
      ('Mercado Local', Icons.storefront_outlined),
    ];
    final t = Theme.of(context).extension<DsTokens>()!;
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheetCtx) => Padding(
        padding: EdgeInsets.fromLTRB(t.space4, 0, t.space4, t.space4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Construir no slot livre',
                style: GoogleFonts.rajdhani(fontWeight: FontWeight.w700, fontSize: 18, color: FwPalette.gray900)),
            SizedBox(height: t.space1),
            Text('Escolha a estrutura (GDD §17). Especializações desbloqueiam variantes potencializadas.',
                style: TextStyle(fontSize: 12, color: t.textSecondary)),
            SizedBox(height: t.space3),
            Wrap(
              spacing: t.space2,
              runSpacing: t.space2,
              children: [
                for (final o in options)
                  ActionChip(
                    avatar: Icon(o.$2, size: 16, color: FwPalette.rust600),
                    label: Text(o.$1),
                    side: BorderSide(color: t.borderDefault),
                    onPressed: () {
                      Navigator.of(sheetCtx).pop();
                      _toast('Construir ${o.$1} — em breve');
                    },
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).extension<DsTokens>()!;
    return Stack(
      children: [
        Positioned.fill(child: GameWidget<FertwaysColonyGame>(game: _game)),
        Positioned(top: t.space4, left: t.space4, child: _Header(base: widget.base)),
        Positioned(top: t.space4, right: t.space4, child: const _CapitalButton()),
        Positioned(right: t.space4, bottom: t.space4, child: _ZoomControls(game: _game)),
        if (_selected != null)
          Positioned(
            left: t.space4,
            bottom: t.space4,
            child: ColonyBuildingPanel(
              building: _selected!,
              onClose: _deselect,
              onAction: () => _runAction(_selected!),
            ),
          ),
      ],
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.base});
  final ColonyBase base;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).extension<DsTokens>()!;
    final scheme = Theme.of(context).colorScheme;
    final spec = base.specialization.isEmpty ? '' : ' · Especialização ${base.specialization}';
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
              Text('${base.name}  ·  Slot',
                  style: GoogleFonts.rajdhani(fontWeight: FontWeight.w700, color: FwPalette.gray900)),
              Text('${base.builtCount} construções · ${base.freeCount} livres$spec',
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
      label: const Text('Capital'),
      style: FilledButton.styleFrom(backgroundColor: FwPalette.rust600, minimumSize: Size(0, t.controlLg)),
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
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(t.radiusMd), border: Border.all(color: t.borderDefault)),
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
