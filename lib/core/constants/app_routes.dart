class AppRoutes {
  AppRoutes._();

  // Auth
  static const String login = '/login';
  static const String signup = '/signup';
  static const String forgotPassword = '/forgot-password';

  // Parent
  static const String parentHome = '/parent/home';
  static const String addChild = '/parent/add-child';
  static const String screening = '/parent/screening';
  static const String screeningResults = '/parent/screening-results';
  static const String doctors = '/parent/doctors';
  static const String therapists = '/parent/therapists';
  static const String specialistDetail = '/parent/specialist/:id';
  static const String bookSpecialist = '/parent/book/:id';
  static const String myBookings = '/parent/bookings';
  static const String parentSessions = '/parent/sessions';
  static const String parentReScreening = '/parent/re-screening';
  static const String parentChat = '/parent/chat';
  static const String parentChatConversation = '/parent/chat/:chatId';

  // Doctor / Specialist
  static const String doctorHome = '/doctor/home';
  static const String doctorPatients = '/doctor/patients';
  static const String patientDetail = '/doctor/patients/:id';
  static const String doctorSessions = '/doctor/sessions';
  static const String doctorChat = '/doctor/chat';

  // Therapist
  static const String therapistHome = '/therapist/home';
  static const String therapistPatients = '/therapist/patients';
  static const String therapistSessions = '/therapist/sessions';
  static const String therapistChat = '/therapist/chat';
}
