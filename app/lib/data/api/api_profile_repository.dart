import 'package:dio/dio.dart';

import '../../domain/models/player_profile.dart';
import '../../domain/repositories/profile_repository.dart';

/// Marcos de colonização (§3): nível → título.
const List<ProgressionTier> _kMarcos = [
  ProgressionTier(level: 1, title: 'Sobrevivente'),
  ProgressionTier(level: 5, title: 'Colono'),
  ProgressionTier(level: 10, title: 'Pioneiro'),
  ProgressionTier(level: 20, title: 'Desbravador'),
  ProgressionTier(level: 35, title: 'Construtor'),
  ProgressionTier(level: 50, title: 'Arquiteto'),
  ProgressionTier(level: 75, title: 'Guardião'),
  ProgressionTier(level: 100, title: 'Lenda de Fertways'),
];

String _titleForLevel(int level) {
  var title = _kMarcos.first.title;
  for (final m in _kMarcos) {
    if (level >= m.level) title = m.title;
  }
  return title;
}

/// Perfil real a partir de /me: nome, nível, XP e os 4 índices de reputação.
/// Avaliações/diário ficam vazios (estado real de conta nova).
class ApiProfileRepository implements ProfileRepository {
  ApiProfileRepository(this._dio);
  final Dio _dio;

  @override
  Future<PlayerProfile> loadProfile() async {
    final me = (await _dio.get<Map<String, dynamic>>('/me')).data!;
    final level = (me['level'] as num?)?.toInt() ?? 1;
    final rep = me['reputation'] as Map<String, dynamic>?;
    return PlayerProfile(
      displayName: me['nickname'] as String? ?? 'Colono',
      sector: 'F-07',
      title: _titleForLevel(level),
      level: level,
      xp: (me['xp'] as num?)?.toInt() ?? 0,
      xpMax: level * 1000,
      rating: 0,
      ratingCount: 0,
      federation: '',
      stats: const [],
      progression: _kMarcos,
      reviews: const [],
      reputation: rep == null
          ? const []
          : [
              ReputationIndex(
                id: 'commercial',
                label: 'Confiança Comercial',
                value: (rep['commercialTrust'] as num).toInt(),
                gates: 'Leilões, contratos de alto valor e Fiscal de Mercado.',
              ),
              ReputationIndex(
                id: 'social',
                label: 'Conduta Social',
                value: (rep['socialConduct'] as num).toInt(),
                gates: 'Silêncio temporário; impede funções públicas de comunicação.',
              ),
              ReputationIndex(
                id: 'civic',
                label: 'Status Cívico',
                value: (rep['civicStatus'] as num).toInt(),
                gates: 'Fundar federação, funções de tesouro e contratos institucionais.',
              ),
              ReputationIndex(
                id: 'military',
                label: 'Honra Militar/Diplomática',
                value: (rep['militaryHonor'] as num).toInt(),
                gates: 'Alianças, tratados e funções diplomáticas.',
              ),
            ],
      diary: const [],
    );
  }
}
