import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../app/theme/ds_colors.dart';
import '../../app/theme/ds_tokens.dart';
import '../../data/providers.dart';
import '../../domain/models/auction.dart';

({String label, Color color}) _rarityMeta(AuctionRarity r, DsTokens t) => switch (r) {
      AuctionRarity.unique => (label: 'Peça única', color: t.federation),
      AuctionRarity.legendary => (label: 'Lendária', color: t.solar),
      AuctionRarity.rare => (label: 'Rara', color: t.info),
    };

({String label, Color color, IconData icon}) _statusMeta(AuctionStatus s, DsTokens t) => switch (s) {
      AuctionStatus.live => (label: 'Ativo', color: t.success, icon: Icons.gavel_outlined),
      AuctionStatus.endingSoon => (label: 'Encerrando', color: t.warning, icon: Icons.timer_outlined),
      AuctionStatus.ended => (label: 'Encerrado', color: t.textSecondary, icon: Icons.lock_clock_outlined),
    };

enum _Tab { active, history }

/// Casa de Leilões (GDD v29 §13). Leilões de peças únicas que desbloqueiam no
/// Nível 100 (Lenda de Fertways); fora disso, a tela é uma prévia com lances
/// bloqueados. Persona Non Grata (§9.4) ou Confiança Comercial baixa (§26.2)
/// também bloqueiam. Drill-in do Mercado (mantém HUD/nav).
class AuctionsScreen extends ConsumerStatefulWidget {
  const AuctionsScreen({super.key});

  @override
  ConsumerState<AuctionsScreen> createState() => _AuctionsScreenState();
}

class _AuctionsScreenState extends ConsumerState<AuctionsScreen> {
  _Tab _tab = _Tab.active;

  void _toast(String m) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(m), behavior: SnackBarBehavior.floating, duration: const Duration(seconds: 2)),
      );

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).extension<DsTokens>()!;
    final money = NumberFormat.decimalPattern(Localizations.localeOf(context).languageCode);
    final house = ref.watch(auctionHouseProvider);

    return ColoredBox(
      color: t.surfacePage,
      child: house.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => Center(
          child: TextButton.icon(
            onPressed: () => ref.invalidate(auctionHouseProvider),
            icon: const Icon(Icons.refresh),
            label: const Text('Não foi possível carregar os leilões. Tocar para tentar de novo.'),
          ),
        ),
        data: (h) => Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const _Header(),
            _Tabs(value: _tab, onChanged: (v) => setState(() => _tab = v)),
            Expanded(
              child: Align(
                alignment: Alignment.topCenter,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 840),
                  child: switch (_tab) {
                    _Tab.active => _ActiveTab(house: h, money: money, onBid: _toast),
                    _Tab.history => _HistoryTab(house: h, money: money),
                  },
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
            onTap: () => context.go('/market'),
            borderRadius: BorderRadius.circular(t.radiusSm),
            child: Padding(
              padding: const EdgeInsets.all(6),
              child: Icon(Icons.arrow_back, size: 20, color: t.textSecondary),
            ),
          ),
          SizedBox(width: t.space2),
          const Icon(Icons.gavel_outlined, size: 22, color: FwPalette.rust600),
          SizedBox(width: t.space2),
          Text('Leilões',
              style: GoogleFonts.rajdhani(fontWeight: FontWeight.w700, fontSize: 22, color: FwPalette.gray900)),
        ],
      ),
    );
  }
}

class _Tabs extends StatelessWidget {
  const _Tabs({required this.value, required this.onChanged});
  final _Tab value;
  final ValueChanged<_Tab> onChanged;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).extension<DsTokens>()!;
    Widget chip(_Tab tab, String label, IconData icon) => Padding(
          padding: EdgeInsets.only(right: t.space2),
          child: ChoiceChip(
            avatar: Icon(icon, size: 15, color: value == tab ? FwPalette.rust600 : t.textSecondary),
            label: Text(label),
            selected: value == tab,
            onSelected: (_) => onChanged(tab),
          ),
        );
    return Padding(
      padding: EdgeInsets.fromLTRB(t.space4, 0, t.space4, t.space2),
      child: Row(
        children: [
          chip(_Tab.active, 'Ativos', Icons.gavel_outlined),
          chip(_Tab.history, 'Histórico', Icons.history_outlined),
        ],
      ),
    );
  }
}

