import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../app/theme/ds_colors.dart';
import '../../app/theme/ds_tokens.dart';
import '../../data/providers.dart';
import '../../domain/models/player_profile.dart';

/// Perfil público do jogador (GDD §5 progressão + §8/§9 reputação).
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = Theme.of(context).extension<DsTokens>()!;
    final profile = ref.watch(profileProvider);

    return profile.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, __) => Center(
        child: TextButton.icon(
          onPressed: () => ref.invalidate(profileProvider),
          icon: const Icon(Icons.refresh),
          label: const Text('Não foi possível carregar o perfil. Tocar para tentar de novo.'),
        ),
      ),
      data: (p) => ListView(
        padding: EdgeInsets.all(t.space4),
        children: [
          _HeaderCard(profile: p),
          if (p.reputation.isNotEmpty) ...[
            SizedBox(height: t.space3),
            _ReputationCard(profile: p),
          ],
          SizedBox(height: t.space3),
          _StatsCard(profile: p),
          SizedBox(height: t.space3),
          _ProgressionCard(profile: p),
          if (p.diary.isNotEmpty) ...[
            SizedBox(height: t.space3),
            _DiaryCard(profile: p),
          ],
          SizedBox(height: t.space3),
          _ReviewsCard(profile: p),
        ],
      ),
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).extension<DsTokens>()!;
    return Container(
      padding: EdgeInsets.all(t.space4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
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

class _Stars extends StatelessWidget {
  const _Stars({required this.rating, this.size = 16});
  final double rating;
  final double size;
  @override
  Widget build(BuildContext context) {
    final full = rating.floor();
    final half = (rating - full) >= 0.3;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 1; i <= 5; i++)
          Icon(
            i <= full ? Icons.star : (i == full + 1 && half ? Icons.star_half : Icons.star_border),
            size: size,
            color: FwPalette.solar500,
          ),
      ],
    );
  }
}

class _HeaderCard extends StatelessWidget {
  const _HeaderCard({required this.profile});
  final PlayerProfile profile;
  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).extension<DsTokens>()!;
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ClipOval(
                child: SizedBox(
                  width: 64,
                  height: 64,
                  child: Image.asset(
                    'assets/images/avatar-vale-v1.png',
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const DecoratedBox(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(colors: [FwPalette.teal500, FwPalette.teal700]),
                      ),
                      child: Icon(Icons.person, color: Colors.white, size: 32),
                    ),
                  ),
                ),
              ),
              SizedBox(width: t.space3),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(profile.displayName,
                        style: GoogleFonts.rajdhani(
                            fontWeight: FontWeight.w700, fontSize: 22, color: FwPalette.gray900, height: 1.1)),
                    SizedBox(height: t.space1),
                    Wrap(
                      spacing: t.space2,
                      runSpacing: t.space1,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        _Chip(text: profile.title, color: FwPalette.rust600),
                        _Chip(text: 'Setor ${profile.sector}', color: FwPalette.gray500),
                        if (profile.federation.isNotEmpty)
                          _Chip(text: profile.federation, color: FwPalette.purple600, icon: Icons.groups_outlined),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: t.space3),
          Row(
            children: [
              _Stars(rating: profile.rating),
              SizedBox(width: t.space2),
              Text(profile.rating.toStringAsFixed(1),
                  style: GoogleFonts.rajdhani(fontWeight: FontWeight.w700, fontSize: 16, color: FwPalette.gray900)),
              SizedBox(width: t.space2),
              Text('${profile.ratingCount} avaliações', style: TextStyle(fontSize: 12, color: t.textSecondary)),
            ],
          ),
          SizedBox(height: t.space3),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(color: FwPalette.rust50, borderRadius: BorderRadius.circular(6), border: Border.all(color: FwPalette.rust200)),
                child: Text('NÍVEL ${profile.level}',
                    style: GoogleFonts.rajdhani(fontWeight: FontWeight.w700, fontSize: 11, color: FwPalette.rust700)),
              ),
              SizedBox(width: t.space2),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(5),
                  child: LinearProgressIndicator(
                    value: profile.xpFraction,
                    minHeight: 8,
                    backgroundColor: t.surfaceSunken,
                    valueColor: const AlwaysStoppedAnimation(FwPalette.solar500),
                  ),
                ),
              ),
              SizedBox(width: t.space2),
              Text('${profile.xp}/${profile.xpMax} XP', style: TextStyle(fontSize: 11, color: t.textSecondary)),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatsCard extends StatelessWidget {
  const _StatsCard({required this.profile});
  final PlayerProfile profile;
  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).extension<DsTokens>()!;
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionTitle('Estatísticas'),
          SizedBox(height: t.space3),
          Wrap(
            spacing: t.space4,
            runSpacing: t.space3,
            children: [
              for (final s in profile.stats)
                SizedBox(
                  width: 130,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(s.value,
                          style: GoogleFonts.rajdhani(fontWeight: FontWeight.w700, fontSize: 20, color: FwPalette.gray900)),
                      Text(s.label, style: TextStyle(fontSize: 11.5, color: t.textSecondary)),
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

class _ProgressionCard extends StatelessWidget {
  const _ProgressionCard({required this.profile});
  final PlayerProfile profile;
  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).extension<DsTokens>()!;
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionTitle('Progressão · Títulos'),
          SizedBox(height: t.space3),
          for (final tier in profile.progression) Padding(
            padding: EdgeInsets.only(bottom: t.space2),
            child: _TierRow(tier: tier, level: profile.level),
          ),
        ],
      ),
    );
  }
}

