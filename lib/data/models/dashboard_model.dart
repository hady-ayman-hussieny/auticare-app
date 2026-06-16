/// Dashboard model — mirrors DashboardSpecialistData from React dashboard.ts
class DashboardSpecialistModel {
  final int patientCount;
  final int activeCases;
  final int upcomingSessions;
  final int todaySessions;
  final int totalSessions;
  final int completedSessions;
  final int pendingRequests;
  final int unreadMessages;
  final int pendingPlans;
  final List<dynamic> patientCards;

  const DashboardSpecialistModel({
    this.patientCount = 0,
    this.activeCases = 0,
    this.upcomingSessions = 0,
    this.todaySessions = 0,
    this.totalSessions = 0,
    this.completedSessions = 0,
    this.pendingRequests = 0,
    this.unreadMessages = 0,
    this.pendingPlans = 0,
    this.patientCards = const [],
  });

  factory DashboardSpecialistModel.fromJson(Map<String, dynamic> json) {
    int i(String key) =>
        int.tryParse((json[key] ?? 0).toString()) ?? 0;
    return DashboardSpecialistModel(
      patientCount: i('patientCount'),
      activeCases: i('activeCases'),
      upcomingSessions: i('upcomingSessions'),
      todaySessions: i('todaySessions'),
      totalSessions: i('totalSessions'),
      completedSessions: i('completedSessions'),
      pendingRequests: i('pendingRequests'),
      unreadMessages: i('unreadMessages'),
      pendingPlans: i('pendingPlans'),
      patientCards: json['patientCards'] is List ? json['patientCards'] as List : const [],
    );
  }

  static const empty = DashboardSpecialistModel();
}

/// Dashboard model for parent role
class DashboardParentModel {
  final int childrenCount;
  final int upcomingScreenings;
  final int upcomingSessions;

  const DashboardParentModel({
    this.childrenCount = 0,
    this.upcomingScreenings = 0,
    this.upcomingSessions = 0,
  });

  factory DashboardParentModel.fromJson(Map<String, dynamic> json) {
    int i(String key) =>
        int.tryParse((json[key] ?? 0).toString()) ?? 0;
    return DashboardParentModel(
      childrenCount: i('childrenCount'),
      upcomingScreenings: i('upcomingScreenings'),
      upcomingSessions: i('upcomingSessions'),
    );
  }

  static const empty = DashboardParentModel();
}
