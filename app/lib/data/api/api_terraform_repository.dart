import 'package:dio/dio.dart';

import '../../domain/models/terraform.dart';
import '../../domain/repositories/terraform_repository.dart';

/// Terraformação Global real (/terraform) — o backend já devolve no formato do
/// modelo. Contribuição do jogador ainda é 0 (endpoint de contribuir virá).
class ApiTerraformRepository implements TerraformRepository {
  ApiTerraformRepository(this._dio);
  final Dio _dio;

  @override
  Future<TerraformState> loadTerraform() async {
    final res = await _dio.get<Map<String, dynamic>>('/terraform');
    return TerraformState.fromJson(res.data!);
  }
}