class _TierRow extends StatelessWidget {
  const _TierRow({required this.tier, required this.level});
  final ProgressionTier tier;
  final int level;
  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).extension<DsTokens>()!;
    final unlocked = level >= tier.level;
    final current = tier.title == 'Pioneiro'; // simplificação: título atual do mock
    return Row(
      children: [
        Icon(unlocked ? Icons.check_circle : Icons.lock_outline,
            size: 18, color: unlocked ? FwPalette.green600 : t.textSecondary),
        SizedBox(width: t.space3),
        Text('Nv ${tier.level}',
            style: GoogleFonts.rajdhani(fontWeight: FontWeight.w700, fontSize: 13, color: t.textSecondary)),
        SizedBox(width: t.space3),
        Text(tier.title,
            style: TextStyle(
                fontSize: 14,
                fontWeight: current ? FontWeight.w700 : FontWeight.w500,
                color: unlocked ? FwPalette.gray900 : t.textSecondary)),
        if (current) ...[
          SizedBox(width: t.space2),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
            decoration: BoxDecoration(color: FwPalette.rust600, borderRadius: BorderRadius.circular(5)),
            child: const Text('ATUAL', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: Colors.white)),
          ),
        ],
      ],
    );
  }
}

class _ReviewsCard extends StatelessWidget {
  const _ReviewsCard({required this.profile});
  final PlayerProfile profile;
  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).extension<DsTokens>()!;
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionTitle('Avaliações recebidas'),
          SizedBox(height: t.space3),
          for (var i = 0; i < profile.reviews.length; i++) ...[
            if (i > 0) Padding(padding: EdgeInsets.symmetric(vertical: t.space2), child: Divider(height: 1, color: t.borderDefault)),
            _ReviewRow(review: profile.reviews[i]),
          ],
        ],
      ),
    );
  }
}

class _ReviewRow extends StatelessWidget {
  const _ReviewRow({required this.review});
  final ProfileReview review;
  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).extension<DsTokens>()!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _Stars(rating: review.stars.toDouble(), size: 14),
            SizedBox(width: t.space2),
            Text('${review.author} · ${review.authorSector}',
                style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: t.textSecondary)),
          ],
        ),
        SizedBox(height: t.space1),
        Text(review.text, style: const TextStyle(fontSize: 13, color: FwPalette.gray800, height: 1.35)),
      ],
    );
  }
}

IconData _repIcon(String id) => switch (id) {
      'commercial' => Icons.payments_outlined,
      'social' => Icons.forum_outlined,
      'civic' => Icons.account_balance_outlined,
      'military' => Icons.shield_outlined,
      _ => Icons.verified_user_outlined,
    };

Color _healthColor(int value, DsTokens t) =>
    value >= 750 ? t.success : (value >= 500 ? t.warning : t.deltaDown);

/// Reputação dividida em 4 índices independentes (GDD §26.2), escala 0–1000.
class _ReputationCard extends StatelessWidget {
  const _ReputationCard({required this.profile});
  final PlayerProfile profile;
  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).extension<DsTokens>()!;
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionTitle('Reputação · 4 índices (§26)'),
          SizedBox(height: t.space1),
          Text('Índices independentes (0–1000) — um não compensa o outro.',
              style: TextStyle(fontSize: 12, color: t.textSecondary)),
          SizedBox(height: t.space3),
          for (var i = 0; i < profile.reputation.length; i++) ...[
            if (i > 0) SizedBox(height: t.space3),
            _ReputationRow(index: profile.reputation[i]),
          ],
        ],
      ),
    );
  }
}

