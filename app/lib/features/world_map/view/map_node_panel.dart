import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../app/theme/ds_colors.dart';
import '../../../app/theme/ds_tokens.dart';
import '../../../domain/models/planet_models.dart';
import '../game/fertways_world_game.dart' show mapNodeColor, mapNodeIcon, relationColor;

String _typeLabel(MapNodeType t) => switch (t) {
      MapNodeType.ownColony => 'Sua colônia',
      MapNodeType.neighborColony => 'Colônia vizinha',
      MapNodeType.neutralZone => 'Zona neutra',
      MapNodeType.spaceport => 'Espaçoporto',
      MapNodeType.landmark => 'Marco',
      MapNodeType.freeSlot => 'Lote livre',
    };

String _relationLabel(Relation r) => switch (r) {
      Relation.self => 'Você',
      Relation.ally => 'Aliado',
      Relation.neutral => 'Neutro',
      Relation.hostile => 'Hostil',
    };

String _resourceLabel(ZoneResource k) => switch (k) {
      ZoneResource.water => 'Água',
      ZoneResource.metals => 'Metais Ferrosos',
      ZoneResource.biomass => 'Biomassa',
      ZoneResource.energy => 'Energia',
      ZoneResource.components => 'Componentes',
      ZoneResource.none => '—',
    };

String? _actionLabel(MapNodeType t) => switch (t) {
      MapNodeType.ownColony => 'Entrar na Colônia',
      MapNodeType.spaceport => 'Ir ao Espaçoporto',
      MapNodeType.neighborColony => 'Ver perfil',
      MapNodeType.neutralZone => 'Gerenciar zona',
      MapNodeType.freeSlot => 'Fundar colônia',
      MapNodeType.landmark => null,
    };

IconData _actionIcon(MapNodeType t) => switch (t) {
      MapNodeType.ownColony => Icons.account_balance_outlined,
      MapNodeType.spaceport => Icons.rocket_launch_outlined,
      MapNodeType.neighborColony => Icons.person_outline,
      MapNodeType.neutralZone => Icons.flag_outlined,
      MapNodeType.freeSlot => Icons.add_location_alt_outlined,
      MapNodeType.landmark => Icons.info_outline,
    };

/// Painel flutuante com os dados de um nó do mapa-planeta + ação principal.
class MapNodePanel extends StatelessWidget {
  const MapNodePanel({super.key, required this.node, required this.onClose, this.onAction});

  final MapNode node;
  final VoidCallback onClose;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).extension<DsTokens>()!;
    final scheme = Theme.of(context).colorScheme;
    final color = mapNodeColor(node);
    final action = _actionLabel(node.type);

    return Container(
      width: 330,
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(t.radiusCard),
        border: Border.all(color: t.borderDefault),
        boxShadow: [
          BoxShadow(
            color: FwPalette.gray900.withValues(alpha: 0.16),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(t.space4, t.space3, t.space2, t.space2),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(t.radiusMd),
                  ),
                  child: Icon(mapNodeIcon(node), color: color, size: 22),
                ),
                SizedBox(width: t.space3),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(node.name,
                          style: GoogleFonts.rajdhani(
                              fontWeight: FontWeight.w700, fontSize: 16, color: FwPalette.gray900),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis),
                      Text(_subtitle(), style: TextStyle(fontSize: 11.5, color: t.textSecondary)),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: onClose,
                  icon: const Icon(Icons.close, size: 18),
                  visualDensity: VisualDensity.compact,
                  tooltip: 'Fechar',
                ),
              ],
            ),
          ),
          Divider(height: 1, color: t.borderDefault),
          _body(context, t, color),
          if (action != null)
            Padding(
              padding: EdgeInsets.fromLTRB(t.space4, 0, t.space4, t.space4),
              child: FilledButton.icon(
                onPressed: onAction,
                icon: Icon(_actionIcon(node.type), size: 18),
                label: Text(action),
                style: FilledButton.styleFrom(
                  minimumSize: Size(double.infinity, t.controlLg),
                  backgroundColor: node.type == MapNodeType.spaceport
                      ? FwPalette.solar600
                      : FwPalette.rust600,
                ),
              ),
            ),
        ],
      ),
    );
  }

  String _subtitle() {
    final parts = <String>[_typeLabel(node.type)];
    if (node.sector != null) parts.add('Setor ${node.sector}');
    return parts.join(' · ');
  }

  Widget _body(BuildContext context, DsTokens t, Color color) {
    switch (node.type) {
      case MapNodeType.ownColony:
      case MapNodeType.neighborColony:
        return Padding(
          padding: EdgeInsets.all(t.space4),
          child: Row(
            children: [
              _Stat(label: 'Relação', value: _relationLabel(node.relation), color: relationColor(node.relation)),
              _Stat(label: 'Nível', value: '${node.level}', color: FwPalette.gray900),
              _Stat(label: 'Governador', value: node.owner ?? '—', color: t.textSecondary),
            ],
          ),
        );
      case MapNodeType.neutralZone:
        return Padding(
          padding: EdgeInsets.all(t.space4),
          child: Row(
            children: [
              _Stat(label: 'Recurso', value: _resourceLabel(node.resource), color: color),
              _Stat(label: 'Depósito', value: 'Nv ${node.level}', color: FwPalette.gray900),
              _Stat(label: 'Status', value: 'Livre', color: t.success),
            ],
          ),
        );
      case MapNodeType.spaceport:
        return Padding(
          padding: EdgeInsets.all(t.space4),
          child: Text(
            'Gateway de comércio interplanetário. Envie cargas para os 5 planetas NPC (Kalidor, Veyra, Auryn, Solène, Drakmoor).',
            style: TextStyle(fontSize: 12.5, color: t.textSecondary, height: 1.4),
          ),
        );
      case MapNodeType.freeSlot:
        return Padding(
          padding: EdgeInsets.all(t.space4),
          child: Text(
            'Terreno disponível para expansão. Funde uma nova colônia ou construa um lote de produção neste setor.',
            style: TextStyle(fontSize: 12.5, color: t.textSecondary, height: 1.4),
          ),
        );
      case MapNodeType.landmark:
        return Padding(
          padding: EdgeInsets.all(t.space4),
          child: Text(
            node.note ?? '',
            style: TextStyle(fontSize: 12.5, color: t.textSecondary, height: 1.4),
          ),
        );
    }
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.label, required this.value, required this.color});
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).extension<DsTokens>()!;
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontSize: 10.5, color: t.textSecondary)),
          SizedBox(height: t.space1),
          Text(value,
              style: GoogleFonts.rajdhani(fontWeight: FontWeight.w700, fontSize: 15, color: color),
              maxLines: 1,
              overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }
}
