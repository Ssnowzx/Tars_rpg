import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../app/theme/ds_colors.dart';
import '../../app/theme/ds_tokens.dart';
import '../../data/providers.dart';
import '../../domain/models/war_ranking.dart';

/// Ranking de Guerras (GDD §15): Ranking Geral (pesos §15.3) + 6 sub-rankings
/// (§15.2). Alcançado pelo Ministério da Segurança e Guerra (Capital).
class RankingsScreen extends ConsumerStatefulWidget {
  const RankingsScreen({super.key});

  @override
  ConsumerState<RankingsScreen> createState() => _RankingsScreenState();
}

class _RankingsScreenState extends ConsumerState<RankingsScreen> {
  int _tab = 0; // 0 = Geral, 1..6 = subs

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).extension<DsTokens>()!;
    final rankings = ref.watch(warRankingsProvider);

    return rankings.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, __) => Center(
        child: TextButton.icon(
          onPressed: () => ref.invalidate(warRankingsProvider),
          icon: const Icon(Icons.refresh),
          label: const Text('Não foi possível carregar o ranking. Tocar para tentar de novo.'),
        ),
      ),
      data: (w) {
        final tabs = ['Geral', ...w.subs.map((s) => s.name)];
        final isGeneral = _tab == 0;
        final sub = isGeneral ? null : w.subs[_tab - 1];
        final entries = isGeneral ? w.general : sub!.entries;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: EdgeInsets.fromLTRB(t.space4, t.space4, t.space4, t.space2),
              child: Row(
                children: [
                  InkWell(
                    onTap: () => context.go('/capital'),
                    borderRadius: BorderRadius.circular(t.radiusSm),
                    child: const Padding(padding: EdgeInsets.all(6), child: Icon(Icons.arrow_back, size: 20)),
                  ),
                  SizedBox(width: t.space2),
                  const Icon(Icons.military_tech_outlined, size: 22, color: FwPalette.red600),
                  SizedBox(width: t.space2),
                  Text('Ranking de Guerras',
                      style: GoogleFonts.rajdhani(fontWeight: FontWeight.w700, fontSize: 22, color: FwPalette.gray900)),
                ],
              ),
            ),
            // Seletor de rankings
            SizedBox(
              height: 44,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(horizontal: t.space4),
                itemCount: tabs.length,
                separatorBuilder: (_, __) => SizedBox(width: t.space2),
                itemBuilder: (_, i) => ChoiceChip(
                  label: Text(tabs[i]),
                  selected: _tab == i,
                  onSelected: (_) => setState(() => _tab = i),
                ),
              ),
            ),
            SizedBox(height: t.space2),
            Expanded(
              child: ListView(
                padding: EdgeInsets.fromLTRB(t.space4, 0, t.space4, t.space4),
                children: [
                  if (isGeneral) _GeneralHeader(weights: w.weights) else _SubHeader(sub: sub!),
                  SizedBox(height: t.space3),
                  for (final e in entries) Padding(
                    padding: EdgeInsets.only(bottom: t.space2),
                    child: _EntryRow(entry: e, isGeneral: isGeneral),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class _GeneralHeader extends StatelessWidget {
  const _GeneralHeader({required this.weights});
  final List<GeneralWeight> weights;
  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).extension<DsTokens>()!;
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: EdgeInsets.all(t.space4),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(t.radiusCard),
        border: Border.all(color: t.borderDefault),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('RANKING GERAL · PESOS (ESCALA 0–100)',
              style: GoogleFonts.rajdhani(
                  fontWeight: FontWeight.w700, fontSize: 12, letterSpacing: 1.2, color: FwPalette.gray500)),
          SizedBox(height: t.space1),
          Text('Cada métrica vira percentil no servidor (0–100); o geral é a soma ponderada desses '
              'percentis — então os pesos abaixo importam de verdade (§27.13).',
              style: TextStyle(fontSize: 12, color: t.textSecondary)),
          SizedBox(height: t.space2),
          Container(
            padding: EdgeInsets.symmetric(horizontal: t.space3, vertical: t.space2),
            decoration: BoxDecoration(
              color: t.surfaceSunken,
              borderRadius: BorderRadius.circular(t.radiusMd),
            ),
            child: Text('Ex.: 5 vitórias com máx. 200 no servidor → percentil 2,5 → × 20% = 0,5 ponto.',
                style: TextStyle(fontSize: 11.5, color: t.textSecondary)),
          ),
          SizedBox(height: t.space3),
          Wrap(
            spacing: t.space2,
            runSpacing: t.space2,
            children: [
              for (final wt in weights)
                Container(
                  padding: EdgeInsets.symmetric(horizontal: t.space3, vertical: t.space2),
                  decoration: BoxDecoration(
                    color: t.surfaceSunken,
                    borderRadius: BorderRadius.circular(t.radiusMd),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('${wt.weight}%',
                          style: GoogleFonts.rajdhani(
                              fontWeight: FontWeight.w700, fontSize: 14, color: FwPalette.rust600)),
                      SizedBox(width: t.space2),
                      Text(wt.metric, style: const TextStyle(fontSize: 12, color: FwPalette.gray800)),
                    ],
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SubHeader extends StatelessWidget {
  const _SubHeader({required this.sub});
  final SubRanking sub;
  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).extension<DsTokens>()!;
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: EdgeInsets.all(t.space4),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(t.radiusCard),
        border: Border.all(color: t.borderDefault),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(sub.measures, style: const TextStyle(fontSize: 13, color: FwPalette.gray800)),
          SizedBox(height: t.space2),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(color: t.surfaceSunken, borderRadius: BorderRadius.circular(6)),
                child: Text(sub.scope, style: TextStyle(fontSize: 11, color: t.textSecondary)),
              ),
              SizedBox(width: t.space2),
              Icon(Icons.leaderboard_outlined, size: 13, color: t.textSecondary),
              SizedBox(width: t.space1),
              Text('ranqueado por percentil no servidor (§27.13)',
                  style: TextStyle(fontSize: 11, color: t.textSecondary)),
            ],
          ),
        ],
      ),
    );
  }
}

