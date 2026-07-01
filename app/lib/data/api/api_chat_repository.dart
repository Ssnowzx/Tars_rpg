import 'package:dio/dio.dart';

import '../../domain/models/chat.dart';
import '../../domain/repositories/chat_repository.dart';

/// Sistema de mensagens (§10) via API (/config).
class ApiChatRepository implements ChatRepository {
  ApiChatRepository(this._dio);
  final Dio _dio;

  @override
  Future<ChatState> loadChat() async {
    final res = await _dio.get<Map<String, dynamic>>('/config/chat');
    return ChatState.fromJson(res.data!);
  }
}
