import 'package:dio/dio.dart';

import '../../domain/models/federation.dart';
import '../../domain/repositories/federation_repository.dart';

/// Federação do jogador (§4) via API (/config).
class ApiFederationRepository implements FederationRepository {
  ApiFederationRepository(this._dio);
  final Dio _dio;

  @override
  Future<Federation> loadFederation() async {
    final res = await _dio.get<Map<String, dynamic>>('/config/federation');
    return Federation.fromJson(res.data!);
  }
}
