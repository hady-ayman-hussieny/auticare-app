// Therapy session model lives here too, alongside NotificationModel
class TherapySessionModel {
  final String id;
  final String treatmentPlanId;
  final String therapistId;
  final String childId;
  final String title;
  final String? description;
  final String scheduledDate;
  final String scheduledTime;
  final int duration;
  final String status;
  final String? notes;
  final String? joinLink;
  final String createdAt;

  const TherapySessionModel({
    required this.id,
    required this.treatmentPlanId,
    required this.therapistId,
    required this.childId,
    required this.title,
    this.description,
    required this.scheduledDate,
    required this.scheduledTime,
    required this.duration,
    required this.status,
    this.notes,
    this.joinLink,
    required this.createdAt,
  });

  factory TherapySessionModel.fromJson(Map<String, dynamic> json) {
    return TherapySessionModel(
      id: (json['id'] ?? '').toString(),
      treatmentPlanId: (json['treatmentPlanId'] ?? '').toString(),
      therapistId: (json['therapistId'] ?? '').toString(),
      childId: (json['childId'] ?? '').toString(),
      title: (json['title'] ?? 'Session').toString(),
      description: json['description']?.toString(),
      scheduledDate: (json['scheduledDate'] ?? '').toString(),
      scheduledTime: (json['scheduledTime'] ?? '').toString(),
      duration: int.tryParse((json['duration'] ?? 60).toString()) ?? 60,
      status: (json['status'] ?? 'scheduled').toString(),
      notes: json['notes']?.toString(),
      joinLink: json['joinLink']?.toString(),
      createdAt: (json['createdAt'] ?? DateTime.now().toIso8601String()).toString(),
    );
  }
}

class NotificationModel {
  final String id;
  final String userId;
  final String type;
  final String title;
  final String message;
  final String? relatedId;
  final bool isRead;
  final String createdAt;

  const NotificationModel({
    required this.id,
    required this.userId,
    required this.type,
    required this.title,
    required this.message,
    this.relatedId,
    required this.isRead,
    required this.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: (json['id'] ?? '').toString(),
      userId: (json['userId'] ?? '').toString(),
      type: (json['type'] ?? 'system').toString(),
      title: (json['title'] ?? '').toString(),
      message: (json['message'] ?? '').toString(),
      relatedId: json['relatedId']?.toString(),
      isRead: json['isRead'] == true,
      createdAt: (json['createdAt'] ?? DateTime.now().toIso8601String()).toString(),
    );
  }
}
