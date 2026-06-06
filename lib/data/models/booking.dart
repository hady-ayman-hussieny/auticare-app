// models/booking.dart
class BookingModel {
  final String id;
  final String parentId;
  final String childId;
  final String specialistId;
  final String specialistType; // 'doctor' | 'therapist'
  final String status; // 'pending'|'approved'|'completed'|'cancelled'|'scheduled'|'confirmed'
  final String appointmentDate;
  final String appointmentTime;
  final int duration;
  final String? notes;
  final String? specialistName;
  final String? joinLink;
  final String createdAt;
  final String updatedAt;

  const BookingModel({
    required this.id,
    required this.parentId,
    required this.childId,
    required this.specialistId,
    required this.specialistType,
    required this.status,
    required this.appointmentDate,
    required this.appointmentTime,
    required this.duration,
    this.notes,
    this.specialistName,
    this.joinLink,
    required this.createdAt,
    required this.updatedAt,
  });

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    return BookingModel(
      id: (json['id'] ?? '').toString(),
      parentId: (json['parentId'] ?? '').toString(),
      childId: (json['childId'] ?? '').toString(),
      specialistId: (json['specialistId'] ?? '').toString(),
      specialistType: (json['specialistType'] ?? 'doctor').toString(),
      status: (json['status'] ?? 'pending').toString(),
      appointmentDate: (json['appointmentDate'] ?? json['dateTime'] ?? '').toString(),
      appointmentTime: (json['appointmentTime'] ?? '').toString(),
      duration: int.tryParse((json['duration'] ?? 60).toString()) ?? 60,
      notes: json['notes']?.toString() ?? json['reason']?.toString(),
      specialistName: json['specialistName']?.toString(),
      joinLink: json['joinLink']?.toString(),
      createdAt: (json['createdAt'] ?? DateTime.now().toIso8601String()).toString(),
      updatedAt: (json['updatedAt'] ?? DateTime.now().toIso8601String()).toString(),
    );
  }
}
