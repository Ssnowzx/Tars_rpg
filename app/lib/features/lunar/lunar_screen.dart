import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../app/theme/ds_colors.dart';
import '../../app/theme/ds_tokens.dart';
import '../../data/providers.dart';
import '../../domain/models/lunar.dart';
import '../market/resource_visual.dart';

/// Exploração Lunar / Telescópio Gagarin (GDD §12 + §28.1–28.2). Fundação
/// narrativa da Temporada 2: status do satélite Gagarin, boletins das 8 luas,
/// catálogo lua↔recurso raro e gatilhos (ativação do Gagarin e marco de 75%
/// de terraformação). As bases lunares em si ficam bloqueadas até a T2 (§12.4).
/// Drill-in do Espaçoporto (mantém HUD/nav).
class LunarScreen extends ConsumerWidget {
  const LunarScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = Theme.of(context).extension<DsTokens>()!;
    final lunar = ref.watch(lunarProvider);

    return ColoredBox(
      color: t.surfacePage,
      child: lunar.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => Center(
          child: TextButton.icon(
            onPressed: () => ref.invalidate(lunarProvider),
            icon: const Icon(Icons.refresh),
            label: const Text('Não foi possível carregar a Exploração Lunar. Tocar para tentar de novo.'),
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
                      _GagarinCard(data: x),
                      SizedBox(height: t.space3),
                      _MilestoneCard(data: x),
                      _SectionTitle(
                        icon: Icons.feed_outlined,
                        title: 'Boletins do Gagarin',
                        subtitle: 'Publicados na Central de Pesquisas e Notícias ${x.bulletinFrequency}.',
                      ),
                      if (x.bulletins.isEmpty)
                        Text('Sem boletins no momento.', style: TextStyle(fontSize: 12.5, color: t.textSecondary))
                      else
                        for (final b in x.bulletins) _BulletinCard(bulletin: b),
                      const _SectionTitle(
                        icon: Icons.brightness_3_outlined,
                        title: 'As 8 Luas de Fertways',
                        subtitle: 'Homenagens a pioneiros da exploração espacial. Cada lua guarda um recurso raro, '
                            'explorável apenas na Temporada 2.',
                      ),
                      for (final m in x.moons) _MoonCard(moon: m),
                      SizedBox(height: t.space2),
                      _Season2LockCard(data: x),
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
            onTap: () => context.go('/spaceport'),
            borderRadius: BorderRadius.circular(t.radiusSm),
            child: Padding(
              padding: const EdgeInsets.all(6),
              child: Icon(Icons.arrow_back, size: 20, color: t.textSecondary),
            ),
          ),
          SizedBox(width: t.space2),
          const Icon(Icons.travel_explore, size: 22, color: FwPalette.solar600),
          SizedBox(width: t.space2),
          Text('Exploração Lunar',
              style: GoogleFonts.rajdhani(fontWeight: FontWeight.w700, fontSize: 22, color: FwPalette.gray900)),
        ],
      ),
    );
  }
}

// ── Telescópio Gagarin ───────────────────────────────────────────────────────