// ── Aba Ativos ───────────────────────────────────────────────────────────────

class _ActiveTab extends StatelessWidget {
  const _ActiveTab({required this.house, required this.money, required this.onBid});
  final AuctionHouse house;
  final NumberFormat money;
  final ValueChanged<String> onBid;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).extension<DsTokens>()!;
    return ListView(
      padding: EdgeInsets.fromLTRB(t.space4, t.space2, t.space4, t.space6),
      children: [
        if (!house.canBid) _LockBanner(house: house),
        if (!house.canBid) SizedBox(height: t.space3),
        for (final item in house.items)
          _AuctionCard(
            item: item,
            money: money,
            canBid: house.canBid,
            onBid: () => onBid(house.canBid
                ? 'Lance de ${money.format(item.nextBid)} Fert\$ em ${item.name} — em breve'
                : 'Leilões liberam no Nível ${house.unlockLevel} (${house.unlockTitle}) — §13'),
          ),
      ],
    );
  }
}

class _LockBanner extends StatelessWidget {
  const _LockBanner({required this.house});
  final AuctionHouse house;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).extension<DsTokens>()!;
    final scheme = Theme.of(context).colorScheme;
    final blocked = house.blocked;
    final color = blocked ? t.deltaDown : t.solar;
    final frac = (house.playerLevel / house.unlockLevel).clamp(0.0, 1.0);
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
              Icon(blocked ? Icons.block : Icons.lock_outline, size: 20, color: color),
              SizedBox(width: t.space2),
              Expanded(
                child: Text(
                  blocked ? 'Acesso aos leilões bloqueado' : 'Leilões bloqueados',
                  style: GoogleFonts.rajdhani(fontWeight: FontWeight.w700, fontSize: 16, color: FwPalette.gray900),
                ),
              ),
            ],
          ),
          SizedBox(height: t.space1),
          Text(
            blocked
                ? (house.blockReason.isNotEmpty ? house.blockReason : 'Restrição ativa (§9.4 / §26.2).')
                : 'Os leilões de peças únicas liberam no Nível ${house.unlockLevel} — ${house.unlockTitle} (§13). '
                    'Você está no nível ${house.playerLevel}.',
            style: TextStyle(fontSize: 12.5, height: 1.35, color: t.textSecondary),
          ),
          if (!blocked) ...[
            SizedBox(height: t.space3),
            Row(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: frac,
                      minHeight: 7,
                      backgroundColor: t.surfaceSunken,
                      valueColor: AlwaysStoppedAnimation<Color>(color),
                    ),
                  ),
                ),
                SizedBox(width: t.space2),
                Text('${house.playerLevel}/${house.unlockLevel}',
                    style: GoogleFonts.rajdhani(fontWeight: FontWeight.w700, fontSize: 13, color: color)),
              ],
            ),
          ],
          SizedBox(height: t.space2),
          Row(
            children: [
              Icon(Icons.info_outline, size: 13, color: t.textSecondary),
              SizedBox(width: t.space1),
              Expanded(
                child: Text(
                  'Persona Non Grata (§9.4) ou Confiança Comercial baixa (§26.2) também bloqueiam o acesso. '
                  'Abaixo, uma prévia dos lotes ativos.',
                  style: TextStyle(fontSize: 11, color: t.textSecondary),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AuctionCard extends StatelessWidget {
  const _AuctionCard({required this.item, required this.money, required this.canBid, required this.onBid});
  final AuctionItem item;
  final NumberFormat money;
  final bool canBid;
  final VoidCallback onBid;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).extension<DsTokens>()!;
    final scheme = Theme.of(context).colorScheme;
    final rarity = _rarityMeta(item.rarity, t);
    final status = _statusMeta(item.status, t);
    return Container(
      margin: EdgeInsets.only(bottom: t.space2),
      padding: EdgeInsets.all(t.space3),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(t.radiusCard),
        border: Border(
          left: BorderSide(color: rarity.color, width: 3),
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
              _Pill(label: rarity.label, color: rarity.color, icon: Icons.auto_awesome_outlined),
              const Spacer(),
              _Pill(label: item.timeLeft, color: status.color, icon: status.icon),
            ],
          ),
          SizedBox(height: t.space2),
          Text(item.name,
              style: GoogleFonts.rajdhani(fontWeight: FontWeight.w700, fontSize: 17, color: FwPalette.gray900)),
          SizedBox(height: t.space1),
          Text(item.description, style: TextStyle(fontSize: 12, height: 1.3, color: t.textSecondary)),
          SizedBox(height: t.space3),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('LANCE ATUAL',
                      style: GoogleFonts.rajdhani(
                          fontWeight: FontWeight.w700, fontSize: 10, letterSpacing: 0.5, color: t.textSecondary)),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Icon(Icons.paid_outlined, size: 18, color: t.solar),
                      SizedBox(width: t.space1),
                      Text(money.format(item.currentBid),
                          style: GoogleFonts.rajdhani(fontWeight: FontWeight.w700, fontSize: 22, color: FwPalette.gray900, height: 1)),
                      SizedBox(width: t.space1),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 2),
                        child: Text('Fert\$', style: TextStyle(fontSize: 11, color: t.textSecondary)),
                      ),
                    ],
                  ),
                ],
              ),
              const Spacer(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('${item.bidCount} lances', style: TextStyle(fontSize: 11, color: t.textSecondary)),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(item.youAreTop ? Icons.star : Icons.person_outline,
                          size: 12, color: item.youAreTop ? t.solar : t.textSecondary),
                      SizedBox(width: t.space1),
                      Text(item.youAreTop ? 'Você lidera' : item.topBidder,
                          style: TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w600,
                              color: item.youAreTop ? t.solar : FwPalette.gray800)),
                    ],
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: t.space3),
          Row(
            children: [
              Expanded(
                child: Text('Próximo lance mín.: ${money.format(item.nextBid)} Fert\$ (+${money.format(item.minIncrement)})',
                    style: TextStyle(fontSize: 11, color: t.textSecondary)),
              ),
              FilledButton.icon(
                onPressed: onBid,
                style: FilledButton.styleFrom(
                  backgroundColor: canBid ? rarity.color : t.surfaceSunken,
                  foregroundColor: canBid ? Colors.white : t.textSecondary,
                  visualDensity: VisualDensity.compact,
                ),
                icon: Icon(canBid ? Icons.gavel : Icons.lock_outline, size: 16),
                label: Text(canBid ? 'Dar lance' : 'Nível 100'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Aba Histórico ────────────────────────────────────────────────────────────

class _HistoryTab extends StatelessWidget {
  const _HistoryTab({required this.house, required this.money});
  final AuctionHouse house;
  final NumberFormat money;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).extension<DsTokens>()!;
    if (house.history.isEmpty) {
      return Center(child: Text('Nenhum leilão encerrado.', style: TextStyle(color: t.textSecondary)));
    }
    return ListView(
      padding: EdgeInsets.fromLTRB(t.space4, t.space2, t.space4, t.space6),
      children: [
        for (final r in house.history)
          Container(
            margin: EdgeInsets.only(bottom: t.space2),
            padding: EdgeInsets.all(t.space3),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(t.radiusMd),
              border: Border.all(color: t.borderDefault),
            ),
            child: Row(
              children: [
                Icon(Icons.emoji_events_outlined, size: 18, color: t.solar),
                SizedBox(width: t.space3),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(r.name,
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: FwPalette.gray900)),
                      Text('Arrematado por ${r.winner} · ${r.day}',
                          style: TextStyle(fontSize: 11.5, color: t.textSecondary)),
                    ],
                  ),
                ),
                Text('${money.format(r.finalPrice)} Fert\$',
                    style: GoogleFonts.rajdhani(fontWeight: FontWeight.w700, fontSize: 15, color: t.solar)),
              ],
            ),
          ),
      ],
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
