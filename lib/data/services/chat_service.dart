import 'package:auticare/data/models/chat_model.dart';
import 'package:auticare/data/services/api_client.dart';

class ChatService {
  /// POST /chat/start — start or get existing conversation
  Future<ChatConversationModel?> startChat(List<String> participantIds) async {
    try {
      final res = await api.post<Map<String, dynamic>>(
        '/chat/start',
        data: {'participantIds': participantIds},
      );
      return ChatConversationModel.fromJson(res.data!);
    } catch (_) {
      return null;
    }
  }

  /// GET /chat/my-chats — list of conversations for the current user
  Future<List<ChatConversationModel>> getMyChats() async {
    try {
      final res = await api.get<dynamic>('/chat/my-chats');
      final list = res.data is List ? res.data as List : [];
      return list
          .whereType<Map<String, dynamic>>()
          .map(ChatConversationModel.fromJson)
          .toList();
    } catch (_) {
      return [];
    }
  }

  /// GET /chat/:chatId/messages — fetch messages for a conversation
  Future<List<ChatMessageModel>> getMessages(String chatId, {int? limit}) async {
    try {
      final res = await api.get<dynamic>(
        '/chat/$chatId/messages',
        params: limit != null ? {'limit': limit} : null,
      );
      final list = res.data is List ? res.data as List : [];
      return list
          .whereType<Map<String, dynamic>>()
          .map(ChatMessageModel.fromJson)
          .toList();
    } catch (_) {
      return [];
    }
  }

  /// POST /chat/send — send a text message
  Future<ChatMessageModel?> sendMessage(String chatId, String content,
      {String messageType = 'text'}) async {
    try {
      final res = await api.post<Map<String, dynamic>>(
        '/chat/send',
        data: {
          'chatId': int.tryParse(chatId) ?? chatId,
          'content': content,
          'messageType': messageType,
        },
      );
      return ChatMessageModel.fromJson(res.data!);
    } catch (_) {
      return null;
    }
  }

  /// POST /chat/send-zoom-link — send a Zoom link via chat
  Future<ChatMessageModel?> sendZoomLink(
    String chatId,
    String zoomLink, {
    String? confirmedDate,
    String? confirmedTime,
    String note = 'Zoom Session Link',
  }) async {
    try {
      final now = DateTime.now();
      final res = await api.post<Map<String, dynamic>>(
        '/chat/send-zoom-link',
        data: {
          'chatId': int.tryParse(chatId) ?? chatId,
          'zoomLink': zoomLink,
          'confirmedDate': confirmedDate ?? now.toIso8601String().split('T').first,
          'confirmedTime': confirmedTime ?? '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}',
          'note': note,
        },
      );
      return ChatMessageModel.fromJson(res.data!);
    } catch (_) {
      return null;
    }
  }

  /// PATCH /chat/:chatId/read-all — mark all messages in a chat as read
  Future<void> markChatAsRead(String chatId) async {
    try {
      await api.patch<dynamic>('/chat/$chatId/read-all');
    } catch (_) {}
  }
}

final chatService = ChatService();
