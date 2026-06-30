import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../app/theme/ds_colors.dart';
import '../../app/theme/ds_tokens.dart';
import '../../data/providers.dart';
import '../../domain/models/combat.dart';
import '../../domain/models/planet_models.dart';
import '../world_map/game/fertways_world_game.dart' show zoneResourceColor, zoneResourceIcon;

String _resourceLabel(ZoneResource k) => switch (k) {
      ZoneResource.water => 'Água',
      ZoneResource.metals => 'Metais Ferrosos',
      ZoneResource.biomass => 'Biomassa',
      ZoneResource.energy => 'Energia',
      ZoneResource.components => 'Componentes',
      ZoneResource.none => 'Recurso',
    };

/// Estrutura construível numa zona neutra (GDD v21 §17.4).
class _Structure {
  const _Structure(this.name, this.icon, this.level, this.desc, {this.max = 0});
  final String name;
  final IconData icon;
  final int level; // 0 = a construir
  final String desc;
  final int max; // >0 mostra "Nv x/max"
}

/// Tela de uma Zona Neutra: ocupar (Robôs Mineradores) → extrair (depósito 10
/// níveis) → transportar (4 destinos). Estruturas do §17.4. Tudo mock.
class ZoneScreen extends StatelessWidget {
  const ZoneScreen({super.key, required this.zone});

