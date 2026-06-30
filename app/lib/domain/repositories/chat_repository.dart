import '../models/chat.dart';

/// Costura de repositório do sistema de mensagens (mock hoje, API depois) — §10.
abstract interface class ChatRepository {
  Future<ChatState> loadChat();
}
