import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../app/theme/ds_colors.dart';
import '../../app/theme/ds_tokens.dart';
import '../../data/providers.dart';
import '../../domain/models/spaceport.dart';

/// Espaçoporto (GDD §3): rotas de comércio aos 5 planetas NPC + frota de
/// Cargueiros Interplanetários.
class SpaceportScreen extends ConsumerWidget {
  const SpaceportScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = Theme.of(context).extension<DsTokens>()!;
    final state = ref.watch(spaceportProvider);

    return state.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, __) => Center(
        child: TextButton.icon(
          onPressed: () => ref.invalidate(spaceportProvider),
          icon: const Icon(Icons.refresh),
          label: const Text('Não foi possível carregar o Espaçoporto. Tocar para tentar de novo.'),
        ),
      ),
      data: (s) => ListView(
        padding: EdgeInsets.all(t.space4),
        children: [
          Row(
            children: [
              const Icon(Icons.rocket_launch_outlined, size: 22, color: FwPalette.solar600),
              SizedBox(width: t.space2),
              Text('Espaçoporto',
                  style: GoogleFonts.rajdhani(fontWeight: FontWeight.w700, fontSize: 22, color: FwPalette.gray900)),
              const Spacer(),
              _FleetChip(available: s.freighters, total: s.freightersTotal),
            ],
          ),
          SizedBox(height: t.space2),
          Text('Comércio com planetas NPC. Cargueiros Interplanetários levam recursos e trazem o que falta.',
              style: TextStyle(fontSize: 12.5, color: t.textSecondary)),
          SizedBox(height: t.space4),
          for (final p in s.planets) Padding(
            padding: EdgeInsets.only(bottom: t.space3),
            child: _PlanetCard(planet: p),
          ),
        ],
      ),
    );
  }
}

class _FleetChip extends StatelessWidget {
  const _FleetChip({required this.available, required this.total});
  final int available;
  final int total;
  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).extension<DsTokens>()!;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: t.space3, vertical: t.space2),
      decoration: BoxDecoration(
        color: FwPalette.solar100.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(t.radiusMd),
        border: Border.all(color: t.borderDefault),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.local_shipping_outlined, size: 16, color: FwPalette.solar700),
          SizedBox(width: t.space2),
          Text('$available/$total cargueiros',
              style: GoogleFonts.rajdhani(fontWeight: FontWeight.w700, fontSize: 13, color: FwPalette.solar700)),
        ],
      ),
    );
  }
}

class _PlanetCard extends StatelessWidget {
  const _PlanetCard({required this.planet});
  final NpcPlanet planet;

  (Color, IconData) _risk(DsTokens t) => switch (planet.risk) {
        RouteRisk.none => (t.success, Icons.check_circle_outline),
        RouteRisk.low => (t.warning, Icons.warning_amber_outlined),
        RouteRisk.high => (FwPalette.red600, Icons.dangerous_outlined),
      };

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).extension<DsTokens>()!;
    final scheme = Theme.of(context).colorScheme;
    final (riskColor, riskIcon) = _risk(t);

    return Container(
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(t.radiusCard),
        border: Border.all(color: t.borderDefault),
      ),
      child: Padding(
        padding: EdgeInsets.all(t.space4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [FwPalette.rust300, FwPalette.solar400],
                    ),
                    borderRadius: BorderRadius.circular(t.radiusMd),
                  ),
                  child: const Icon(Icons.public, color: Colors.white, size: 24),
                ),
                SizedBox(width: t.space3),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(planet.name,
                          style: GoogleFonts.rajdhani(
                              fontWeight: FontWeight.w700, fontSize: 17, color: FwPalette.gray900)),
                      Row(
                        children: [
                          Icon(Icons.schedule, size: 13, color: t.textSecondary),
                          const SizedBox(width: 3),
                          Text(planet.distance, style: TextStyle(fontSize: 12, color: t.textSecondary)),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                  decoration: BoxDecoration(color: riskColor.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(8)),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(riskIcon, size: 13, color: riskColor),
                      const SizedBox(width: 4),
                      Text(planet.riskLabel,
                          style: GoogleFonts.rajdhani(fontWeight: FontWeight.w700, fontSize: 11.5, color: riskColor)),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: t.space3),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: _Trade(label: 'Exporta', value: planet.exports, color: t.deltaUp, icon: Icons.north_east)),
                SizedBox(width: t.space3),
                Expanded(child: _Trade(label: 'Importa', value: planet.imports, color: t.teal, icon: Icons.south_west)),
              ],
            ),
            SizedBox(height: t.space3),
            Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Enviar Cargueiro a ${planet.name} (${planet.distance}) — em breve'),
                        behavior: SnackBarBehavior.floating,
                        duration: const Duration(seconds: 2),
                      ),
                    ),
                    icon: const Icon(Icons.send_outlined, size: 18),
                    label: const Text('Enviar carga'),
                    style: FilledButton.styleFrom(backgroundColor: FwPalette.rust600, minimumSize: Size(0, t.controlLg)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Trade extends StatelessWidget {
  const _Trade({required this.label, required this.value, required this.color, required this.icon});
  final String label;
  final String value;
  final Color color;
  final IconData icon;
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 13, color: color),
            const SizedBox(width: 4),
            Text(label, style: GoogleFonts.rajdhani(fontWeight: FontWeight.w700, fontSize: 11.5, color: color)),
          ],
        ),
        const SizedBox(height: 2),
        Text(value, style: const TextStyle(fontSize: 12.5, color: FwPalette.gray800, height: 1.3)),
      ],
    );
  }
}
