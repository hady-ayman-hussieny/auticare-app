/// TreatmentPlan model — mirrors TreatmentPlan type from React treatmentPlans.ts
class TreatmentPlanModel {
  final String id;
  final String childId;
  final String specialistId;
  final String specialistName;
  final String title;
  final String description;
  final List<String> goals;
  final List<String> recommendations;
  final List<String> homeActivities;
  final List<String> assignedTherapists;
  final String status;
  final String startDate;
  final String? endDate;
  final String notes;
  final String createdAt;
  final String updatedAt;

  const TreatmentPlanModel({
    required this.id,
    required this.childId,
    required this.specialistId,
    this.specialistName = '',
    required this.title,
    this.description = '',
    this.goals = const [],
    this.recommendations = const [],
    this.homeActivities = const [],
    this.assignedTherapists = const [],
    required this.status,
    required this.startDate,
    this.endDate,
    this.notes = '',
    required this.createdAt,
    required this.updatedAt,
  });

  factory TreatmentPlanModel.fromJson(Map<String, dynamic> json) {
    List<String> strList(dynamic val) {
      if (val is List) return val.map((e) => e.toString()).toList();
      if (val is String && val.isNotEmpty) {
        return val.split('\n').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
      }
      return [];
    }

    final id = (json['id'] ?? json['treatmentId'] ?? '').toString();
    final goalRaw = json['goals'] ?? json['goal'];
    final goals = strList(goalRaw);

    return TreatmentPlanModel(
      id: id,
      childId: (json['childId'] ?? '').toString(),
      specialistId: (json['specialistId'] ?? json['doctorId'] ?? '').toString(),
      specialistName: (json['specialistName'] ?? '').toString(),
      title: (json['title'] ?? json['notes']?.toString().split('\n').first ?? 'Treatment Plan').toString(),
      description: (json['description'] ?? json['notes'] ?? '').toString(),
      goals: goals,
      recommendations: strList(json['recommendations']),
      homeActivities: strList(json['homeActivities']),
      assignedTherapists: strList(json['assignedTherapists']),
      status: (json['status'] ?? 'active').toString(),
      startDate: (json['startDate'] ?? json['createdAt'] ?? '').toString(),
      endDate: json['endDate']?.toString(),
      notes: (json['notes'] ?? '').toString(),
      createdAt: (json['createdAt'] ?? DateTime.now().toIso8601String()).toString(),
      updatedAt: (json['updatedAt'] ?? json['createdAt'] ?? DateTime.now().toIso8601String()).toString(),
    );
  }
}
