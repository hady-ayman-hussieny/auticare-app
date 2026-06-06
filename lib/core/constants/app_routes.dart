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

  // Doctor / Specialist
  static const String doctorHome = '/doctor/home';
  static const String doctorPatients = '/doctor/patients';
  static const String patientDetail = '/doctor/patients/:id';
  static const String doctorSessions = '/doctor/sessions';
}
