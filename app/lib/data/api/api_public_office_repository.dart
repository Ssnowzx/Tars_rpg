import 'package:dio/dio.dart';

import '../../domain/models/public_office.dart';
import '../../domain/repositories/public_office_repository.dart';

/// Cargos Públicos Neutros (§14) via API (/config).
class ApiPublicOfficeRepository implements PublicOfficeRepository {
  ApiPublicOfficeRepository(this._dio);
  final Dio _dio;

  @override
  Future<PublicOfficeBoard> loadOffices() async {
    final res = await _dio.get<Map<String, dynamic>>('/config/offices');
    return PublicOfficeBoard.fromJson(res.data!);
  }
}
