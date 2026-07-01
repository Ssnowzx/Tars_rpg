import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../app/theme/ds_colors.dart';
import '../../app/theme/ds_tokens.dart';
import '../../data/providers.dart';
import '../../domain/models/terraform.dart';

/// Terraformação Global (GDD §04 + §12.3): objetivo coletivo da temporada. Os
/// três indicadores públicos (atmosfera, ciclo hídrico, biosfera) avançam por
/// contribuição; ao alcançarem 75%, inicia-se a campanha lunar (gatilho da T2).
/// Contribuir só concede Status Cívico e cosméticos — nunca vantagem econômica.
/// Drill-in do Mapa (mantém HUD/nav).
class TerraformScreen extends ConsumerWidget {
  const TerraformScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = Theme.of(context).extension<DsTokens>()!;
    final state = ref.watch(terraformProvider);

    return ColoredBox(
      color: t.surfacePage,
      child: state.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => Center(
          child: TextButton.icon(
            onPressed: () => ref.invalidate(terraformProvider),
            icon: const Icon(Icons.refresh),
            label: const Text('Não foi possível carregar a Terraformação. Tocar para tentar de novo.'),
          ),
        ),
        data: (x) => Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const _Header(),
            Expanded(
              child: Align(
                alignment: Alignment.topCenter,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 900),
                  child: ListView(
                    padding: EdgeInsets.fromLTRB(t.space4, t.space2, t.space4, t.space6),
                    children: [
                      _OverviewCard(data: x),
                      SizedBox(height: t.space3),
                      _ContributionCard(data: x),
                      SizedBox(height: t.space3),
                      _GateCard(data: x),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).extension<DsTokens>()!;
    return Padding(
      padding: EdgeInsets.fromLTRB(t.space4, t.space4, t.space4, t.space2),
      child: Row(
        children: [
          InkWell(
            onTap: () => context.go('/map'),
            borderRadius: BorderRadius.circular(t.radiusSm),
            child: Padding(
              padding: const EdgeInsets.all(6),
              child: Icon(Icons.arrow_back, size: 20, color: t.textSecondary),
            ),
          ),
          SizedBox(width: t.space2),
          const Icon(Icons.public, size: 22, color: FwPalette.green600),
          SizedBox(width: t.space2),
          Text('Terraformação Global',
              style: GoogleFonts.rajdhani(fontWeight: FontWeight.w700, fontSize: 22, color: FwPalette.gray900)),
        ],
      ),
    );
  }
}

({Color color, IconData icon}) _trackMeta(TerraformIndicator k) => switch (k) {
      TerraformIndicator.atmosphere => (color: FwPalette.teal500, icon: Icons.cloud_outlined),
      TerraformIndicator.water => (color: FwPalette.teal700, icon: Icons.water_drop_outlined),
      TerraformIndicator.biosphere => (color: FwPalette.green600, icon: Icons.eco_outlined),
    };

// ── Visão coletiva ───────────────────────────────────────────────────────────

class _OverviewCard extends StatelessWidget {
  const _OverviewCard({required this.data});
  final TerraformState data;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).extension<DsTokens>()!;
    final scheme = Theme.of(context).colorScheme;
    final unlocked = data.season2Unlocked;
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
          Row(
            children: [
              Expanded(
                child: Text('Objetivo coletivo da temporada',
                    style: GoogleFonts.rajdhani(
                        fontWeight: FontWeight.w700, fontSize: 16, color: FwPalette.gray900)),
              ),
              if (data.orbitWindowActive) _Pill(label: 'Janela de Órbita Lunar', color: t.info, icon: Icons.radar),
            ],
          ),
          SizedBox(height: t.space1),
          Text(
            'Os três indicadores públicos precisam alcançar ${data.triggerPercent}% para disparar a '
            'campanha lunar (Temporada 2). O menor indicador determina o progresso.',
            style: TextStyle(fontSize: 12, height: 1.35, color: t.textSecondary),
          ),
          SizedBox(height: t.space3),
          for (final tr in data.tracks) ...[
            _TrackRow(track: tr, fraction: data.trackFraction(tr), trigger: data.triggerPercent),
            SizedBox(height: t.space3),
          ],
          Container(
            padding: EdgeInsets.symmetric(horizontal: t.space3, vertical: t.space2),
            decoration: BoxDecoration(
              color: (unlocked ? t.success : t.solar).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(t.radiusMd),
            ),
            child: Row(
              children: [
                Icon(unlocked ? Icons.lock_open_outlined : Icons.flag_outlined,
                    size: 16, color: unlocked ? t.success : t.solar),
                SizedBox(width: t.space2),
                Expanded(
                  child: Text(
                    unlocked
                        ? 'Marco de ${data.triggerPercent}% alcançado nos três indicadores — campanha lunar liberada.'
                        : 'Menor indicador em ${data.lowestPercent}% de ${data.triggerPercent}% — faltam '
                            '${data.triggerPercent - data.lowestPercent} pontos para o gatilho.',
                    style: TextStyle(
                        fontSize: 12, fontWeight: FontWeight.w600, color: unlocked ? t.success : FwPalette.gray800),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TrackRow extends StatelessWidget {
  const _TrackRow({required this.track, required this.fraction, required this.trigger});
  final TerraformTrack track;
  final double fraction;
  final int trigger;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).extension<DsTokens>()!;
    final meta = _trackMeta(track.kind);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(meta.icon, size: 16, color: meta.color),
            SizedBox(width: t.space2),
            Expanded(
              child: Text(track.label,
                  style: GoogleFonts.rajdhani(fontWeight: FontWeight.w700, fontSize: 13.5, color: FwPalette.gray900)),
            ),
            Text('${track.percent}% / $trigger%',
                style: GoogleFonts.rajdhani(fontWeight: FontWeight.w700, fontSize: 12.5, color: meta.color)),
          ],
        ),
        SizedBox(height: t.space1),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: fraction,
            minHeight: 7,
            backgroundColor: t.surfaceSunken,
            valueColor: AlwaysStoppedAnimation<Color>(meta.color),
          ),
        ),
        SizedBox(height: t.space1),
        Row(
          children: [
            Expanded(child: Text(track.note, style: TextStyle(fontSize: 11, height: 1.3, color: t.textSecondary))),
            SizedBox(width: t.space2),
            Text('+${track.perDay}%/dia', style: TextStyle(fontSize: 11, color: t.deltaUp)),
          ],
        ),
      ],
    );
  }
}