  final MapNode? zone;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).extension<DsTokens>()!;
    if (zone == null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.travel_explore_outlined, size: 40, color: t.textSecondary),
            SizedBox(height: t.space3),
            const Text('Selecione uma zona neutra no mapa.'),
            SizedBox(height: t.space3),
            FilledButton.icon(
              onPressed: () => context.go('/map'),
              icon: const Icon(Icons.map_outlined, size: 18),
              label: const Text('Ir ao mapa'),
              style: FilledButton.styleFrom(backgroundColor: FwPalette.rust600),
            ),
          ],
        ),
      );
    }

    final z = zone!;
    final color = zoneResourceColor(z.resource);
    final robosNeeded = 20 + z.level * 20; // §16: varia por nível (20–150+)
    final deposit = z.level.clamp(0, 10);

    final structures = <_Structure>[
      const _Structure('Posto de Comando', Icons.flag_outlined, 1, 'Controle territorial da zona — primeira estrutura.'),
      _Structure('Depósito de Recursos', Icons.inventory_2_outlined, deposit, 'Armazena o extraído. Quando lota, a extração para.', max: 10),
      _Structure('Estrutura de Extração', zoneResourceIcon(z.resource), 2, 'Perfuratriz/escavadeira conforme o recurso.'),
      const _Structure('Abrigo de Robôs', Icons.precision_manufacturing_outlined, 1, 'Onde os Robôs Mineradores se recuperam.'),
      const _Structure('Muralha de Perímetro', Icons.security_outlined, 0, 'Dificulta a Invasão Direta. Upgrades = mais defesa.'),
      const _Structure('Torre de Vigia', Icons.visibility_outlined, 0, 'Detecta inimigos antes do ataque.'),
      const _Structure('Refinaria de Campo', Icons.science_outlined, 0, 'Primário → secundário na zona, antes do transporte.'),
    ];

    const destinos = [
      ('Mercado', Icons.storefront_outlined),
      ('Slot', Icons.home_work_outlined),
      ('Jogador', Icons.person_outline),
      ('Federação', Icons.groups_outlined),
    ];

    void toast(String m) => ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(m), behavior: SnackBarBehavior.floating, duration: const Duration(seconds: 2)),
        );

    return ListView(
      padding: EdgeInsets.all(t.space4),
      children: [
        // Header
        Row(
          children: [
            InkWell(
              onTap: () => context.go('/map'),
              borderRadius: BorderRadius.circular(t.radiusSm),
              child: const Padding(padding: EdgeInsets.all(6), child: Icon(Icons.arrow_back, size: 20)),
            ),
            SizedBox(width: t.space2),
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(color: color.withValues(alpha: 0.14), borderRadius: BorderRadius.circular(t.radiusMd)),
              child: Icon(zoneResourceIcon(z.resource), color: color, size: 24),
            ),
            SizedBox(width: t.space3),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(z.name,
                      style: GoogleFonts.rajdhani(fontWeight: FontWeight.w700, fontSize: 20, color: FwPalette.gray900)),
                  Text('Zona neutra · ${_resourceLabel(z.resource)}',
                      style: TextStyle(fontSize: 12.5, color: t.textSecondary)),
                ],
              ),
            ),
            _StatusChip(text: 'Livre', color: t.success),
          ],
        ),
        SizedBox(height: t.space4),

        // Depósito + ocupar
        _Card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _SectionTitle('Ocupação e extração'),
              SizedBox(height: t.space3),
              Row(
                children: [
                  Expanded(child: _Metric(label: 'Recurso', value: _resourceLabel(z.resource), color: color)),
                  Expanded(child: _Metric(label: 'Robôs p/ ocupar', value: '$robosNeeded', color: FwPalette.rust600)),
                  Expanded(child: _Metric(label: 'Depósito', value: 'Nv $deposit/10', color: FwPalette.gray900)),
                ],
              ),
              SizedBox(height: t.space3),
              ClipRRect(
                borderRadius: BorderRadius.circular(5),
                child: LinearProgressIndicator(
                  value: deposit / 10,
                  minHeight: 8,
                  backgroundColor: t.surfaceSunken,
                  valueColor: AlwaysStoppedAnimation(color),
                ),
              ),
              SizedBox(height: t.space4),
              Row(
                children: [
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: () => toast('Ocupar ${z.name} com $robosNeeded Robôs Mineradores — em breve'),
                      icon: const Icon(Icons.flag_outlined, size: 18),
                      label: const Text('Ocupar zona'),
                      style: FilledButton.styleFrom(backgroundColor: FwPalette.rust600, minimumSize: Size(0, t.controlLg)),
                    ),
                  ),
                  SizedBox(width: t.space2),
                  OutlinedButton.icon(
                    onPressed: () => toast('Recrute Robôs Mineradores no Quartel do seu Slot'),
                    icon: const Icon(Icons.precision_manufacturing_outlined, size: 18),
                    label: const Text('Robôs'),
                    style: OutlinedButton.styleFrom(minimumSize: Size(0, t.controlLg), side: BorderSide(color: t.borderStrong)),
                  ),
                ],
              ),
            ],
          ),
        ),
        SizedBox(height: t.space4),

        // Estruturas (§17.4)
        const _SectionTitle('Estruturas da zona'),
        SizedBox(height: t.space2),
        ...structures.map((s) => Padding(
              padding: EdgeInsets.only(bottom: t.space2),
              child: _StructureRow(s: s, onTap: () => toast('${s.level == 0 ? 'Construir' : 'Melhorar'} ${s.name} — em breve')),
            )),
        SizedBox(height: t.space4),

        // Defesa & Combate (§27)
        const _CombatSection(),
        SizedBox(height: t.space4),

        // Transporte (§7: 4 destinos)
        _Card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _SectionTitle('Transporte da carga'),
              SizedBox(height: t.space1),
              Text('Caminhão de Carga ou Nave de Transporte Planetária leva o recurso a um dos 4 destinos.',
                  style: TextStyle(fontSize: 12, color: t.textSecondary)),
              SizedBox(height: t.space3),
              Wrap(
                spacing: t.space2,
                runSpacing: t.space2,
                children: [
                  for (final d in destinos)
                    ActionChip(
                      avatar: Icon(d.$2, size: 16, color: FwPalette.rust600),
                      label: Text(d.$1),
                      onPressed: () => toast('Enviar carga → ${d.$1} — em breve'),
                      side: BorderSide(color: t.borderDefault),
                    ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.child});
  final Widget child;
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
      child: child,
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);
  final String text;
  @override
  Widget build(BuildContext context) => Text(text.toUpperCase(),
      style: GoogleFonts.rajdhani(
          fontWeight: FontWeight.w700, fontSize: 12, letterSpacing: 1.2, color: FwPalette.gray500));
}

