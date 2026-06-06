import 'package:auticare/data/models/notification_model.dart';
import 'package:auticare/data/services/api_client.dart';

class NotificationsService {
  Future<List<NotificationModel>> getNotifications({int? limit}) async {
    try {
      final res = await api.get<dynamic>(
        '/notifications',
        params: limit != null ? {'limit': limit} : null,
      );
      final list = res.data is List ? res.data as List : [];
      return list
          .whereType<Map<String, dynamic>>()
          .map(NotificationModel.fromJson)
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<int> getUnreadCount() async {
    try {
      final res = await api.get<Map<String, dynamic>>('/notifications/unread-count');
      return (res.data?['count'] as int?) ?? 0;
    } catch (_) {
      return 0;
    }
  }

  Future<void> markAsRead(String id) async {
    try {
      await api.put('/notifications/$id/read');
    } catch (_) {}
  }

  Future<void> markAllAsRead() async {
    try {
      await api.put('/notifications/read-all');
    } catch (_) {}
  }

  Future<void> deleteNotification(String id) async {
    try {
      await api.delete('/notifications/$id');
    } catch (_) {}
  }
}

final notificationsService = NotificationsService();