// ── Sua contribuição ─────────────────────────────────────────────────────────

class _ContributionCard extends StatelessWidget {
  const _ContributionCard({required this.data});
  final TerraformState data;

  void _contribute(BuildContext context) {
    final msg = data.dailyCapReached
        ? 'Limite diário de contribuição atingido (anti-farming, §04)'
        : 'Contribuir (+${data.civicStatusGain} Status Cívico) — em breve';
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), behavior: SnackBarBehavior.floating, duration: const Duration(seconds: 2)),
    );
  }

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
          Row(
            children: [
              Icon(Icons.volunteer_activism_outlined, size: 18, color: t.federation),
              SizedBox(width: t.space2),
              Expanded(
                child: Text('Sua contribuição',
                    style: GoogleFonts.rajdhani(
                        fontWeight: FontWeight.w700, fontSize: 15, color: FwPalette.gray900)),
              ),
              _Pill(label: 'Top ${data.contributorTopPct}%', color: t.solar, icon: Icons.emoji_events_outlined),
            ],
          ),
          SizedBox(height: t.space3),
          Row(
            children: [
              Expanded(child: Text('Contribuição de hoje (limite anti-farming)',
                  style: TextStyle(fontSize: 12, color: t.textSecondary))),
              Text('${data.dailyContributed}/${data.dailyCap}',
                  style: GoogleFonts.rajdhani(fontWeight: FontWeight.w700, fontSize: 12.5, color: t.federation)),
            ],
          ),
          SizedBox(height: t.space1),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: data.dailyFraction,
              minHeight: 7,
              backgroundColor: t.surfaceSunken,
              valueColor: AlwaysStoppedAnimation<Color>(t.federation),
            ),
          ),
          SizedBox(height: t.space3),
          Row(
            children: [
              Expanded(child: _StatBox(label: 'Total contribuído', value: '${data.totalContributed}', color: t.info)),
              SizedBox(width: t.space2),
              Expanded(child: _StatBox(label: 'Recompensa', value: '+${data.civicStatusGain} Status Cívico', color: t.federation)),
            ],
          ),
          SizedBox(height: t.space3),
          FilledButton.icon(
            onPressed: () => _contribute(context),
            icon: Icon(data.dailyCapReached ? Icons.hourglass_bottom : Icons.add, size: 18),
            label: Text(data.dailyCapReached ? 'Limite diário atingido' : 'Contribuir'),
            style: FilledButton.styleFrom(
              backgroundColor: data.dailyCapReached ? t.surfaceSunken : FwPalette.green600,
              foregroundColor: data.dailyCapReached ? t.textSecondary : Colors.white,
              minimumSize: Size(0, t.controlLg),
            ),
          ),
          SizedBox(height: t.space2),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.info_outline, size: 13, color: t.textSecondary),
              SizedBox(width: t.space1),
              Expanded(
                child: Text(
                  'Contribuir concede apenas Status Cívico e recompensas cosméticas/contratuais — '
                  'nunca vantagem econômica ou competitiva (§04).',
                  style: TextStyle(fontSize: 11, color: t.textSecondary, height: 1.3),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatBox extends StatelessWidget {
  const _StatBox({required this.label, required this.value, required this.color});
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).extension<DsTokens>()!;
    return Container(
      padding: EdgeInsets.all(t.space3),
      decoration: BoxDecoration(
        color: t.surfaceSunken,
        borderRadius: BorderRadius.circular(t.radiusMd),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: GoogleFonts.rajdhani(
                  fontWeight: FontWeight.w700, fontSize: 10, letterSpacing: 0.4, color: t.textSecondary)),
          SizedBox(height: t.space1),
          Text(value,
              style: GoogleFonts.rajdhani(fontWeight: FontWeight.w700, fontSize: 15, color: color)),
        ],
      ),
    );
  }
}