class _Metric extends StatelessWidget {
  const _Metric({required this.label, required this.value, required this.color});
  final String label;
  final String value;
  final Color color;
  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).extension<DsTokens>()!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 10.5, color: t.textSecondary)),
        SizedBox(height: t.space1),
        Text(value,
            style: GoogleFonts.rajdhani(fontWeight: FontWeight.w700, fontSize: 15, color: color),
            maxLines: 1,
            overflow: TextOverflow.ellipsis),
      ],
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.text, required this.color});
  final String text;
  final Color color;
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(color: color.withValues(alpha: 0.14), borderRadius: BorderRadius.circular(8)),
        child: Text(text,
            style: GoogleFonts.rajdhani(fontWeight: FontWeight.w700, fontSize: 12, color: color)),
      );
}

class _StructureRow extends StatelessWidget {
  const _StructureRow({required this.s, required this.onTap});
  final _Structure s;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).extension<DsTokens>()!;
    final scheme = Theme.of(context).colorScheme;
    final built = s.level > 0;
    return Container(
      padding: EdgeInsets.all(t.space3),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(t.radiusMd),
        border: Border.all(color: t.borderDefault),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: (built ? FwPalette.rust600 : FwPalette.gray400).withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(t.radiusMd),
            ),
            child: Icon(s.icon, size: 20, color: built ? FwPalette.rust600 : FwPalette.gray500),
          ),
          SizedBox(width: t.space3),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(s.name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13.5)),
                    SizedBox(width: t.space2),
                    if (built && s.max > 0)
                      Text('Nv ${s.level}/${s.max}', style: TextStyle(fontSize: 11, color: t.textSecondary))
                    else if (built)
                      Text('Nv ${s.level}', style: TextStyle(fontSize: 11, color: t.textSecondary)),
                  ],
                ),
                const SizedBox(height: 2),
                Text(s.desc, style: TextStyle(fontSize: 11.5, color: t.textSecondary), maxLines: 2),
              ],
            ),
          ),
          SizedBox(width: t.space2),
          TextButton(onPressed: onTap, child: Text(built ? 'Melhorar' : 'Construir')),
        ],
      ),
    );
  }
}

/// Defesa & Combate territorial da zona (GDD v29 §27): guarnição, forças,
/// previsão de ataque (§27.5), manutenção (§27.12), proteção de novatos (§27.11).
class _CombatSection extends ConsumerWidget {
  const _CombatSection();

  void _toast(BuildContext context, String m) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(m), behavior: SnackBarBehavior.floating, duration: const Duration(seconds: 2)),
      );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = Theme.of(context).extension<DsTokens>()!;
    final combat = ref.watch(combatProvider);
    return _Card(
      child: combat.when(
        loading: () => Padding(
          padding: EdgeInsets.symmetric(vertical: t.space4),
          child: const Center(child: CircularProgressIndicator()),
        ),
        error: (_, __) => Row(
          children: [
            Icon(Icons.error_outline, size: 18, color: Theme.of(context).colorScheme.error),
            SizedBox(width: t.space2),
            const Expanded(child: Text('Falha ao carregar o combate.')),
            TextButton(onPressed: () => ref.invalidate(combatProvider), child: const Text('Tentar')),
          ],
        ),
        data: (c) => _CombatBody(combat: c, onAction: (m) => _toast(context, m)),
      ),
    );
  }
}

class _CombatBody extends StatelessWidget {
  const _CombatBody({required this.combat, required this.onAction});
  final CombatState combat;
  final void Function(String) onAction;

