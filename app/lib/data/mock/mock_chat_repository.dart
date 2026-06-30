import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

import '../../domain/models/chat.dart';
import '../../domain/repositories/chat_repository.dart';

class MockChatRepository implements ChatRepository {
  const MockChatRepository({this.latency = const Duration(milliseconds: 450)});

  final Duration latency;

  @override
  Future<ChatState> loadChat() async {
    await Future<void>.delayed(latency);
    final raw = await rootBundle.loadString('assets/fixtures/chat.json');
    return ChatState.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }
}