class _GagarinCard extends StatelessWidget {
  const _GagarinCard({required this.data});
  final LunarExploration data;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).extension<DsTokens>()!;
    final scheme = Theme.of(context).colorScheme;
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
                      colors: [FwPalette.teal500, FwPalette.purple600],
                    ),
                    borderRadius: BorderRadius.circular(t.radiusMd),
                  ),
                  child: const Icon(Icons.satellite_alt_outlined, color: Colors.white, size: 24),
                ),
                SizedBox(width: t.space3),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Telescópio Orbital Gagarin',
                          style: GoogleFonts.rajdhani(
                              fontWeight: FontWeight.w700, fontSize: 18, color: FwPalette.gray900)),
                      Text('Satélite do Governo · homenagem a Yuri Gagarin',
                          style: TextStyle(fontSize: 12, color: t.textSecondary)),
                    ],
                  ),
                ),
                _Pill(
                  label: data.gagarinActive ? 'Ativo' : 'Inativo',
                  color: data.gagarinActive ? t.success : t.textSecondary,
                  icon: data.gagarinActive ? Icons.sensors : Icons.sensors_off,
                ),
              ],
            ),
            SizedBox(height: t.space3),
            _ProgressRow(
              label: 'Gatilho de ativação — 50 jogadores OU 45 dias',
              value: data.activationFraction,
              trailing: '${data.playersRegistered}/${data.playersTrigger} jog. · dia ${data.daysElapsed}/${data.daysTrigger}',
              color: t.info,
            ),
            SizedBox(height: t.space3),
            const _KV(label: 'Proprietário', value: 'Governo de Fertways · não vendável'),
            _KV(label: 'Frequência de boletins', value: data.bulletinFrequency),
            const _KV(label: 'Canal', value: 'Central de Pesquisas e Notícias'),
            SizedBox(height: t.space2),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.info_outline, size: 13, color: t.textSecondary),
                SizedBox(width: t.space1),
                Expanded(
                  child: Text(
                    'Opera em órbita baixa de Fertways — não repousa no casco da Endurance (§28.1). '
                    'Observa as 8 luas e envia dados à Central de Pesquisas.',
                    style: TextStyle(fontSize: 11, color: t.textSecondary, height: 1.3),
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

// ── Preparativos T1 / marco de terraformação ────────────────────────────────

class _MilestoneCard extends StatelessWidget {
  const _MilestoneCard({required this.data});
  final LunarExploration data;

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
              Icon(Icons.public_outlined, size: 18, color: t.teal),
              SizedBox(width: t.space2),
              Expanded(
                child: Text('Preparativos da Temporada 1',
                    style: GoogleFonts.rajdhani(
                        fontWeight: FontWeight.w700, fontSize: 15, color: FwPalette.gray900)),
              ),
              if (data.orbitWindowActive) _Pill(label: 'Janela de Órbita Lunar', color: t.info, icon: Icons.radar),
            ],
          ),
          SizedBox(height: t.space3),
          _ProgressRow(
            label: 'Terraformação global — gatilho da Temporada 2',
            value: data.terraformFraction,
            trailing: '${data.terraformPercent}% / ${data.terraformTrigger}%',
            color: unlocked ? t.success : t.solar,
          ),
          SizedBox(height: t.space2),
          Text(
            unlocked
                ? 'Marco de ${data.terraformTrigger}% alcançado — a exploração lunar da Temporada 2 pode ser aberta por GDD complementar aprovado.'
                : 'Ao alcançar ${data.terraformTrigger}% nos três indicadores (atmosfera, ciclo hídrico e biosfera), '
                    'inicia-se a campanha "Janela de Órbita Lunar" e o gatilho oficial da Temporada 2 (§12.3).',
            style: TextStyle(fontSize: 12, height: 1.35, color: t.textSecondary),
          ),
        ],
      ),
    );
  }
}

// ── Boletins ─────────────────────────────────────────────────────────────────

({Color color, IconData icon, String label}) _bulletinMeta(BulletinKind k, DsTokens t) => switch (k) {
      BulletinKind.atmosphere => (color: t.teal, icon: Icons.cloud_outlined, label: 'Atmosfera'),
      BulletinKind.resource => (color: t.solar, icon: Icons.diamond_outlined, label: 'Recurso'),
      BulletinKind.anomaly => (color: t.federation, icon: Icons.warning_amber_outlined, label: 'Anomalia'),
      BulletinKind.moon => (color: t.info, icon: Icons.travel_explore, label: 'Lua'),
    };