  String _f(double v) => v.round().toString();

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).extension<DsTokens>()!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionTitle('Defesa & Combate (§27)'),
        SizedBox(height: t.space3),
        Row(
          children: [
            Expanded(child: _Metric(label: 'Defesa da zona', value: _f(combat.defenseTotal), color: FwPalette.red600)),
            Expanded(child: _Metric(label: 'Sua força de ataque', value: _f(combat.attackTotal), color: FwPalette.rust600)),
            Expanded(child: _Metric(label: 'Saque ao vencer', value: '${combat.lootPct}%', color: t.solar)),
          ],
        ),
        SizedBox(height: t.space3),
        _ForecastBanner(forecast: combat.forecast),
        SizedBox(height: t.space3),
        Divider(height: 1, color: t.borderDefault),
        SizedBox(height: t.space3),
        // Guarnição da zona
        Text('GUARNIÇÃO DA ZONA',
            style: GoogleFonts.rajdhani(
                fontWeight: FontWeight.w700, fontSize: 10.5, letterSpacing: 0.8, color: FwPalette.gray500)),
        SizedBox(height: t.space2),
        for (final u in combat.garrison) _UnitRow(stack: u, defenseMode: true),
        SizedBox(height: t.space1),
        Row(
          children: [
            Icon(Icons.security_outlined, size: 13, color: t.textSecondary),
            SizedBox(width: t.space1),
            Expanded(
              child: Text('Bônus de construção +${combat.constructionBonusPct.round()}% (Muralha/Bastião/Torre, §27.3).',
                  style: TextStyle(fontSize: 11, color: t.textSecondary)),
            ),
          ],
        ),
        SizedBox(height: t.space3),
        // Sua força de ataque
        Text('SUA FORÇA DE ATAQUE',
            style: GoogleFonts.rajdhani(
                fontWeight: FontWeight.w700, fontSize: 10.5, letterSpacing: 0.8, color: FwPalette.gray500)),
        SizedBox(height: t.space2),
        for (final u in combat.yourUnits) _UnitRow(stack: u, defenseMode: false),
        SizedBox(height: t.space3),
        // Manutenção + novatos + cooldown
        _MaintenanceBlock(combat: combat),
        SizedBox(height: t.space3),
        Text(
          'Combate em rodadas de 10 min (§27.5). Ao vencer, saqueia ${combat.lootPct}% do estoque; o restante é '
          'destruído no conflito (§27.8). Após atacar, cooldown de 48h na mesma zona (§27.10).',
          style: TextStyle(fontSize: 11.5, height: 1.3, color: t.textSecondary),
        ),
        SizedBox(height: t.space3),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => onAction('Recrute Sentinelas no Quartel do seu Slot (§27.1)'),
                icon: const Icon(Icons.add_moderator_outlined, size: 18),
                label: const Text('Recrutar Sentinela'),
                style: OutlinedButton.styleFrom(minimumSize: Size(0, t.controlLg), side: BorderSide(color: t.borderStrong)),
              ),
            ),
            SizedBox(width: t.space2),
            Expanded(
              child: FilledButton.icon(
                onPressed: combat.noviceProtected || combat.cooldownHours > 0
                    ? null
                    : () => onAction('Ataque despachado — combate por rodadas (§27.5)'),
                icon: const Icon(Icons.gps_fixed, size: 18),
                label: const Text('Atacar zona'),
                style: FilledButton.styleFrom(backgroundColor: FwPalette.red600, minimumSize: Size(0, t.controlLg)),
              ),
            ),
          ],
        ),
        SizedBox(height: t.space3),
        const _SentinelTable(),
      ],
    );
  }
}

class _ForecastBanner extends StatelessWidget {
  const _ForecastBanner({required this.forecast});
  final CombatForecast forecast;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).extension<DsTokens>()!;
    final (label, detail, color, icon) = switch (forecast) {
      CombatForecast.attackerAdvantage =>
        ('Vantagem do atacante', '~4 rodadas (~40 min)', t.success, Icons.trending_up),
      CombatForecast.balanced =>
        ('Forças equilibradas', '~12 rodadas (~120 min) — reforços podem virar o jogo', t.warning, Icons.balance),
      CombatForecast.defenderAdvantage =>
        ('Vantagem do defensor', 'ataque tende a ser destruído', t.deltaDown, Icons.trending_down),
    };
    return Container(
      padding: EdgeInsets.all(t.space3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(t.radiusMd),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: color),
          SizedBox(width: t.space2),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: color)),
                Text(detail, style: TextStyle(fontSize: 11, color: t.textSecondary)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _UnitRow extends StatelessWidget {
  const _UnitRow({required this.stack, required this.defenseMode});
  final UnitStack stack;
  final bool defenseMode;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).extension<DsTokens>()!;
    final isRobo = stack.type == UnitType.robo;
    final value = defenseMode ? stack.totalDef : stack.totalAtk;
    final perUnit = defenseMode ? stack.unitDef : stack.unitAtk;
    return Padding(
      padding: EdgeInsets.symmetric(vertical: t.space1),
      child: Row(
        children: [
          Icon(isRobo ? Icons.precision_manufacturing_outlined : Icons.shield_outlined,
              size: 16, color: isRobo ? t.textSecondary : FwPalette.red600),
          SizedBox(width: t.space2),
          Expanded(
            child: Text('${stack.label} Nv ${stack.level} · ${stack.count}×',
                style: const TextStyle(fontSize: 12.5, color: FwPalette.gray900)),
          ),
          Text(defenseMode ? '$value def' : (isRobo ? '— atq' : '$value atq'),
              style: GoogleFonts.rajdhani(
                  fontWeight: FontWeight.w700, fontSize: 13, color: defenseMode ? FwPalette.red600 : FwPalette.rust600)),
          SizedBox(width: t.space2),
          Text('($perUnit/un)', style: TextStyle(fontSize: 10, color: t.textSecondary)),
        ],
      ),
    );
  }
}

