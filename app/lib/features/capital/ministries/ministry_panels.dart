import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../app/theme/ds_colors.dart';
import '../../../app/theme/ds_tokens.dart';
import '../../../domain/models/ministry.dart';
import 'ministry_widgets.dart';

// ── Formatação ──────────────────────────────────────────────────────────────
String _grp(int n) {
  final s = n.abs().toString();
  final b = StringBuffer();
  for (var i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) b.write('.');
    b.write(s[i]);
  }
  return '${n < 0 ? '-' : ''}$b';
}

String _fert(num v) => 'Fert\$ ${_grp(v.round())}';

EdgeInsets _bodyPadding(DsTokens t) => EdgeInsets.fromLTRB(t.space4, 0, t.space4, t.space6);

// ── Finanças e Tesouro (§2.1 slot 4) ────────────────────────────────────────
class TreasuryPanel extends StatelessWidget {
  const TreasuryPanel({super.key, required this.data});
  final TreasuryData data;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).extension<DsTokens>()!;
    final net = data.dailyRevenue - data.dailyExpense;
    return ListView(
      padding: _bodyPadding(t),
      children: [
        StatGrid(tiles: [
          StatTile(
              label: 'Tesouro (Fert\$)',
              value: _grp(data.balanceFert.round()),
              icon: Icons.account_balance_wallet_outlined,
              color: t.solar),
          StatTile(label: 'PIB do servidor', value: _grp(data.pib.round()), icon: Icons.public, color: t.info),
          StatTile(
              label: 'Receita / dia',
              value: _fert(data.dailyRevenue),
              icon: Icons.trending_up,
              color: t.success),
          StatTile(
              label: 'Despesa / dia',
              value: _fert(data.dailyExpense),
              icon: Icons.trending_down,
              color: t.deltaDown),
        ]),
        SizedBox(height: t.space3),
        MinistrySection(
          title: 'Fluxo de caixa do dia',
          subtitle: 'Entradas e saídas que o Tesouro consolida em Fert\$.',
          child: Column(
            children: [
              for (final l in data.lines)
                Padding(
                  padding: EdgeInsets.symmetric(vertical: t.space1),
                  child: Row(
                    children: [
                      Icon(l.inflow ? Icons.south_west : Icons.north_east,
                          size: 15, color: l.inflow ? t.success : t.deltaDown),
                      SizedBox(width: t.space2),
                      Expanded(
                        child: Text(l.label, style: TextStyle(fontSize: 13, color: t.textSecondary)),
                      ),
                      Text('${l.inflow ? '+' : '−'} ${_fert(l.amount)}',
                          style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: l.inflow ? t.success : t.deltaDown)),
                    ],
                  ),
                ),
              Divider(height: t.space6, color: t.borderDefault),
              KeyValueRow(
                label: 'Resultado do dia',
                value: '${net >= 0 ? '+' : '−'} ${_fert(net.abs())}',
                valueColor: net >= 0 ? t.success : t.deltaDown,
              ),
            ],
          ),
        ),
        FilledButton.icon(
          onPressed: () => mockMinistryAction(context, 'Painel financeiro completo — em breve'),
          icon: const Icon(Icons.analytics_outlined, size: 18),
          label: const Text('Abrir painel financeiro'),
        ),
      ],
    );
  }
}

