import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../api/api_client.dart';

enum AuthStatus { authenticated, unauthenticated }

class AuthState {
  const AuthState(this.status, {this.playerId});
  final AuthStatus status;
  final String? playerId;

  bool get isAuthenticated => status == AuthStatus.authenticated;
}

const _kTokenKey = 'accessToken';
const _kRefreshKey = 'refreshToken';

/// Token carregado do storage no boot (sobrescrito em main). null = deslogado.
final initialTokenProvider = Provider<String?>((ref) => null);

/// Estado de autenticação. Guarda o token em memória (via [setAccessToken]) e
/// persiste em SharedPreferences para sobreviver a reloads.
class AuthController extends Notifier<AuthState> {
  @override
  AuthState build() {
    final token = ref.read(initialTokenProvider);
    if (token != null && token.isNotEmpty) {
      setAccessToken(token);
      return const AuthState(AuthStatus.authenticated);
    }
    return const AuthState(AuthStatus.unauthenticated);
  }

  Future<void> login(String email, String password) async {
    final res = await ref
        .read(dioProvider)
        .post<Map<String, dynamic>>('/auth/login', data: {'email': email, 'password': password});
    await _apply(res.data!);
  }

  Future<void> register(String email, String password, String nickname) async {
    final res = await ref.read(dioProvider).post<Map<String, dynamic>>(
      '/auth/register',
      data: {'email': email, 'password': password, 'nickname': nickname},
    );
    await _apply(res.data!);
  }

  Future<void> logout() async {
    setAccessToken(null);
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kTokenKey);
    await prefs.remove(_kRefreshKey);
    state = const AuthState(AuthStatus.unauthenticated);
  }

  Future<void> _apply(Map<String, dynamic> data) async {
    final token = data['accessToken'] as String;
    final playerId = data['playerId'] as String?;
    setAccessToken(token);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kTokenKey, token);
    final refresh = data['refreshToken'] as String?;
    if (refresh != null) await prefs.setString(_kRefreshKey, refresh);
    state = AuthState(AuthStatus.authenticated, playerId: playerId);
  }
}

final authProvider = NotifierProvider<AuthController, AuthState>(AuthController.new);

/// Extrai a mensagem de erro amigável de uma exceção da API.
String apiErrorMessage(Object error) {
  if (error is DioException) {
    final data = error.response?.data;
    if (data is Map && data['message'] != null) {
      final msg = data['message'];
      if (msg is List) return msg.join(', ');
      return msg.toString();
    }
    if (error.type == DioExceptionType.connectionError ||
        error.type == DioExceptionType.connectionTimeout) {
      return 'Sem conexão com o servidor. O backend está rodando?';
    }
  }
  return 'Falha inesperada. Tente novamente.';
}
