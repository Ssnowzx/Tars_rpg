import 'package:flutter/foundation.dart';

/// Marco de progressão (GDD §5): nível → título.
@immutable
class ProgressionTier {
  const ProgressionTier({required this.level, required this.title});
  final int level;
  final String title;
  factory ProgressionTier.fromJson(Map<String, dynamic> j) =>
      ProgressionTier(level: j['level'] as int, title: j['title'] as String);
}

/// Avaliação pública recebida (GDD §8.4).
@immutable
class ProfileReview {
  const ProfileReview({
    required this.author,
    required this.authorSector,
    required this.stars,
    required this.text,
  });
  final String author;
  final String authorSector;
  final int stars;
  final String text;
  factory ProfileReview.fromJson(Map<String, dynamic> j) => ProfileReview(
        author: j['author'] as String,
        authorSector: j['authorSector'] as String? ?? '',
        stars: j['stars'] as int? ?? 5,
        text: j['text'] as String? ?? '',
      );
}

/// Estatística do perfil (rótulo + valor formatado).
@immutable
class ProfileStat {
  const ProfileStat({required this.label, required this.value});
  final String label;
  final String value;
  factory ProfileStat.fromJson(Map<String, dynamic> j) =>
      ProfileStat(label: j['label'] as String, value: j['value'].toString());
}

/// Um dos 4 índices de reputação independentes (GDD §26.2), escala 0–1000.
@immutable
class ReputationIndex {
  const ReputationIndex({
    required this.id,
    required this.label,
    required this.value,
    required this.gates,
  });

  final String id; // commercial | social | civic | military
  final String label;
  final int value; // 0–1000
  final String gates; // o que bloqueia quando baixo

  double get fraction => (value / 1000).clamp(0, 1).toDouble();

  factory ReputationIndex.fromJson(Map<String, dynamic> j) => ReputationIndex(
        id: j['id'] as String? ?? '',
        label: j['label'] as String? ?? '',
        value: (j['value'] as int? ?? 0).clamp(0, 1000),
        gates: j['gates'] as String? ?? '',
      );
}

/// Entrada do Diário do Colono (GDD §24.3): narrativa automática por marco +
/// nota pessoal opcional; privada por padrão.
@immutable
class DiaryEntry {
  const DiaryEntry({
    required this.milestone,
    required this.day,
    required this.text,
    this.note = '',
    this.isPublic = false,
  });

  final String milestone;
  final String day;
  final String text;
  final String note;
  final bool isPublic;

  factory DiaryEntry.fromJson(Map<String, dynamic> j) => DiaryEntry(
        milestone: j['milestone'] as String? ?? '',
        day: j['day'] as String? ?? '',
        text: j['text'] as String? ?? '',
        note: j['note'] as String? ?? '',
        isPublic: j['isPublic'] as bool? ?? false,
      );
}

/// Perfil público do jogador (GDD §5 + §8/§9) — mock.
@immutable
class PlayerProfile {
  const PlayerProfile({
    required this.displayName,
    required this.sector,
    required this.title,
    required this.level,
    required this.xp,
    required this.xpMax,
    required this.rating,
    required this.ratingCount,
    required this.federation,
    required this.stats,
    required this.progression,
    required this.reviews,
    this.reputation = const [],
    this.diary = const [],
  });

  final String displayName;
  final String sector;
  final String title;
  final int level;
  final int xp;
  final int xpMax;
  final double rating; // 0–5 (média das avaliações de comércio, §8.4)
  final int ratingCount;
  final String federation;
  final List<ProfileStat> stats;
  final List<ProgressionTier> progression;
  final List<ProfileReview> reviews;
  final List<ReputationIndex> reputation; // 4 índices §26.2
  final List<DiaryEntry> diary; // Diário do Colono §24.3

  double get xpFraction => xpMax == 0 ? 0 : (xp / xpMax).clamp(0, 1).toDouble();

  factory PlayerProfile.fromJson(Map<String, dynamic> j) => PlayerProfile(
        displayName: j['displayName'] as String? ?? 'Colono',
        sector: j['sector'] as String? ?? '',
        title: j['title'] as String? ?? '',
        level: j['level'] as int? ?? 0,
        xp: j['xp'] as int? ?? 0,
        xpMax: j['xpMax'] as int? ?? 1,
        rating: ((j['rating'] as num?)?.toDouble() ?? 0).clamp(0, 5).toDouble(),
        ratingCount: j['ratingCount'] as int? ?? 0,
        federation: j['federation'] as String? ?? '',
        stats: (j['stats'] as List<dynamic>? ?? const [])
            .map((e) => ProfileStat.fromJson(e as Map<String, dynamic>))
            .toList(),
        progression: (j['progression'] as List<dynamic>? ?? const [])
            .map((e) => ProgressionTier.fromJson(e as Map<String, dynamic>))
            .toList(),
        reviews: (j['reviews'] as List<dynamic>? ?? const [])
            .map((e) => ProfileReview.fromJson(e as Map<String, dynamic>))
            .toList(),
        reputation: (j['reputation'] as List<dynamic>? ?? const [])
            .map((e) => ReputationIndex.fromJson(e as Map<String, dynamic>))
            .toList(),
        diary: (j['diary'] as List<dynamic>? ?? const [])
            .map((e) => DiaryEntry.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}
