import 'package:dio/dio.dart';

import '../../domain/models/dispute.dart';
import '../../domain/repositories/reputation_repository.dart';

/// Ministério das Reputações / Justiça (§9) via API (/config).
class ApiReputationRepository implements ReputationRepository {
  ApiReputationRepository(this._dio);
  final Dio _dio;

  @override
  Future<DisputeBoard> loadDisputes() async {
    final res = await _dio.get<Map<String, dynamic>>('/config/disputes');
    return DisputeBoard.fromJson(res.data!);
  }
}