// ── Gatilho da Temporada 2 ───────────────────────────────────────────────────

class _GateCard extends StatelessWidget {
  const _GateCard({required this.data});
  final TerraformState data;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).extension<DsTokens>()!;
    final scheme = Theme.of(context).colorScheme;
    final unlocked = data.season2Unlocked;
    final color = unlocked ? t.success : t.solar;
    return Container(
      padding: EdgeInsets.all(t.space4),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(t.radiusCard),
        border: Border.all(color: color.withValues(alpha: 0.45)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.rocket_launch_outlined, size: 20, color: color),
              SizedBox(width: t.space2),
              Expanded(
                child: Text('Gatilho da Temporada 2',
                    style: GoogleFonts.rajdhani(
                        fontWeight: FontWeight.w700, fontSize: 16, color: FwPalette.gray900)),
              ),
              _Pill(label: unlocked ? 'Alcançado' : 'Em progresso', color: color, icon: Icons.public_outlined),
            ],
          ),
          SizedBox(height: t.space2),
          Text(
            'Ao alcançar ${data.triggerPercent}% nos três indicadores, inicia-se a campanha pública '
            '"Janela de Órbita Lunar" e o gatilho oficial da Temporada 2 (§12.3). A liberação depende '
            'de conteúdo pronto e GDD complementar aprovado — não é automática.',
            style: TextStyle(fontSize: 12, height: 1.35, color: t.textSecondary),
          ),
          SizedBox(height: t.space3),
          OutlinedButton.icon(
            onPressed: () => context.go('/spaceport/lunar'),
            icon: const Icon(Icons.travel_explore, size: 18),
            label: const Text('Ver Exploração Lunar'),
            style: OutlinedButton.styleFrom(
              foregroundColor: FwPalette.gray800,
              side: BorderSide(color: t.borderDefault),
              minimumSize: Size(0, t.controlMd),
            ),
          ),
        ],
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.label, required this.color, this.icon});
  final String label;
  final Color color;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[Icon(icon, size: 11, color: color), const SizedBox(width: 4)],
          Text(label, style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w600, color: color)),
        ],
      ),
    );
  }
}
