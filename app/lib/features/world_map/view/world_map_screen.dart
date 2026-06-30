import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../app/theme/ds_colors.dart';
import '../../../app/theme/ds_tokens.dart';
import '../../../data/providers.dart';
import '../../../domain/models/planet_models.dart';
import '../game/fertways_world_game.dart';
import 'map_node_panel.dart';

/// Tela do mapa-planeta: canvas Flame (terreno + colônias + zonas) com painéis
/// flutuantes. A barra de recursos fica no shell.
class WorldMapScreen extends ConsumerWidget {
  const WorldMapScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final planet = ref.watch(planetProvider);

    return planet.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, __) => Center(
        child: TextButton.icon(
          onPressed: () => ref.invalidate(planetProvider),
          icon: const Icon(Icons.refresh),
          label: const Text('Não foi possível carregar o mapa. Tocar para tentar de novo.'),
        ),
      ),
      data: (state) => _MapView(state: state),
    );
  }
}

class _MapView extends StatefulWidget {
  const _MapView({required this.state});
  final PlanetState state;

  @override
  State<_MapView> createState() => _MapViewState();
}

class _MapViewState extends State<_MapView> {
  MapNode? _selected;
  late final FertwaysWorldGame _game = FertwaysWorldGame(
    widget.state,
    onNodeTap: _select,
  );

  void _select(MapNode n) => setState(() {
        _selected = n;
        _game.selectedId = n.id;
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

  void _runAction(MapNode node) {
    switch (node.type) {
      case MapNodeType.ownColony:
        context.go('/map/colony');
      case MapNodeType.spaceport:
        context.go('/spaceport');
      case MapNodeType.neighborColony:
        _toast('Perfil de ${node.name} — em breve');
      case MapNodeType.neutralZone:
        context.go('/map/zone', extra: node);
      case MapNodeType.freeSlot:
        _toast('Fundar colônia neste setor — em breve');
      case MapNodeType.landmark:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).extension<DsTokens>()!;
    return Stack(
      children: [
        Positioned.fill(child: GameWidget<FertwaysWorldGame>(game: _game)),
        Positioned(top: t.space4, left: t.space4, child: _PlanetChip(sector: widget.state.ownSector)),
        Positioned(top: t.space4, right: t.space4, child: const _Legend()),
        Positioned(right: t.space4, bottom: t.space4, child: _ZoomControls(game: _game)),
        if (_selected != null)
          Positioned(
            left: t.space4,
            bottom: t.space4,
            child: MapNodePanel(
              node: _selected!,
              onClose: _deselect,
              onAction: () => _runAction(_selected!),
            ),
          ),
      ],
    );
  }
}

class _PlanetChip extends StatelessWidget {
  const _PlanetChip({required this.sector});
  final String sector;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).extension<DsTokens>()!;
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: t.space3, vertical: t.space2),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(t.radiusMd),
        border: Border.all(color: t.borderDefault),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.public_outlined, size: 15, color: FwPalette.rust600),
          SizedBox(width: t.space2),
          Text('Fertways',
              style: GoogleFonts.rajdhani(fontWeight: FontWeight.w700, color: FwPalette.gray900)),
          if (sector.isNotEmpty) ...[
            SizedBox(width: t.space2),
            Container(width: 1, height: 14, color: t.borderDefault),
            SizedBox(width: t.space2),
            Text('Setor $sector', style: TextStyle(fontSize: 12, color: t.textSecondary)),
          ],
        ],
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  const _Legend();

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).extension<DsTokens>()!;
    final scheme = Theme.of(context).colorScheme;
    Widget row(Color c, String label) => Padding(
          padding: EdgeInsets.symmetric(vertical: t.space1),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(color: c, shape: BoxShape.circle),
              ),
              SizedBox(width: t.space2),
              Text(label, style: const TextStyle(fontSize: 12, color: FwPalette.gray800)),
            ],
          ),
        );
    return Container(
      padding: EdgeInsets.fromLTRB(t.space3, t.space3, t.space4, t.space3),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(t.radiusMd),
        border: Border.all(color: t.borderDefault),
        boxShadow: [
          BoxShadow(
            color: FwPalette.gray900.withValues(alpha: 0.10),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('LEGENDA',
              style: GoogleFonts.rajdhani(
                  fontWeight: FontWeight.w700,
                  fontSize: 11,
                  letterSpacing: 1.5,
                  color: FwPalette.gray500)),
          SizedBox(height: t.space2),
          row(FwPalette.rust600, 'Sua colônia'),
          row(FwPalette.teal600, 'Aliado'),
          row(FwPalette.gray500, 'Neutro'),
          row(FwPalette.red600, 'Hostil'),
          row(FwPalette.solar600, 'Espaçoporto'),
          row(FwPalette.gray400, 'Lote livre'),
        ],
      ),
    );
  }
}

class _ZoomControls extends StatelessWidget {
  const _ZoomControls({required this.game});
  final FertwaysWorldGame game;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).extension<DsTokens>()!;
    final scheme = Theme.of(context).colorScheme;
    Widget btn(IconData i, VoidCallback onTap, String tip) => Tooltip(
          message: tip,
          child: InkWell(
            onTap: onTap,
            child: SizedBox(
              width: 40,
              height: 40,
              child: Icon(i, size: 18, color: FwPalette.gray700),
            ),
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
