// models/booking.dart
class BookingModel {
  final String id;
  final String parentId;
  final String parentName;
  final String childId;
  final String childName;
  final String specialistId;
  final String specialistType; // 'doctor' | 'therapist'
  final String status; // 'pending'|'approved'|'completed'|'cancelled'|'scheduled'|'confirmed'
  final String appointmentDate;
  final String appointmentTime;
  final int duration;
  final String? notes;
  final String? reason;
  final String? specialistName;
  final String? joinLink;
  final String? zoomUrl;
  final String? therapistName;
  final String? doctorName;
  final String createdAt;
  final String updatedAt;

  const BookingModel({
    required this.id,
    this.parentId = '',
    this.parentName = '',
    this.childId = '',
    this.childName = '',
    required this.specialistId,
    required this.specialistType,
    required this.status,
    required this.appointmentDate,
    required this.appointmentTime,
    this.duration = 60,
    this.notes,
    this.reason,
    this.specialistName,
    this.joinLink,
    this.zoomUrl,
    this.therapistName,
    this.doctorName,
    required this.createdAt,
    required this.updatedAt,
  });

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    return BookingModel(
      id: (json['id'] ?? json['bookingId'] ?? '').toString(),
      parentId: (json['parentId'] ?? '').toString(),
      parentName: (json['parentName'] ?? '').toString(),
      childId: (json['childId'] ?? '').toString(),
      childName: (json['childName'] ?? '').toString(),
      specialistId: (json['specialistId'] ?? json['doctorId'] ?? json['therapistId'] ?? '').toString(),
      specialistType: (json['specialistType'] ?? json['type'] ?? 'doctor').toString(),
      status: (json['status'] ?? 'pending').toString(),
      appointmentDate: (json['appointmentDate'] ?? json['dateTime'] ?? '').toString(),
      appointmentTime: (json['appointmentTime'] ?? '').toString(),
      duration: int.tryParse((json['duration'] ?? 60).toString()) ?? 60,
      notes: json['notes']?.toString(),
      reason: json['reason']?.toString(),
      specialistName: json['specialistName']?.toString(),
      joinLink: json['joinLink']?.toString(),
      zoomUrl: json['zoomUrl']?.toString() ?? json['zoomLink']?.toString(),
      therapistName: json['therapistName']?.toString(),
      doctorName: json['doctorName']?.toString(),
      createdAt: (json['createdAt'] ?? DateTime.now().toIso8601String()).toString(),
      updatedAt: (json['updatedAt'] ?? DateTime.now().toIso8601String()).toString(),
    );
  }
}
