import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// URL base da API (NestJS). Sobrescrevível em build: --dart-define=API_BASE_URL=...
const String kApiBaseUrl = String.fromEnvironment(
  'API_BASE_URL',
  defaultValue: 'http://localhost:3000/api',
);

/// Tokens atuais (em memória). O [AuthController] os atualiza; o interceptor do
/// Dio injeta o access no header e usa o refresh para renovar quando expira.
String? _accessToken;
String? _refreshToken;

void setAccessToken(String? token) => _accessToken = token;
void setRefreshToken(String? token) => _refreshToken = token;

/// Chamado quando um novo access token é obtido via refresh — o [AuthController]
/// o persiste em SharedPreferences para sobreviver a reloads.
void Function(String accessToken)? onAccessTokenRefreshed;

/// Chamado quando o refresh falha (refresh token inválido/expirado) — leva ao
/// logout para o usuário reautenticar.
void Function()? onRefreshFailed;

/// Deduplica refreshes concorrentes: várias chamadas retornam 401 ao mesmo tempo
/// (colônia + recursos + perfil), mas só um POST /auth/refresh deve disparar.
Future<String?>? _refreshing;

Future<String?> _refreshAccessToken() {
  return _refreshing ??= () async {
    try {
      // Dio "cru" (sem interceptors) evita recursão no próprio refresh.
      final bare = Dio(BaseOptions(
        baseUrl: kApiBaseUrl,
        headers: {'Content-Type': 'application/json'},
      ));
      final res = await bare.post<Map<String, dynamic>>(
        '/auth/refresh',
        data: {'refreshToken': _refreshToken},
      );
      final token = res.data!['accessToken'] as String;
      _accessToken = token;
      onAccessTokenRefreshed?.call(token);
      return token;
    } catch (_) {
      return null;
    } finally {
      _refreshing = null;
    }
  }();
}

/// Cria o cliente HTTP com base URL, injeção do Bearer e auto-refresh no 401.
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
      onError: (e, handler) async {
        final isUnauthorized = e.response?.statusCode == 401;
        final isAuthCall = e.requestOptions.path.contains('/auth/');
        final alreadyRetried = e.requestOptions.extra['__retried'] == true;
        if (isUnauthorized && !isAuthCall && !alreadyRetried && _refreshToken != null) {
          final token = await _refreshAccessToken();
          if (token != null) {
            try {
              final opts = e.requestOptions;
              opts.extra['__retried'] = true;
              opts.headers['Authorization'] = 'Bearer $token';
              final clone = await dio.fetch<dynamic>(opts);
              return handler.resolve(clone);
            } catch (err) {
              return handler.next(err is DioException ? err : e);
            }
          }
          // Refresh falhou (refresh token inválido/expirado): força reautenticação.
          onRefreshFailed?.call();
        }
        handler.next(e);
      },
    ),
  );
  return dio;
}

final dioProvider = Provider<Dio>((ref) => createDio());