class _ReputationRow extends StatelessWidget {
  const _ReputationRow({required this.index});
  final ReputationIndex index;
  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).extension<DsTokens>()!;
    final health = _healthColor(index.value, t);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(_repIcon(index.id), size: 16, color: FwPalette.gray700),
            SizedBox(width: t.space2),
            Expanded(
              child: Text(index.label,
                  style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600, color: FwPalette.gray900)),
            ),
            Text('${index.value}',
                style: GoogleFonts.rajdhani(fontWeight: FontWeight.w700, fontSize: 15, color: health)),
            Text('/1000', style: TextStyle(fontSize: 10, color: t.textSecondary)),
          ],
        ),
        SizedBox(height: t.space1),
        ClipRRect(
          borderRadius: BorderRadius.circular(t.radiusSm),
          child: LinearProgressIndicator(
            value: index.fraction,
            minHeight: 7,
            backgroundColor: t.surfaceSunken,
            valueColor: AlwaysStoppedAnimation(health),
          ),
        ),
        SizedBox(height: t.space1),
        Text('Afeta: ${index.gates}', style: TextStyle(fontSize: 11, color: t.textSecondary)),
      ],
    );
  }
}

/// Diário do Colono (GDD §24.3): entradas automáticas por marco + nota pessoal.
class _DiaryCard extends StatelessWidget {
  const _DiaryCard({required this.profile});
  final PlayerProfile profile;
  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).extension<DsTokens>()!;
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionTitle('Diário do Colono (§24.3)'),
          SizedBox(height: t.space1),
          Text('Entradas automáticas por marco + sua nota. Privado por padrão.',
              style: TextStyle(fontSize: 12, color: t.textSecondary)),
          SizedBox(height: t.space3),
          for (var i = 0; i < profile.diary.length; i++) ...[
            if (i > 0) Padding(
              padding: EdgeInsets.symmetric(vertical: t.space2),
              child: Divider(height: 1, color: t.borderDefault),
            ),
            _DiaryRow(entry: profile.diary[i]),
          ],
        ],
      ),
    );
  }
}

class _DiaryRow extends StatelessWidget {
  const _DiaryRow({required this.entry});
  final DiaryEntry entry;
  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).extension<DsTokens>()!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.auto_stories_outlined, size: 16, color: FwPalette.rust600),
            SizedBox(width: t.space2),
            Expanded(
              child: Text(entry.milestone,
                  style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700, color: FwPalette.gray900)),
            ),
            SizedBox(width: t.space2),
            _PrivacyTag(isPublic: entry.isPublic),
          ],
        ),
        SizedBox(height: t.space1),
        Text('${entry.day} · ${entry.text}',
            style: const TextStyle(fontSize: 12.5, height: 1.35, color: FwPalette.gray800)),
        if (entry.note.isNotEmpty) ...[
          SizedBox(height: t.space2),
          Container(
            padding: EdgeInsets.all(t.space2),
            decoration: BoxDecoration(
              color: t.surfaceSunken,
              borderRadius: BorderRadius.circular(t.radiusSm),
              border: const Border(left: BorderSide(color: FwPalette.solar500, width: 3)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.edit_note_outlined, size: 15, color: t.textSecondary),
                SizedBox(width: t.space1),
                Expanded(
                  child: Text('Sua nota: ${entry.note}',
                      style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic, color: t.textSecondary)),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _PrivacyTag extends StatelessWidget {
  const _PrivacyTag({required this.isPublic});
  final bool isPublic;
  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).extension<DsTokens>()!;
    final c = isPublic ? t.info : t.textSecondary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(color: c.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(5)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(isPublic ? Icons.public : Icons.lock_outline, size: 11, color: c),
          const SizedBox(width: 3),
          Text(isPublic ? 'Público' : 'Privado',
              style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w700, color: c)),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.text, required this.color, this.icon});
  final String text;
  final Color color;
  final IconData? icon;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(6)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[Icon(icon, size: 12, color: color), const SizedBox(width: 4)],
          Text(text, style: GoogleFonts.rajdhani(fontWeight: FontWeight.w700, fontSize: 11.5, color: color)),
        ],
      ),
    );
  }
}