class _EntryRow extends StatelessWidget {
  const _EntryRow({required this.entry, this.isGeneral = false});
  final RankingEntry entry;
  final bool isGeneral;

  Color _rankColor(int r) => switch (r) {
        1 => FwPalette.solar500,
        2 => FwPalette.gray400,
        3 => FwPalette.rust300,
        _ => FwPalette.gray300,
      };

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).extension<DsTokens>()!;
    final scheme = Theme.of(context).colorScheme;
    final you = entry.isYou;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: t.space3, vertical: t.space3),
      decoration: BoxDecoration(
        color: you ? FwPalette.rust50 : scheme.surface,
        borderRadius: BorderRadius.circular(t.radiusMd),
        border: Border.all(color: you ? FwPalette.rust200 : t.borderDefault),
      ),
      child: Row(
        children: [
          Container(
            width: 30,
            height: 30,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: _rankColor(entry.rank).withValues(alpha: entry.rank <= 3 ? 0.2 : 0.12),
              shape: BoxShape.circle,
            ),
            child: Text('${entry.rank}',
                style: GoogleFonts.rajdhani(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: entry.rank <= 3 ? FwPalette.gray900 : FwPalette.gray600)),
          ),
          SizedBox(width: t.space3),
          Icon(entry.federation ? Icons.groups_outlined : Icons.person_outline,
              size: 16, color: entry.federation ? FwPalette.purple600 : t.textSecondary),
          SizedBox(width: t.space2),
          Expanded(
            child: Row(
              children: [
                Flexible(
                  child: Text(entry.name,
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: FwPalette.gray900),
                      overflow: TextOverflow.ellipsis),
                ),
                if (you) ...[
                  SizedBox(width: t.space2),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                    decoration: BoxDecoration(color: FwPalette.rust600, borderRadius: BorderRadius.circular(5)),
                    child: const Text('VOCÊ',
                        style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: Colors.white)),
                  ),
                ],
              ],
            ),
          ),
          SizedBox(width: t.space2),
          if (isGeneral)
            Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(entry.value,
                    style: GoogleFonts.rajdhani(
                        fontWeight: FontWeight.w700, fontSize: 16, color: FwPalette.gray900)),
                Text(' /100', style: TextStyle(fontSize: 10, color: t.textSecondary)),
              ],
            )
          else
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(entry.value,
                    style: GoogleFonts.rajdhani(
                        fontWeight: FontWeight.w700, fontSize: 15, color: FwPalette.gray900)),
                if (entry.percentile != null) ...[
                  const SizedBox(height: 2),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                    decoration: BoxDecoration(
                      color: t.surfaceSunken,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text('percentil ${entry.percentile!.round()}',
                        style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w600, color: t.textSecondary)),
                  ),
                ],
              ],
            ),
        ],
      ),
    );
  }
}