// ── Central de Tributos (§2.1 slot 2 + §8.3) ────────────────────────────────
class TaxPanel extends StatelessWidget {
  const TaxPanel({super.key, required this.data});
  final TaxData data;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).extension<DsTokens>()!;
    return ListView(
      padding: _bodyPadding(t),
      children: [
        StatGrid(tiles: [
          StatTile(
              label: 'Arrecadado hoje',
              value: _fert(data.collectedToday),
              icon: Icons.account_balance_outlined,
              color: t.solar),
          StatTile(
              label: 'Redistribuído hoje',
              value: _fert(data.redistributedToday),
              icon: Icons.share_outlined,
              color: t.info),
        ]),
        SizedBox(height: t.space3),
        MinistrySection(
          title: 'Alíquotas sobre o comércio (§8.3)',
          subtitle: 'Cobradas na saída de recursos — negociação ou presente.',
          child: Column(
            children: [
              _TaxRateRow(label: 'Recursos primários', rate: data.primaryRate, color: t.success),
              _TaxRateRow(label: 'Recursos secundários', rate: data.secondaryRate, color: t.info),
              _TaxRateRow(label: 'Recursos raros', rate: data.rareRate, color: t.federation),
              SizedBox(height: t.space2),
              Container(
                padding: EdgeInsets.all(t.space3),
                decoration: BoxDecoration(
                  color: t.surfaceSunken,
                  borderRadius: BorderRadius.circular(t.radiusMd),
                ),
                child: Row(
                  children: [
                    Icon(Icons.groups_outlined, size: 16, color: t.federation),
                    SizedBox(width: t.space2),
                    Expanded(
                      child: Text(data.federationExemption,
                          style: TextStyle(fontSize: 12.5, color: t.textSecondary)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        MinistrySection(
          title: 'Arrecadações recentes',
          child: Column(
            children: [
              for (final c in data.recent)
                MinistryTile(
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(c.resource,
                                style: const TextStyle(
                                    fontSize: 13.5, fontWeight: FontWeight.w600, color: FwPalette.gray900)),
                            SizedBox(height: t.space1),
                            Text('${c.trader} · ${c.volume} un',
                                style: TextStyle(fontSize: 11.5, color: t.textSecondary)),
                          ],
                        ),
                      ),
                      SizedBox(width: t.space2),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text('+ ${_fert(c.tax)}',
                              style: GoogleFonts.rajdhani(
                                  fontWeight: FontWeight.w700, fontSize: 15, color: t.solar)),
                          SizedBox(height: t.space1),
                          Text('${c.tier} · ${c.rate}%',
                              style: TextStyle(fontSize: 10.5, color: t.textSecondary)),
                        ],
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _TaxRateRow extends StatelessWidget {
  const _TaxRateRow({required this.label, required this.rate, required this.color});
  final String label;
  final int rate;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).extension<DsTokens>()!;
    return Padding(
      padding: EdgeInsets.symmetric(vertical: t.space1),
      child: Row(
        children: [
          Expanded(child: Text(label, style: const TextStyle(fontSize: 13, color: FwPalette.gray900))),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(t.radiusMd),
            ),
            child: Text('$rate%',
                style: GoogleFonts.rajdhani(fontWeight: FontWeight.w700, fontSize: 14, color: color)),
          ),
        ],
      ),
    );
  }
}

// ── Pesquisas e Notícias (§2.1 slot 3 + §12.1) ──────────────────────────────
class ResearchPanel extends StatelessWidget {
  const ResearchPanel({super.key, required this.data});
  final ResearchData data;

  ({Color color, IconData icon, String label}) _cat(String c, DsTokens t) => switch (c) {
        'gagarin' => (color: t.info, icon: Icons.travel_explore, label: 'Gagarin'),
        'event' => (color: t.solar, icon: Icons.celebration_outlined, label: 'Evento'),
        _ => (color: t.federation, icon: Icons.campaign_outlined, label: 'Oficial'),
      };

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).extension<DsTokens>()!;
    return ListView(
      padding: _bodyPadding(t),
      children: [
        MinistrySection(
          title: 'Telescópio Orbital Gagarin',
          trailing: StatusPill(
            label: data.gagarinActive ? 'Ativo' : 'Inativo',
            color: data.gagarinActive ? t.success : t.textSecondary,
            icon: data.gagarinActive ? Icons.sensors : Icons.sensors_off,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              KeyValueRow(label: 'Gatilho de ativação', value: data.gagarinTrigger),
              KeyValueRow(label: 'Frequência', value: data.gagarinFrequency),
              SizedBox(height: t.space3),
              OutlinedButton.icon(
                onPressed: () => context.go('/spaceport/lunar'),
                icon: const Icon(Icons.travel_explore, size: 18),
                label: const Text('Exploração Lunar · 8 luas'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: FwPalette.gray800,
                  side: BorderSide(color: t.borderDefault),
                  minimumSize: Size(0, t.controlMd),
                ),
              ),
            ],
          ),
        ),
        MinistrySection(
          title: 'Feed de notícias',
          subtitle: 'Descobertas do Gagarin, eventos e comunicados oficiais.',
          child: Column(
            children: [
              for (final n in data.feed) ...[
                Builder(builder: (context) {
                  final cat = _cat(n.category, t);
                  return MinistryTile(
                    accent: cat.color,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            StatusPill(label: cat.label, color: cat.color, icon: cat.icon),
                            const Spacer(),
                            Text(n.day, style: TextStyle(fontSize: 11, color: t.textSecondary)),
                          ],
                        ),
                        SizedBox(height: t.space2),
                        Text(n.title,
                            style: const TextStyle(
                                fontSize: 14, fontWeight: FontWeight.w600, color: FwPalette.gray900)),
                        SizedBox(height: t.space1),
                        Text(n.body,
                            style: TextStyle(fontSize: 12.5, height: 1.35, color: t.textSecondary)),
                      ],
                    ),
                  );
                }),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

// ── Administração Pública (§2.1 slot 1 + §14) ───────────────────────────────
class AdminPanel extends StatelessWidget {
  const AdminPanel({super.key, required this.data});
  final AdminData data;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).extension<DsTokens>()!;
    return ListView(
      padding: _bodyPadding(t),
      children: [
        MinistrySection(
          title: 'Leis vigentes',
          child: Column(
            children: [
              for (final law in data.laws)
                MinistryTile(
                  accent: t.info,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(law.primary,
                          style: const TextStyle(
                              fontSize: 13.5, fontWeight: FontWeight.w600, color: FwPalette.gray900)),
                      SizedBox(height: t.space1),
                      Text(law.secondary,
                          style: TextStyle(fontSize: 12.5, height: 1.3, color: t.textSecondary)),
                    ],
                  ),
                ),
            ],
          ),
        ),
        MinistrySection(
          title: 'Punições recentes',
          child: Column(
            children: [
              for (final p in data.punishments)
                MinistryTile(
                  accent: t.deltaDown,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(p.primary,
                                style: const TextStyle(
                                    fontSize: 13, fontWeight: FontWeight.w600, color: FwPalette.gray900)),
                          ),
                          StatusPill(label: p.tertiary, color: t.deltaDown, icon: Icons.gavel_outlined),
                        ],
                      ),
                      SizedBox(height: t.space1),
                      Text(p.secondary, style: TextStyle(fontSize: 12, color: t.textSecondary)),
                    ],
                  ),
                ),
            ],
          ),
        ),
        MinistrySection(
          title: 'Recompensas',
          child: Column(
            children: [
              for (final r in data.rewards)
                MinistryTile(
                  accent: t.success,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(r.primary,
                                style: const TextStyle(
                                    fontSize: 13, fontWeight: FontWeight.w600, color: FwPalette.gray900)),
                          ),
                          Icon(Icons.workspace_premium_outlined, size: 16, color: t.success),
                        ],
                      ),
                      SizedBox(height: t.space1),
                      Text('${r.secondary} · ${r.tertiary}',
                          style: TextStyle(fontSize: 12, color: t.textSecondary)),
                    ],
                  ),
                ),
            ],
          ),
        ),
        MinistrySection(
          title: 'Cargos públicos neutros (§14)',
          subtitle: 'Trilha administrativa: salário fixo + bônus por atividade.',
          trailing: TextButton(
            onPressed: () => context.go('/capital/offices'),
            child: const Text('Gerir'),
          ),
          child: Column(
            children: [
              for (final o in data.offices)
                Padding(
                  padding: EdgeInsets.symmetric(vertical: t.space1),
                  child: Row(
                    children: [
                      Icon(Icons.badge_outlined, size: 16, color: t.textSecondary),
                      SizedBox(width: t.space2),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(o.primary,
                                style: const TextStyle(
                                    fontSize: 13, fontWeight: FontWeight.w600, color: FwPalette.gray900)),
                            Text('${o.secondary} · ${o.tertiary}',
                                style: TextStyle(fontSize: 11.5, color: t.textSecondary)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

// ── Segurança e Guerra (§2.1 slot 5 + §15) ──────────────────────────────────
class SecurityPanel extends StatelessWidget {
  const SecurityPanel({super.key, required this.data});
  final SecurityData data;

  Color _statusColor(String s, DsTokens t) {
    final low = s.toLowerCase();
    if (low.contains('validad')) return t.success;
    if (low.contains('valida')) return t.warning;
    if (low.contains('cerco') || low.contains('curso')) return t.deltaDown;
    return t.info;
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).extension<DsTokens>()!;
    return ListView(
      padding: _bodyPadding(t),
      children: [
        Container(
          margin: EdgeInsets.only(bottom: t.space3),
          padding: EdgeInsets.all(t.space4),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(t.radiusCard),
            gradient: const LinearGradient(colors: [FwPalette.rust600, FwPalette.red600]),
          ),
          child: Row(
            children: [
              const Icon(Icons.military_tech_outlined, color: Colors.white, size: 26),
              SizedBox(width: t.space3),
              const Expanded(
                child: Text('Ranking de Guerras — geral individual e de federações (§15.4)',
                    style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
              ),
              SizedBox(width: t.space2),
              FilledButton(
                style: FilledButton.styleFrom(
                    backgroundColor: Colors.white, foregroundColor: FwPalette.rust700),
                onPressed: () => context.go('/capital/rankings'),
                child: const Text('Ver ranking'),
              ),
            ],
          ),
        ),
        MinistrySection(
          title: 'Guerras registradas',
          child: Column(
            children: [
              for (final w in data.wars)
                MinistryTile(
                  accent: t.deltaDown,
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Flexible(
                                  child: Text(w.primary,
                                      style: const TextStyle(
                                          fontSize: 12.5, fontWeight: FontWeight.w600, color: FwPalette.gray900),
                                      overflow: TextOverflow.ellipsis),
                                ),
                                Padding(
                                  padding: EdgeInsets.symmetric(horizontal: t.space1),
                                  child: Icon(Icons.arrow_forward, size: 13, color: t.textSecondary),
                                ),
                                Flexible(
                                  child: Text(w.secondary,
                                      style: TextStyle(fontSize: 12.5, color: t.textSecondary),
                                      overflow: TextOverflow.ellipsis),
                                ),
                              ],
                            ),
                            SizedBox(height: t.space1),
                            Text(w.meta, style: TextStyle(fontSize: 11, color: t.textSecondary)),
                          ],
                        ),
                      ),
                      SizedBox(width: t.space2),
                      StatusPill(label: w.status, color: _statusColor(w.status, t)),
                    ],
                  ),
                ),
            ],
          ),
        ),
        MinistrySection(
          title: 'Tratados e acordos',
          subtitle: 'Validação de acordos entre colonos e federações.',
          child: Column(
            children: [
              for (final tr in data.treaties)
                MinistryTile(
                  child: Row(
                    children: [
                      Icon(Icons.handshake_outlined, size: 16, color: t.textSecondary),
                      SizedBox(width: t.space2),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(tr.primary,
                                style: const TextStyle(
                                    fontSize: 13, fontWeight: FontWeight.w600, color: FwPalette.gray900)),
                            Text(tr.secondary, style: TextStyle(fontSize: 11.5, color: t.textSecondary)),
                          ],
                        ),
                      ),
                      SizedBox(width: t.space2),
                      StatusPill(label: tr.status, color: _statusColor(tr.status, t)),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

// ── Estacionamento de Caminhões (§2.1 slot 6) ───────────────────────────────
class ParkingPanel extends StatelessWidget {
  const ParkingPanel({super.key, required this.data});
  final ParkingData data;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).extension<DsTokens>()!;
    final ratio = data.totalSlots == 0 ? 0.0 : data.occupied / data.totalSlots;
    return ListView(
      padding: _bodyPadding(t),
      children: [
        StatGrid(tiles: [
          StatTile(
              label: 'Vagas ocupadas',
              value: '${data.occupied} / ${data.totalSlots}',
              icon: Icons.local_parking_outlined,
              color: t.info),
          StatTile(
              label: 'Taxa por hora',
              value: _fert(data.hourlyFee),
              icon: Icons.schedule,
              color: t.solar),
        ]),
        SizedBox(height: t.space3),
        MinistrySection(
          title: 'Ocupação',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(t.radiusSm),
                child: LinearProgressIndicator(
                  value: ratio,
                  minHeight: 10,
                  backgroundColor: t.surfaceSunken,
                  valueColor: AlwaysStoppedAnimation(ratio > 0.85 ? t.deltaDown : t.info),
                ),
              ),
              SizedBox(height: t.space2),
              Text('${(ratio * 100).round()}% das vagas em uso · cobrança por hora.',
                  style: TextStyle(fontSize: 12, color: t.textSecondary)),
            ],
          ),
        ),
        MinistrySection(
          title: 'Caminhões aguardando retirada',
          child: Column(
            children: [
              for (final s in data.slots)
                MinistryTile(
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                        decoration: BoxDecoration(
                          color: t.surfaceSunken,
                          borderRadius: BorderRadius.circular(t.radiusSm),
                        ),
                        child: Text(s.plate,
                            style: GoogleFonts.robotoMono(
                                fontSize: 11.5, fontWeight: FontWeight.w600, color: FwPalette.gray800)),
                      ),
                      SizedBox(width: t.space2),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(s.cargo,
                                style: const TextStyle(
                                    fontSize: 13, fontWeight: FontWeight.w600, color: FwPalette.gray900)),
                            Text(s.owner, style: TextStyle(fontSize: 11, color: t.textSecondary)),
                          ],
                        ),
                      ),
                      SizedBox(width: t.space2),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text('${s.hoursWaiting}h',
                              style: const TextStyle(
                                  fontSize: 12.5, fontWeight: FontWeight.w600, color: FwPalette.gray900)),
                          Text(_fert(s.fee), style: TextStyle(fontSize: 11, color: t.solar)),
                        ],
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

// ── Ministério dos Transportes (§2.1 slot 8 + §16.3/§16.4) ───────────────────
class TransportPanel extends StatelessWidget {
  const TransportPanel({super.key, required this.data});
  final TransportData data;

  Color _condColor(int c, DsTokens t) {
    if (c >= 70) return t.success;
    if (c >= 45) return t.warning;
    return t.deltaDown;
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).extension<DsTokens>()!;
    return ListView(
      padding: _bodyPadding(t),
      children: [
        Container(
          margin: EdgeInsets.only(bottom: t.space3),
          padding: EdgeInsets.all(t.space3),
          decoration: BoxDecoration(
            color: t.surfaceSunken,
            borderRadius: BorderRadius.circular(t.radiusMd),
          ),
          child: Row(
            children: [
              Icon(Icons.info_outline, size: 16, color: t.textSecondary),
              SizedBox(width: t.space2),
              Expanded(
                child: Text(
                    'Depreciação por horas de uso ativo (§16.4) — só Furgão e Caminhão de Carga. '
                    'Abaixo do limite crítico o veículo é bloqueado até manutenção.',
                    style: TextStyle(fontSize: 12, height: 1.3, color: t.textSecondary)),
              ),
            ],
          ),
        ),
        MinistrySection(
          title: 'Registro de placas (§16.3)',
          subtitle: 'Todo veículo civil recebe registro obrigatório ao ser construído.',
          child: Column(
            children: [
              for (final v in data.registry)
                MinistryTile(
                  accent: _condColor(v.condition, t),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                            decoration: BoxDecoration(
                              color: t.surfaceSunken,
                              borderRadius: BorderRadius.circular(t.radiusSm),
                            ),
                            child: Text(v.plate,
                                style: GoogleFonts.robotoMono(
                                    fontSize: 11.5, fontWeight: FontWeight.w600, color: FwPalette.gray800)),
                          ),
                          SizedBox(width: t.space2),
                          Expanded(
                            child: Text(v.type,
                                style: const TextStyle(
                                    fontSize: 13, fontWeight: FontWeight.w600, color: FwPalette.gray900)),
                          ),
                          StatusPill(label: '${v.condition}%', color: _condColor(v.condition, t)),
                        ],
                      ),
                      SizedBox(height: t.space2),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(t.radiusSm),
                        child: LinearProgressIndicator(
                          value: v.condition / 100,
                          minHeight: 6,
                          backgroundColor: t.surfaceSunken,
                          valueColor: AlwaysStoppedAnimation(_condColor(v.condition, t)),
                        ),
                      ),
                      SizedBox(height: t.space2),
                      Wrap(
                        spacing: t.space3,
                        runSpacing: t.space1,
                        children: [
                          _MetaBit(icon: Icons.person_outline, text: v.owner),
                          _MetaBit(icon: Icons.timer_outlined, text: '${v.activeHours}h de uso'),
                          _MetaBit(icon: Icons.build_outlined, text: '${v.maintenances} manut.'),
                          _MetaBit(icon: Icons.sell_outlined, text: 'Revenda ${_fert(v.resaleValue)}'),
                        ],
                      ),
                      SizedBox(height: t.space1),
                      Text(v.status, style: TextStyle(fontSize: 11.5, color: t.textSecondary)),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _MetaBit extends StatelessWidget {
  const _MetaBit({required this.icon, required this.text});
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).extension<DsTokens>()!;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: t.textSecondary),
        SizedBox(width: t.space1),
        Text(text, style: TextStyle(fontSize: 11.5, color: t.textSecondary)),
      ],
    );
  }
}

// ── Depósito Central ────────────────────────────────────────────────────────
class DepotPanel extends StatelessWidget {
  const DepotPanel({super.key, required this.data});
  final DepotData data;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).extension<DsTokens>()!;
    return ListView(
      padding: _bodyPadding(t),
      children: [
        MinistrySection(
          title: 'Capacidade por recurso',
          subtitle: 'Quando um recurso lota, a captação correspondente é desperdiçada.',
          child: Column(
            children: [
              for (final l in data.lines) ...[
                Padding(
                  padding: EdgeInsets.symmetric(vertical: t.space2),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(l.resource,
                                style: const TextStyle(
                                    fontSize: 13, fontWeight: FontWeight.w600, color: FwPalette.gray900)),
                          ),
                          Text('${_grp(l.stored)} / ${_grp(l.capacity)}',
                              style: TextStyle(fontSize: 12, color: t.textSecondary)),
                        ],
                      ),
                      SizedBox(height: t.space1),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(t.radiusSm),
                        child: LinearProgressIndicator(
                          value: l.ratio,
                          minHeight: 8,
                          backgroundColor: t.surfaceSunken,
                          valueColor: AlwaysStoppedAnimation(l.ratio > 0.85 ? t.deltaDown : t.teal),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
        FilledButton.icon(
          onPressed: () => mockMinistryAction(context, 'Ampliar depósito — em breve'),
          icon: const Icon(Icons.add_box_outlined, size: 18),
          label: const Text('Ampliar capacidade'),
        ),
      ],
    );
  }
}

// ── Central de Transportes (§19.5) ──────────────────────────────────────────
class CentralTransportPanel extends StatelessWidget {
  const CentralTransportPanel({super.key, required this.data});
  final CentralTransportData data;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).extension<DsTokens>()!;
    final current = data.levels.firstWhere(
      (l) => l.level == data.currentLevel,
      orElse: () => data.levels.isNotEmpty ? data.levels.first : const TransportLevel(level: 1, trucks: 1, energy: 22),
    );
    return ListView(
      padding: _bodyPadding(t),
      children: [
        StatGrid(tiles: [
          StatTile(label: 'Nível atual', value: '${current.level} / 10', icon: Icons.stairs_outlined, color: t.info),
          StatTile(
              label: 'Caminhões-base',
              value: '${current.trucks}',
              icon: Icons.local_shipping_outlined,
              color: FwPalette.rust600),
          StatTile(
              label: 'Consumo de energia',
              value: '${current.energy}/h',
              icon: Icons.bolt_outlined,
              color: t.solar),
        ]),
        SizedBox(height: t.space3),
        MinistrySection(
          title: 'Níveis (§19.5)',
          subtitle: 'Caminhões-base produzidos são permanentes; caminhões extras são produzíveis.',
          child: Column(
            children: [
              for (final lvl in data.levels)
                Builder(builder: (context) {
                  final isCurrent = lvl.level == data.currentLevel;
                  return Container(
                    margin: EdgeInsets.only(bottom: t.space1),
                    padding: EdgeInsets.symmetric(horizontal: t.space3, vertical: t.space2),
                    decoration: BoxDecoration(
                      color: isCurrent ? t.info.withValues(alpha: 0.1) : Colors.transparent,
                      borderRadius: BorderRadius.circular(t.radiusSm),
                    ),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 28,
                          child: Text('${lvl.level}',
                              style: GoogleFonts.rajdhani(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14,
                                  color: isCurrent ? t.info : FwPalette.gray700)),
                        ),
                        Expanded(
                          child: Text('${lvl.trucks} caminhões-base',
                              style: TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: isCurrent ? FontWeight.w600 : FontWeight.w400,
                                  color: FwPalette.gray900)),
                        ),
                        Text('${lvl.energy}/h',
                            style: TextStyle(fontSize: 12, color: t.textSecondary)),
                        if (isCurrent) ...[
                          SizedBox(width: t.space2),
                          StatusPill(label: 'Atual', color: t.info),
                        ],
                      ],
                    ),
                  );
                }),
            ],
          ),
        ),
        FilledButton.icon(
          onPressed: () => mockMinistryAction(context, 'Evoluir Central de Transportes — em breve'),
          icon: const Icon(Icons.upgrade, size: 18),
          label: const Text('Evoluir nível'),
        ),
      ],
    );
  }
}

// ── Genérico (slot desconhecido) ────────────────────────────────────────────
class GenericPanel extends StatelessWidget {
  const GenericPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).extension<DsTokens>()!;
    return Center(
      child: Padding(
        padding: EdgeInsets.all(t.space6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.dashboard_customize_outlined, size: 40, color: t.textSecondary),
            SizedBox(height: t.space3),
            Text('Painel desta instituição em desenvolvimento.',
                textAlign: TextAlign.center, style: TextStyle(fontSize: 13, color: t.textSecondary)),
          ],
        ),
      ),
    );
  }
}
