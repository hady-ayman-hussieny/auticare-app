/// Chat models — mirror ChatConversation and ChatMessage types from React
class ChatMessageModel {
  final String id;
  final String chatId;
  final String senderId;
  final String senderName;
  final String senderRole; // 'parent' | 'doctor' | 'therapist'
  final String content;
  final String messageType; // 'text' | 'zoom-link' | 'file'
  final String? zoomLink;
  final bool isRead;
  final String timestamp;
  final String createdAt;

  const ChatMessageModel({
    required this.id,
    required this.chatId,
    required this.senderId,
    this.senderName = '',
    this.senderRole = 'parent',
    required this.content,
    this.messageType = 'text',
    this.zoomLink,
    this.isRead = false,
    required this.timestamp,
    required this.createdAt,
  });

  factory ChatMessageModel.fromJson(Map<String, dynamic> json) {
    return ChatMessageModel(
      id: (json['id'] ?? json['messageId'] ?? '').toString(),
      chatId: (json['chatId'] ?? '').toString(),
      senderId: (json['senderId'] ?? json['userId'] ?? '').toString(),
      senderName: (json['senderName'] ?? '').toString(),
      senderRole: (json['senderRole'] ?? json['role'] ?? 'parent').toString(),
      content: (json['content'] ?? json['message'] ?? '').toString(),
      messageType: (json['messageType'] ?? json['type'] ?? 'text').toString(),
      zoomLink: json['zoomLink']?.toString(),
      isRead: json['isRead'] == true,
      timestamp: (json['timestamp'] ?? json['createdAt'] ?? DateTime.now().toIso8601String()).toString(),
      createdAt: (json['createdAt'] ?? json['timestamp'] ?? DateTime.now().toIso8601String()).toString(),
    );
  }
}

class ChatConversationModel {
  final String id;
  final List<String> participantIds;
  final Map<String, String> participantNames;
  final ChatMessageModel? lastMessage;
  final int unreadCount;
  final String lastUpdated;
  final String createdAt;

  const ChatConversationModel({
    required this.id,
    this.participantIds = const [],
    this.participantNames = const {},
    this.lastMessage,
    this.unreadCount = 0,
    required this.lastUpdated,
    required this.createdAt,
  });

  factory ChatConversationModel.fromJson(Map<String, dynamic> json) {
    final ids = (json['participantIds'] as List? ?? [])
        .map((e) => e.toString())
        .toList();

    final rawNames = json['participantNames'];
    final Map<String, String> names = {};
    if (rawNames is Map) {
      rawNames.forEach((key, value) {
        names[key.toString()] = value.toString();
      });
    }

    ChatMessageModel? lastMsg;
    if (json['lastMessage'] is Map<String, dynamic>) {
      lastMsg = ChatMessageModel.fromJson(json['lastMessage'] as Map<String, dynamic>);
    }

    return ChatConversationModel(
      id: (json['id'] ?? json['chatId'] ?? '').toString(),
      participantIds: ids,
      participantNames: names,
      lastMessage: lastMsg,
      unreadCount: int.tryParse((json['unreadCount'] ?? 0).toString()) ?? 0,
      lastUpdated: (json['lastUpdated'] ?? json['updatedAt'] ?? DateTime.now().toIso8601String()).toString(),
      createdAt: (json['createdAt'] ?? DateTime.now().toIso8601String()).toString(),
    );
  }

  String otherParticipantName(String myId) {
    final otherIds = participantIds.where((id) => id != myId);
    if (otherIds.isEmpty) return 'Specialist';
    return otherIds.map((id) => participantNames[id] ?? 'Specialist').join(', ');
  }
}
