import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../app/theme/ds_colors.dart';
import '../../app/theme/ds_tokens.dart';
import '../../data/providers.dart';
import '../../domain/models/institution_slot.dart';
import '../../l10n/app_localizations.dart';
import 'category_meta.dart';

/// Capital — grid dos 20 slots de instituição (GDD §2.1), estilo Solar Frontier.
class CapitalScreen extends ConsumerWidget {
  const CapitalScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final t = Theme.of(context).extension<DsTokens>()!;
    final slots = ref.watch(slotsProvider);

    return ColoredBox(
      color: t.surfacePage,
      child: slots.when(
        loading: () => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(),
              SizedBox(height: t.space3),
              Text(l10n.stateLoading, style: TextStyle(color: t.textSecondary)),
            ],
          ),
        ),
        error: (_, __) => Center(
          child: TextButton.icon(
            onPressed: () => ref.invalidate(slotsProvider),
            icon: const Icon(Icons.refresh),
            label: Text(l10n.stateError),
          ),
        ),
        data: (data) => _CapitalBody(slots: data),
      ),
    );
  }
}

class _CapitalBody extends StatelessWidget {
  const _CapitalBody({required this.slots});
  final List<InstitutionSlot> slots;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).extension<DsTokens>()!;
    final l10n = AppLocalizations.of(context);
    final installed = slots.where((s) => s.installed).length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(t.space6, t.space4, t.space6, t.space2),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(t.radiusMd),
                  gradient: const LinearGradient(colors: [FwPalette.rust600, FwPalette.solar500]),
                ),
                child: const Icon(Icons.account_balance, color: Colors.white, size: 22),
              ),
              SizedBox(width: t.space3),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l10n.capitalTitle,
                      style: GoogleFonts.rajdhani(
                          fontWeight: FontWeight.w700, fontSize: 22, color: FwPalette.gray900, height: 1)),
                  Text(l10n.capitalSlotsSummary(installed, slots.length),
                      style: TextStyle(fontSize: 12.5, color: t.textSecondary)),
                ],
              ),
            ],
          ),
        ),
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final columns = (constraints.maxWidth / 230).floor().clamp(2, 6);
              return GridView.builder(
                padding: EdgeInsets.all(t.space6),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: columns,
                  mainAxisSpacing: t.space4,
                  crossAxisSpacing: t.space4,
                  childAspectRatio: 1.5,
                ),
                itemCount: slots.length,
                itemBuilder: (context, i) => _SlotCard(slot: slots[i]),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _SlotCard extends StatelessWidget {
  const _SlotCard({required this.slot});
  final InstitutionSlot slot;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).extension<DsTokens>()!;
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    final meta = categoryMeta(slot.category, t);

    if (slot.isEmpty) {
      return Semantics(
        button: true,
        label: '${l10n.capitalEmptySlot} ${slot.index}',
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: t.surfaceSunken,
            borderRadius: BorderRadius.circular(t.radiusCard),
            border: Border.all(color: t.borderStrong, width: 1),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.add_circle_outline, color: t.textSecondary, size: 26),
              SizedBox(height: t.space2),
              Text(l10n.capitalEmptySlot, style: TextStyle(color: t.textSecondary, fontSize: 12)),
              SizedBox(height: t.space1),
              Text(l10n.capitalBuildAction,
                  style: textTheme.labelMedium?.copyWith(color: FwPalette.rust600, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      );
    }

    return InkWell(
      onTap: () => _onTap(context),
      borderRadius: BorderRadius.circular(t.radiusCard),
      child: Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(t.radiusCard),
        border: Border.all(color: t.borderDefault),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 4,
            decoration: BoxDecoration(
              color: meta.color,
              borderRadius: BorderRadius.vertical(top: Radius.circular(t.radiusCard)),
            ),
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(t.space3),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          color: meta.color.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(t.radiusSm),
                        ),
                        child: Icon(meta.icon, size: 17, color: meta.color),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(
                          color: t.surfaceSunken,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text('Nv ${slot.level}',
                            style: GoogleFonts.rajdhani(
                                fontWeight: FontWeight.w700, fontSize: 11, color: FwPalette.gray700)),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Text(slot.name ?? '',
                      style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis),
                  SizedBox(height: t.space1),
                  Text(meta.label, style: textTheme.labelSmall?.copyWith(color: meta.color)),
                ],
              ),
            ),
          ),
        ],
      ),
      ),
    );
  }

  void _onTap(BuildContext context) {
    context.go('/capital/ministry', extra: slot);
  }
}

