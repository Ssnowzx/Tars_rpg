import 'package:dio/dio.dart';

import '../../domain/models/ministry.dart';
import '../../domain/repositories/ministry_repository.dart';

/// Ministérios da Capital via API (/config).
class ApiMinistryRepository implements MinistryRepository {
  ApiMinistryRepository(this._dio);
  final Dio _dio;

  @override
  Future<MinistriesData> loadMinistries() async {
    final res = await _dio.get<Map<String, dynamic>>('/config/ministries');
    return MinistriesData.fromJson(res.data!);
  }
}