class _BulletinCard extends StatelessWidget {
  const _BulletinCard({required this.bulletin});
  final GagarinBulletin bulletin;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).extension<DsTokens>()!;
    final scheme = Theme.of(context).colorScheme;
    final meta = _bulletinMeta(bulletin.kind, t);
    return Container(
      margin: EdgeInsets.only(bottom: t.space2),
      padding: EdgeInsets.all(t.space3),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(t.radiusCard),
        border: Border(
          left: BorderSide(color: meta.color, width: 3),
          top: BorderSide(color: t.borderDefault),
          right: BorderSide(color: t.borderDefault),
          bottom: BorderSide(color: t.borderDefault),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _Pill(label: meta.label, color: meta.color, icon: meta.icon),
              SizedBox(width: t.space2),
              Text(bulletin.cycle,
                  style: GoogleFonts.rajdhani(fontWeight: FontWeight.w700, fontSize: 12, color: t.textSecondary)),
              const Spacer(),
              Text(bulletin.time, style: TextStyle(fontSize: 11, color: t.textSecondary)),
            ],
          ),
          SizedBox(height: t.space2),
          Text(bulletin.title,
              style: GoogleFonts.rajdhani(fontWeight: FontWeight.w700, fontSize: 15, color: FwPalette.gray900)),
          SizedBox(height: t.space1),
          Text(bulletin.body, style: TextStyle(fontSize: 12.5, height: 1.35, color: t.textSecondary)),
        ],
      ),
    );
  }
}

// ── Luas ─────────────────────────────────────────────────────────────────────

({Color color, IconData icon, String label}) _atmMeta(MoonAtmosphere a, DsTokens t) => switch (a) {
      MoonAtmosphere.similar => (color: t.success, icon: Icons.check_circle_outline, label: 'Atmosfera similar'),
      MoonAtmosphere.none => (color: t.textSecondary, icon: Icons.block_outlined, label: 'Sem atmosfera'),
      MoonAtmosphere.toxic => (color: t.warning, icon: Icons.warning_amber_outlined, label: 'Atmosfera tóxica'),
    };

class _MoonCard extends StatelessWidget {
  const _MoonCard({required this.moon});
  final Moon moon;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).extension<DsTokens>()!;
    final scheme = Theme.of(context).colorScheme;
    final atm = _atmMeta(moon.atmosphere, t);
    final resColor = resourceColor(moon.rareResourceId);
    return Container(
      margin: EdgeInsets.only(bottom: t.space3),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(t.radiusCard),
        border: Border.all(color: moon.mystery ? t.federation.withValues(alpha: 0.5) : t.borderDefault),
      ),
      child: Padding(
        padding: EdgeInsets.all(t.space4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [FwPalette.gray300, resColor],
                    ),
                    borderRadius: BorderRadius.circular(t.radiusMd),
                  ),
                  child: Icon(moon.mystery ? Icons.help_outline : Icons.brightness_2_outlined,
                      color: Colors.white, size: 22),
                ),
                SizedBox(width: t.space3),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(moon.name,
                          style: GoogleFonts.rajdhani(
                              fontWeight: FontWeight.w700, fontSize: 17, color: FwPalette.gray900)),
                      Text(moon.honoree,
                          style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: FwPalette.gray800)),
                      Text(moon.honoreeNote, style: TextStyle(fontSize: 11, color: t.textSecondary)),
                    ],
                  ),
                ),
                _Pill(label: atm.label, color: atm.color, icon: atm.icon),
              ],
            ),
            SizedBox(height: t.space3),
            Container(
              padding: EdgeInsets.symmetric(horizontal: t.space3, vertical: t.space2),
              decoration: BoxDecoration(
                color: resColor.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(t.radiusMd),
                border: Border.all(color: resColor.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  Icon(resourceIcon(moon.rareResourceId), size: 16, color: resColor),
                  SizedBox(width: t.space2),
                  Text('Recurso raro', style: TextStyle(fontSize: 11, color: t.textSecondary)),
                  SizedBox(width: t.space2),
                  Expanded(
                    child: Text(moon.rareResource,
                        textAlign: TextAlign.right,
                        style: GoogleFonts.rajdhani(fontWeight: FontWeight.w700, fontSize: 13.5, color: resColor)),
                  ),
                ],
              ),
            ),
            SizedBox(height: t.space2),
            Text(moon.profile, style: const TextStyle(fontSize: 12.5, height: 1.35, color: FwPalette.gray800)),
            SizedBox(height: t.space2),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.lock_clock_outlined, size: 13, color: t.textSecondary),
                SizedBox(width: t.space1),
                Expanded(
                  child: Text('Temporada 2: ${moon.t2Reading}',
                      style: TextStyle(fontSize: 11.5, fontStyle: FontStyle.italic, color: t.textSecondary)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ── Prévia bloqueada da Temporada 2 ─────────────────────────────────────────

class _Season2LockCard extends StatelessWidget {
  const _Season2LockCard({required this.data});
  final LunarExploration data;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).extension<DsTokens>()!;
    final scheme = Theme.of(context).colorScheme;
    final unlocked = data.season2Unlocked;
    final color = unlocked ? t.success : t.solar;
    const bullets = [
      'Bases lunares — individual, de federação, de grupo de federações ou do governo',
      'Slots de estrutura — silos, armazéns, geradores e suporte à vida',
      'Slots de mineração — ocupados ou alugados a jogadores neutros',
      'Terceirização — alugar slots de mineração viabiliza manter a base',
      'Ataques e guerras lunares — regras próprias da Temporada 2',
    ];
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
              Icon(unlocked ? Icons.lock_open_outlined : Icons.lock_outline, size: 20, color: color),
              SizedBox(width: t.space2),
              Expanded(
                child: Text('Bases Lunares — Temporada 2',
                    style: GoogleFonts.rajdhani(
                        fontWeight: FontWeight.w700, fontSize: 16, color: FwPalette.gray900)),
              ),
              _Pill(label: unlocked ? 'Desbloqueável' : 'Bloqueado', color: color, icon: Icons.brightness_2_outlined),
            ],
          ),
          SizedBox(height: t.space2),
          Text(
            'Prévia de design. As bases lunares só entram quando custos, defesa, abandono, propriedade, transporte '
            'e combate lunar estiverem fechados em GDD complementar aprovado (§12.4).',
            style: TextStyle(fontSize: 12, height: 1.35, color: t.textSecondary),
          ),
          SizedBox(height: t.space3),
          for (final b in bullets)
            Padding(
              padding: EdgeInsets.only(bottom: t.space2),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.chevron_right, size: 15, color: color),
                  SizedBox(width: t.space1),
                  Expanded(child: Text(b, style: const TextStyle(fontSize: 12.5, height: 1.3, color: FwPalette.gray800))),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