class _MaintenanceBlock extends StatelessWidget {
  const _MaintenanceBlock({required this.combat});
  final CombatState combat;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).extension<DsTokens>()!;
    final lines = combat.maintenance.lines.map((e) => '${e.$2} ${e.$1}').join(' · ');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.build_circle_outlined, size: 14, color: t.textSecondary),
            SizedBox(width: t.space1),
            Expanded(
              child: Text('Manutenção diária (§27.12): $lines',
                  style: TextStyle(fontSize: 11.5, color: t.textSecondary)),
            ),
            _StatusChip(
                text: combat.maintenancePaid ? 'Em dia' : 'Atrasada',
                color: combat.maintenancePaid ? t.success : t.deltaDown),
          ],
        ),
        SizedBox(height: t.space2),
        Row(
          children: [
            Icon(combat.noviceProtected ? Icons.verified_user_outlined : Icons.lock_open_outlined,
                size: 14, color: combat.noviceProtected ? t.success : t.textSecondary),
            SizedBox(width: t.space1),
            Expanded(
              child: Text(
                  combat.noviceProtected
                      ? 'Protegida (novato, ${combat.noviceDaysLeft} dias restantes) — §27.11'
                      : 'Sem proteção de novato — pode ser atacada (§27.11)',
                  style: TextStyle(fontSize: 11.5, color: t.textSecondary)),
            ),
            if (combat.cooldownHours > 0)
              _StatusChip(text: 'Cooldown ${combat.cooldownHours}h', color: t.warning),
          ],
        ),
      ],
    );
  }
}

class _SentinelTable extends StatelessWidget {
  const _SentinelTable();

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
          Text('SENTINELA — ATRIBUTOS (QUARTEL, §27.1)',
              style: GoogleFonts.rajdhani(
                  fontWeight: FontWeight.w700, fontSize: 10.5, letterSpacing: 0.8, color: FwPalette.gray500)),
          SizedBox(height: t.space2),
          Row(
            children: [
              const Expanded(flex: 2, child: Text('Nível', style: TextStyle(fontSize: 10.5, color: FwPalette.gray600))),
              for (final s in kSentinelSpecs)
                Expanded(
                  child: Text('${s.level}',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.rajdhani(fontWeight: FontWeight.w700, fontSize: 11.5, color: FwPalette.gray700)),
                ),
            ],
          ),
          SizedBox(height: t.space1),
          _SentinelStatRow(label: 'Defesa', values: [for (final s in kSentinelSpecs) s.def], color: FwPalette.red600),
          _SentinelStatRow(label: 'Ataque', values: [for (final s in kSentinelSpecs) s.atk], color: FwPalette.rust600),
          SizedBox(height: t.space1),
          Text('Robô Minerador defende com 25% da Sentinela de mesmo nível (§27.2).',
              style: TextStyle(fontSize: 10.5, color: t.textSecondary)),
        ],
      ),
    );
  }
}

class _SentinelStatRow extends StatelessWidget {
  const _SentinelStatRow({required this.label, required this.values, required this.color});
  final String label;
  final List<int> values;
  final Color color;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1),
      child: Row(
        children: [
          Expanded(flex: 2, child: Text(label, style: const TextStyle(fontSize: 11, color: FwPalette.gray800))),
          for (final v in values)
            Expanded(
              child: Text('$v',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.rajdhani(fontWeight: FontWeight.w600, fontSize: 11.5, color: color)),
            ),
        ],
      ),
    );
  }
}
