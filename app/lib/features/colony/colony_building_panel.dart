import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../app/theme/ds_colors.dart';
import '../../app/theme/ds_tokens.dart';
import '../../domain/models/colony_buildings.dart';
import 'game/colony_game.dart' show buildingColor, buildingIcon;

String _categoryLabel(BuildingCategory c) => switch (c) {
      BuildingCategory.habitat => 'Estrutura central',
      BuildingCategory.oxygen => 'Produção · Oxigênio',
      BuildingCategory.water => 'Produção · Água',
      BuildingCategory.metals => 'Produção · Ligas Metálicas',
      BuildingCategory.rawmetal => 'Produção · Metal Bruto',
      BuildingCategory.biomass => 'Produção · Biomassa',
      BuildingCategory.energy => 'Produção · Energia',
      BuildingCategory.components => 'Produção · Compostos',
      BuildingCategory.biofuel => 'Produção · Biocombustível',
      BuildingCategory.military => 'Militar',
      BuildingCategory.research => 'Pesquisa',
      BuildingCategory.transport => 'Transporte',
      BuildingCategory.special => 'Especialização',
      BuildingCategory.empty => 'Slot livre',
    };

/// Receitas de Componentes Eletrônicos da Oficina (GDD v29 §24.5).
const _componentRecipes = <(String, String)>[
  ('Básica', '4 minerais · 5 Água · 10 kWh'),
  ('Intermediária', '5 minerais · 4 Oxigênio · 14 kWh'),
  ('Avançada', '7 minerais (Tântalo★/Ouro★) · 3 Biocombustível · 20 kWh'),
];

/// Painel com os dados de uma construção do Slot + ação (construir/melhorar/abrir).
class ColonyBuildingPanel extends StatelessWidget {
  const ColonyBuildingPanel({super.key, required this.building, required this.onClose, this.onAction});

  final ColonyBuilding building;
  final VoidCallback onClose;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).extension<DsTokens>()!;
    final scheme = Theme.of(context).colorScheme;
    final color = buildingColor(building.category);

    final (actionLabel, actionIcon) = switch (true) {
      _ when building.isHabitat => ('Abrir Capital', Icons.account_balance_outlined),
      _ when building.isFree => ('Construir', Icons.add),
      _ => ('Melhorar', Icons.upgrade),
    };

    return Container(
      width: 330,
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(t.radiusCard),
        border: Border.all(color: t.borderDefault),
        boxShadow: [
          BoxShadow(color: FwPalette.gray900.withValues(alpha: 0.16), blurRadius: 24, offset: const Offset(0, 10)),
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
                  decoration: BoxDecoration(color: color.withValues(alpha: 0.14), borderRadius: BorderRadius.circular(t.radiusMd)),
                  child: Icon(buildingIcon(building.category), color: color, size: 22),
                ),
                SizedBox(width: t.space3),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(building.name,
                          style: GoogleFonts.rajdhani(fontWeight: FontWeight.w700, fontSize: 16, color: FwPalette.gray900),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis),
                      Text(
                          building.isFree
                              ? 'Disponível para construção'
                              : '${_categoryLabel(building.category)}${building.isHabitat ? '' : ' · Nível ${building.level}'}',
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
          if (building.isSubsidized) _SubsidyBanner(),
          if (building.isFree)
            Padding(
              padding: EdgeInsets.all(t.space4),
              child: Text(
                'Terreno livre no Slot. Construa uma estrutura (produção, militar, transporte ou da sua especialização) para crescer a colônia.',
                style: TextStyle(fontSize: 12.5, color: t.textSecondary, height: 1.4),
              ),
            )
          else
            Padding(
              padding: EdgeInsets.all(t.space4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      _Stat(
                          label: 'Produção',
                          value: building.perHour != 0 ? '${building.perHour >= 0 ? '+' : ''}${building.perHour}/h' : '—',
                          color: building.perHour >= 0 ? t.deltaUp : FwPalette.red600),
                      _Stat(label: 'Nível', value: '${building.level}', color: FwPalette.gray900),
                      _Stat(label: 'Conservação', value: '92%', color: t.success),
                    ],
                  ),
                  if (building.category == BuildingCategory.metals) ...[
                    SizedBox(height: t.space3),
                    const _RecipesBlock(),
                  ],
                ],
              ),
            ),
          Padding(
            padding: EdgeInsets.fromLTRB(t.space4, 0, t.space4, t.space4),
            child: FilledButton.icon(
              onPressed: onAction,
              icon: Icon(actionIcon, size: 18),
              label: Text(actionLabel),
              style: FilledButton.styleFrom(minimumSize: Size(double.infinity, t.controlLg), backgroundColor: FwPalette.rust600),
            ),
          ),
        ],
      ),
    );
  }
}

/// Aviso de subsídio do Governo Central (GDD v29 §24.7).
class _SubsidyBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).extension<DsTokens>()!;
    return Container(
      margin: EdgeInsets.fromLTRB(t.space4, t.space3, t.space4, 0),
      padding: EdgeInsets.all(t.space2),
      decoration: BoxDecoration(
        color: FwPalette.green600.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(t.radiusSm),
        border: Border.all(color: FwPalette.green600.withValues(alpha: 0.35)),
      ),
      child: Row(
        children: [
          const Icon(Icons.volunteer_activism_outlined, size: 15, color: FwPalette.green800),
          SizedBox(width: t.space2),
          const Expanded(
            child: Text('Custeada pelo Governo Central até o nível 3 (§24.7).',
                style: TextStyle(fontSize: 11.5, color: FwPalette.green800, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}

/// Receitas de Componentes Eletrônicos da Oficina (GDD v29 §24.5).
class _RecipesBlock extends StatelessWidget {
  const _RecipesBlock();
  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).extension<DsTokens>()!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('RECEITAS DE COMPONENTES (§24.5)',
            style: GoogleFonts.rajdhani(
                fontWeight: FontWeight.w700, fontSize: 10.5, letterSpacing: 0.8, color: FwPalette.gray500)),
        SizedBox(height: t.space2),
        for (final (name, inputs) in _componentRecipes)
          Padding(
            padding: EdgeInsets.only(bottom: t.space1),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 2),
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                  decoration: BoxDecoration(
                    color: FwPalette.purple600.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(name,
                      style: const TextStyle(
                          fontSize: 10, fontWeight: FontWeight.w700, color: FwPalette.purple600)),
                ),
                SizedBox(width: t.space2),
                Expanded(
                  child: Text(inputs, style: TextStyle(fontSize: 11.5, color: t.textSecondary, height: 1.3)),
                ),
              ],
            ),
          ),
      ],
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
