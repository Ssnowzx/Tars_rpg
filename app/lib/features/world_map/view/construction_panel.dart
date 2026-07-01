import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../app/theme/ds_colors.dart';
import '../../../app/theme/ds_tokens.dart';
import '../../../data/build_queue_controller.dart';
import '../../../domain/models/build_queue.dart';
import '../../../domain/models/world_models.dart' show PlotKind;

/// Painel flutuante "Construção em andamento". Lê a fila mutável
/// (`buildQueueProvider`) e anima a contagem regressiva a cada tick. Fila dupla
/// (2 vagas) nos primeiros 5 dias de conta (§20.2). Some quando não há obras.
class ConstructionPanel extends ConsumerWidget {
  const ConstructionPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = Theme.of(context).extension<DsTokens>()!;
    final scheme = Theme.of(context).colorScheme;
    final queue = ref.watch(buildQueueProvider);
    if (queue.jobs.isEmpty) return const SizedBox.shrink();
    final now = DateTime.now().millisecondsSinceEpoch;

    return Container(
      width: 320,
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(t.radiusCard),
        border: Border.all(color: t.borderDefault),
        boxShadow: [
          BoxShadow(
            color: FwPalette.gray900.withValues(alpha: 0.12),
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
            padding: EdgeInsets.fromLTRB(t.space4, t.space3, t.space3, t.space2),
            child: Row(
              children: [
                const Icon(Icons.construction_outlined, size: 18, color: FwPalette.rust600),
                SizedBox(width: t.space2),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Construção em andamento',
                          style: GoogleFonts.rajdhani(
                              fontWeight: FontWeight.w700, fontSize: 14, color: FwPalette.gray900)),
                      Text(queue.doubleQueue ? 'Fila dupla · primeiros 5 dias (§20.2)' : 'Fila de obras · Slot',
                          style: TextStyle(fontSize: 10.5, color: t.textSecondary)),
                    ],
                  ),
                ),
                _Pill(text: '${queue.jobs.length}/${queue.maxSlots}'),
              ],
            ),
          ),
          Divider(height: 1, color: t.borderDefault),
          for (final b in queue.jobs)
            _BuildRow(
              item: b,
              now: now,
              onCancel: () => ref.read(buildQueueProvider.notifier).cancel(b.id),
            ),
          Padding(
            padding: EdgeInsets.all(t.space3),
            child: FilledButton.icon(
              onPressed: () => ref.read(buildQueueProvider.notifier).finishAll(),
              icon: const Icon(Icons.flash_on, size: 18),
              label: const Text('Concluir agora'),
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

class _BuildRow extends StatelessWidget {
  const _BuildRow({required this.item, required this.now, required this.onCancel});
  final QueuedBuild item;
  final int now;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).extension<DsTokens>()!;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: t.space4, vertical: t.space3),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: _kindColor(item.kind, t).withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(t.radiusMd),
            ),
            child: Icon(_kindIcon(item.kind), size: 18, color: _kindColor(item.kind, t)),
          ),
          SizedBox(width: t.space3),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(item.name,
                          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                          overflow: TextOverflow.ellipsis),
                    ),
                    Text('Nv ${item.fromLevel} → ${item.toLevel}',
                        style: TextStyle(fontSize: 10.5, color: t.textSecondary)),
                  ],
                ),
                SizedBox(height: t.space2),
                Row(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: item.progress(now),
                          minHeight: 6,
                          backgroundColor: t.surfaceSunken,
                          valueColor: const AlwaysStoppedAnimation(FwPalette.solar500),
                        ),
                      ),
                    ),
                    SizedBox(width: t.space2),
                    Text(item.remainingLabel(now),
                        style: GoogleFonts.rajdhani(
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                            color: FwPalette.gray900,
                            fontFeatures: const [FontFeature.tabularFigures()])),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(width: t.space1),
          IconButton(
            onPressed: onCancel,
            visualDensity: VisualDensity.compact,
            tooltip: 'Cancelar obra',
            icon: Icon(Icons.close, size: 16, color: t.textSecondary),
          ),
        ],
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.text});
  final String text;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: FwPalette.solar500.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(text,
          style: GoogleFonts.rajdhani(
              fontWeight: FontWeight.w700, fontSize: 11, color: FwPalette.solar700)),
    );
  }
}

IconData _kindIcon(PlotKind k) => switch (k) {
      PlotKind.water => Icons.water_drop_outlined,
      PlotKind.metals => Icons.view_in_ar_outlined,
      PlotKind.biomass => Icons.eco_outlined,
      PlotKind.energy => Icons.bolt_outlined,
      PlotKind.factory => Icons.factory_outlined,
      _ => Icons.construction_outlined,
    };

Color _kindColor(PlotKind k, DsTokens t) => switch (k) {
      PlotKind.water => t.teal,
      PlotKind.metals => FwPalette.rust600,
      PlotKind.biomass => t.success,
      PlotKind.energy => t.warning,
      PlotKind.factory => FwPalette.rust600,
      _ => t.textSecondary,
    };
