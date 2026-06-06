import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../providers/auth_provider.dart';
import '../core/constants.dart';

// Screens – Auth
import '../screens/auth/login_screen.dart';
import '../screens/auth/signup_screen.dart';
import '../screens/auth/forgot_password_screen.dart';

// Screens – Parent
import '../screens/parent/parent_home_screen.dart';
import '../screens/parent/add_child_screen.dart';
import '../screens/parent/screening_screen.dart';
import '../screens/parent/screening_results_screen.dart';
import '../screens/parent/doctors_screen.dart';
import '../screens/parent/therapists_screen.dart';
import '../screens/parent/specialist_detail_screen.dart';
import '../screens/parent/book_specialist_screen.dart';
import '../screens/parent/my_bookings_screen.dart';
import '../screens/parent/parent_sessions_screen.dart';

// Screens – Doctor
import '../screens/doctor/doctor_home_screen.dart';
import '../screens/doctor/doctor_patients_screen.dart';
import '../screens/doctor/patient_detail_screen.dart';
import '../screens/doctor/doctor_sessions_screen.dart';

GoRouter buildRouter(AuthProvider authProvider) {
  return GoRouter(
    refreshListenable: authProvider,
    initialLocation: AppRoutes.login,
    redirect: (BuildContext context, GoRouterState state) {
      final status = authProvider.status;
      final location = state.matchedLocation;

      // Still loading
      if (status == AuthStatus.unknown) return null;

      final authRoutes = [
        AppRoutes.login,
        AppRoutes.signup,
        AppRoutes.forgotPassword,
      ];
      final isOnAuth = authRoutes.any((r) => location.startsWith(r));

      if (status == AuthStatus.unauthenticated && !isOnAuth) {
        return AppRoutes.login;
      }

      if (status == AuthStatus.authenticated && isOnAuth) {
        final role = authProvider.user?.role ?? 'parent';
        return role == 'doctor' || role == 'therapist'
            ? AppRoutes.doctorHome
            : AppRoutes.parentHome;
      }

      return null;
    },
    routes: [
      // ── Auth ──────────────────────────────────────────────────────────────
      GoRoute(path: AppRoutes.login, builder: (_, __) => const LoginScreen()),
      GoRoute(path: AppRoutes.signup, builder: (_, __) => const SignupScreen()),
      GoRoute(
        path: AppRoutes.forgotPassword,
        builder: (_, __) => const ForgotPasswordScreen(),
      ),

      // ── Parent ────────────────────────────────────────────────────────────
      GoRoute(
        path: AppRoutes.parentHome,
        builder: (_, __) => const ParentHomeScreen(),
      ),
      GoRoute(
        path: AppRoutes.addChild,
        builder: (_, __) => const AddChildScreen(),
      ),
      GoRoute(
        path: AppRoutes.screening,
        builder: (_, state) {
          final childId = state.uri.queryParameters['childId'];
          return ScreeningScreen(childId: childId);
        },
      ),
      GoRoute(
        path: AppRoutes.screeningResults,
        builder: (_, state) {
          final childId = state.uri.queryParameters['childId'] ?? '';
          return ScreeningResultsScreen(childId: childId);
        },
      ),
      GoRoute(
        path: AppRoutes.doctors,
        builder: (_, __) => const DoctorsScreen(),
      ),
      GoRoute(
        path: AppRoutes.therapists,
        builder: (_, __) => const TherapistsScreen(),
      ),
      GoRoute(
        path: '/parent/specialist/:id',
        builder: (_, state) {
          final id = state.pathParameters['id']!;
          final type = state.uri.queryParameters['type'] ?? 'doctor';
          return SpecialistDetailScreen(specialistId: id, type: type);
        },
      ),
      GoRoute(
        path: '/parent/book/:id',
        builder: (_, state) {
          final id = state.pathParameters['id']!;
          final type = state.uri.queryParameters['type'] ?? 'doctor';
          return BookSpecialistScreen(specialistId: id, type: type);
        },
      ),
      GoRoute(
        path: AppRoutes.myBookings,
        builder: (_, __) => const MyBookingsScreen(),
      ),
      GoRoute(
        path: AppRoutes.parentSessions,
        builder: (_, __) => const ParentSessionsScreen(),
      ),

      // ── Doctor / Specialist ───────────────────────────────────────────────
      GoRoute(
        path: AppRoutes.doctorHome,
        builder: (_, __) => const DoctorHomeScreen(),
      ),
      GoRoute(
        path: AppRoutes.doctorPatients,
        builder: (_, __) => const DoctorPatientsScreen(),
      ),
      GoRoute(
        path: '/doctor/patients/:id',
        builder: (_, state) {
          final id = state.pathParameters['id']!;
          return PatientDetailScreen(childId: id);
        },
      ),
      GoRoute(
        path: AppRoutes.doctorSessions,
        builder: (_, __) => const DoctorSessionsScreen(),
      ),
    ],
  );
}
