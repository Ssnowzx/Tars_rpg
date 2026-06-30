import 'package:flutter/foundation.dart';

/// Os 5 canais de comunicação do Fertways (GDD v29 §10.1).
enum ChannelKind { global, region, federation, dm, neighborhood }

ChannelKind _kindFrom(String? s) => switch (s) {
      'region' => ChannelKind.region,
      'federation' => ChannelKind.federation,
      'dm' => ChannelKind.dm,
      'neighborhood' => ChannelKind.neighborhood,
      _ => ChannelKind.global,
    };

/// Uma mensagem dentro de um canal (§10).
@immutable
class ChatMessage {
  const ChatMessage({
    required this.id,
    required this.author,
    required this.sector,
    required this.text,
    required this.time,
    this.language = 'pt',
    this.isYou = false,
  });

  final String id;
  final String author;
  final String sector;
  final String text;
  final String time; // já formatado (ex.: "14:32")
  final String language; // idioma do remetente (§10.4)
  final bool isYou;

  factory ChatMessage.fromJson(Map<String, dynamic> j) => ChatMessage(
        id: j['id'] as String,
        author: j['author'] as String? ?? '',
        sector: j['sector'] as String? ?? '',
        text: j['text'] as String? ?? '',
        time: j['time'] as String? ?? '',
        language: j['language'] as String? ?? 'pt',
        isYou: j['isYou'] as bool? ?? false,
      );
}

/// Um canal de comunicação (§10.1). `moderated` = filtro automático de palavras
/// (§10.2); federação e MP NÃO têm filtro automático, só denúncia manual.
@immutable
class ChatChannel {
  const ChatChannel({
    required this.id,
    required this.name,
    required this.kind,
    required this.scope,
    required this.description,
    required this.moderated,
    required this.messages,
    this.unread = 0,
  });

  final String id;
  final String name;
  final ChannelKind kind;
  final String scope; // ex.: "Todos os jogadores", "12 membros"
  final String description;
  final bool moderated;
  final int unread;
  final List<ChatMessage> messages;

  factory ChatChannel.fromJson(Map<String, dynamic> j) => ChatChannel(
        id: j['id'] as String,
        name: j['name'] as String? ?? '',
        kind: _kindFrom(j['kind'] as String?),
        scope: j['scope'] as String? ?? '',
        description: j['description'] as String? ?? '',
        moderated: j['moderated'] as bool? ?? true,
        unread: j['unread'] as int? ?? 0,
        messages: (j['messages'] as List<dynamic>? ?? const [])
            .map((e) => ChatMessage.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}

/// Estado do sistema de mensagens (mock, §10).
@immutable
class ChatState {
  const ChatState({required this.channels});
  final List<ChatChannel> channels;

  factory ChatState.fromJson(Map<String, dynamic> j) => ChatState(
        channels: (j['channels'] as List<dynamic>? ?? const [])
            .map((e) => ChatChannel.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}
