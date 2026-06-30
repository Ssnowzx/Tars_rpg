import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../app/theme/ds_colors.dart';
import '../../app/theme/ds_tokens.dart';
import '../../domain/models/colony_lots.dart';
import '../../domain/models/world_models.dart';
import 'game/colony_game.dart' show colonyLotColor, colonyLotIcon;

String _kindLabel(PlotKind k) => switch (k) {
      PlotKind.water => 'Aquífero (Água)',
      PlotKind.metals => 'Mina (Metais Ferrosos)',
      PlotKind.biomass => 'Estufa (Biomassa)',
      PlotKind.energy => 'Campo Solar (Energia)',
      PlotKind.factory => 'Fábrica (Componentes)',
      PlotKind.capital => 'Capital',
      _ => 'Lote livre',
    };

/// Painel com os dados de um lote da colônia + ação (construir/melhorar/abrir).
class ColonyLotPanel extends StatelessWidget {
  const ColonyLotPanel({super.key, required this.lot, required this.onClose, this.onAction});

  final ColonyLot lot;
  final VoidCallback onClose;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).extension<DsTokens>()!;
    final scheme = Theme.of(context).colorScheme;
    final color = colonyLotColor(lot.kind);

    final (actionLabel, actionIcon) = switch (true) {
      _ when lot.isCapital => ('Abrir Capital', Icons.account_balance_outlined),
      _ when lot.isFree => ('Construir lote', Icons.add),
      _ => ('Melhorar', Icons.upgrade),
    };

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
                  child: Icon(colonyLotIcon(lot.kind), color: color, size: 22),
                ),
                SizedBox(width: t.space3),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(lot.name,
                          style: GoogleFonts.rajdhani(
                              fontWeight: FontWeight.w700, fontSize: 16, color: FwPalette.gray900),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis),
                      Text(
                          lot.isFree
                              ? 'Disponível para construção'
                              : '${_kindLabel(lot.kind)}${lot.isCapital ? '' : ' · Nível ${lot.level}'}',
                          style: TextStyle(fontSize: 11.5, color: t.textSecondary)),
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
          if (lot.isFree)
            Padding(
              padding: EdgeInsets.all(t.space4),
              child: Text(
                'Terreno livre na colônia. Construa um lote de produção (água, metais, biomassa, energia ou fábrica) para aumentar a renda por hora.',
                style: TextStyle(fontSize: 12.5, color: t.textSecondary, height: 1.4),
              ),
            )
          else
            Padding(
              padding: EdgeInsets.all(t.space4),
              child: Row(
                children: [
                  _Stat(
                      label: 'Produção',
                      value: lot.isCapital ? '—' : '${lot.perHour >= 0 ? '+' : ''}${lot.perHour}/h',
                      color: lot.perHour >= 0 ? t.deltaUp : FwPalette.red600),
                  _Stat(label: 'Nível', value: '${lot.level}', color: FwPalette.gray900),
                  _Stat(label: 'Conservação', value: '92%', color: t.success),
                ],
              ),
            ),
          Padding(
            padding: EdgeInsets.fromLTRB(t.space4, 0, t.space4, t.space4),
            child: FilledButton.icon(
              onPressed: onAction,
              icon: Icon(actionIcon, size: 18),
              label: Text(actionLabel),
              style: FilledButton.styleFrom(
                minimumSize: Size(double.infinity, t.controlLg),
                backgroundColor: FwPalette.rust600,
              ),
            ),
          ),
        ],
      ),
    );
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
