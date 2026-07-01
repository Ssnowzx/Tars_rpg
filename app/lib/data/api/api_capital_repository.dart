import 'package:dio/dio.dart';

import '../../domain/models/institution_slot.dart';
import '../../domain/models/resources.dart';
import '../../domain/repositories/capital_repository.dart';

/// Implementação de API: recursos vêm de /resources; os 20 slots da Capital
/// (config canônica do jogo) vêm de /config/capital.
class ApiCapitalRepository implements CapitalRepository {
  ApiCapitalRepository(this._dio);
  final Dio _dio;

  @override
  Future<Resources> loadResources() async {
    final res = await _dio.get<Map<String, dynamic>>('/resources');
    final data = res.data!;
    final stocks = (data['stocks'] as List<dynamic>).map((e) {
      final s = e as Map<String, dynamic>;
      final key = s['key'] as String;
      return ResourceStock(
        id: key,
        label: _label(key),
        amount: (s['amount'] as num).toInt(),
        tier: _tier(s['tier'] as String),
        capacity: (s['capacity'] as num?)?.toInt(),
        perHour: (s['perHour'] as num?)?.toInt() ?? 0,
      );
    }).toList();
    return Resources(
      fertCoins: num.parse(data['fertCoins'].toString()).round(),
      stocks: stocks,
    );
  }

  @override
  Future<List<InstitutionSlot>> loadSlots() async {
    final res = await _dio.get<Map<String, dynamic>>('/config/capital');
    final slots = res.data?['slots'] as List<dynamic>? ?? const [];
    return slots.map((e) => InstitutionSlot.fromJson(e as Map<String, dynamic>)).toList();
  }
}

ResourceTier _tier(String backend) => switch (backend) {
      'rare' => ResourceTier.rare,
      'primary' => ResourceTier.primary,
      _ => ResourceTier.secondary, // industrial / mineral / component
    };

String _label(String key) => switch (key) {
      'oxygen' => 'Oxigênio',
      'water' => 'Água',
      'biomass' => 'Biomassa',
      'energy' => 'Energia',
      'metalore' => 'Metal Bruto',
      'alloys' => 'Ligas Metálicas',
      'chemicals' => 'Compostos Químicos',
      'biofuel' => 'Biocombustível',
      'aluminum' => 'Alumínio',
      'tin' => 'Estanho',
      'copper' => 'Cobre',
      'silicon' => 'Silício',
      'lithium' => 'Lítio',
      'tungsten' => 'Tungstênio',
      'tantalum' => 'Tântalo',
      'gold' => 'Ouro',
      _ => key,
    };
