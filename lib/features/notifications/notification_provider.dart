import 'package:flutter/foundation.dart';
import 'package:auticare/data/models/notification_model.dart';
import 'package:auticare/data/services/notifications_service.dart';

class NotificationProvider extends ChangeNotifier {
  List<NotificationModel> _notifications = [];
  int _unreadCount = 0;
  bool _loading = false;

  List<NotificationModel> get notifications => _notifications;
  int get unreadCount => _unreadCount;
  bool get loading => _loading;

  Future<void> load({int? limit}) async {
    _loading = true;
    notifyListeners();
    try {
      _notifications = await notificationsService.getNotifications(limit: limit);
      _unreadCount = _notifications.where((n) => !n.isRead).length;
    } catch (_) {}
    _loading = false;
    notifyListeners();
  }

  Future<void> markAsRead(String id) async {
    await notificationsService.markAsRead(id);
    _notifications = _notifications
        .map((n) => n.id == id ? _markRead(n) : n)
        .toList();
    _unreadCount = _notifications.where((n) => !n.isRead).length;
    notifyListeners();
  }

  NotificationModel _markRead(NotificationModel n) {
    return NotificationModel(
      id: n.id,
      userId: n.userId,
      type: n.type,
      title: n.title,
      message: n.message,
      relatedId: n.relatedId,
      isRead: true,
      createdAt: n.createdAt,
    );
  }
}
