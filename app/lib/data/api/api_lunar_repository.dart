import 'package:dio/dio.dart';

import '../../domain/models/lunar.dart';
import '../../domain/repositories/lunar_repository.dart';

/// Exploração Lunar real (/lunar) — o backend já devolve no formato do modelo.
class ApiLunarRepository implements LunarRepository {
  ApiLunarRepository(this._dio);
  final Dio _dio;

  @override
  Future<LunarExploration> loadLunar() async {
    final res = await _dio.get<Map<String, dynamic>>('/lunar');
    return LunarExploration.fromJson(res.data!);
  }
}
