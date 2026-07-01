import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// URL base da API (NestJS). Sobrescrevível em build: --dart-define=API_BASE_URL=...
const String kApiBaseUrl = String.fromEnvironment(
  'API_BASE_URL',
  defaultValue: 'http://localhost:3000/api',
);

/// Token de acesso atual (em memória). O [AuthController] atualiza; o
/// interceptor do Dio injeta no header Authorization.
String? _accessToken;

void setAccessToken(String? token) => _accessToken = token;

/// Cria o cliente HTTP com base URL e injeção automática do Bearer token.
Dio createDio() {
  final dio = Dio(
    BaseOptions(
      baseUrl: kApiBaseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {'Content-Type': 'application/json'},
    ),
  );
  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) {
        final token = _accessToken;
        if (token != null && token.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
    ),
  );
  return dio;
}

final dioProvider = Provider<Dio>((ref) => createDio());