// ── Widgets compartilhados desta tela ───────────────────────────────────────

class _ProgressRow extends StatelessWidget {
  const _ProgressRow({required this.label, required this.value, required this.trailing, required this.color});
  final String label;
  final double value;
  final String trailing;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).extension<DsTokens>()!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(label,
                  style: GoogleFonts.rajdhani(fontWeight: FontWeight.w700, fontSize: 12.5, color: FwPalette.gray800)),
            ),
            SizedBox(width: t.space2),
            Text(trailing, style: GoogleFonts.rajdhani(fontWeight: FontWeight.w700, fontSize: 12, color: color)),
          ],
        ),
        SizedBox(height: t.space2),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: value,
            minHeight: 7,
            backgroundColor: t.surfaceSunken,
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }
}

class _KV extends StatelessWidget {
  const _KV({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).extension<DsTokens>()!;
    return Padding(
      padding: EdgeInsets.symmetric(vertical: t.space1),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 132,
            child: Text(label, style: TextStyle(fontSize: 12, color: t.textSecondary)),
          ),
          Expanded(
            child: Text(value,
                style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: FwPalette.gray800)),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.icon, required this.title, this.subtitle = ''});
  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).extension<DsTokens>()!;
    return Padding(
      padding: EdgeInsets.only(top: t.space4, bottom: t.space2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: FwPalette.solar600),
              SizedBox(width: t.space2),
              Text(title,
                  style: GoogleFonts.rajdhani(fontWeight: FontWeight.w700, fontSize: 16, color: FwPalette.gray900)),
            ],
          ),
          if (subtitle.isNotEmpty) ...[
            SizedBox(height: t.space1),
            Text(subtitle, style: TextStyle(fontSize: 12, height: 1.3, color: t.textSecondary)),
          ],
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
