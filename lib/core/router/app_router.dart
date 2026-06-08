import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:auticare/features/auth/logic/auth_provider.dart';
import 'package:auticare/core/constants/app_routes.dart';

// Screens – Auth
import 'package:auticare/features/auth/screens/login_screen.dart';
import 'package:auticare/features/auth/screens/signup_screen.dart';
import 'package:auticare/features/auth/screens/forgot_password_screen.dart';

// Screens – Parent
import 'package:auticare/features/parent/screens/parent_home_screen.dart';
import 'package:auticare/features/parent/screens/add_child_screen.dart';
import 'package:auticare/features/screening/screens/parent_re_screening_screen.dart';
import 'package:auticare/features/screening/screens/screening_screen.dart';
import 'package:auticare/features/screening/screens/screening_results_screen.dart';
import 'package:auticare/features/specialists/screens/doctors_screen.dart';
import 'package:auticare/features/specialists/screens/therapists_screen.dart';
import 'package:auticare/features/specialists/screens/specialist_detail_screen.dart';
import 'package:auticare/features/bookings/screens/book_specialist_screen.dart';
import 'package:auticare/features/bookings/screens/my_bookings_screen.dart';
import 'package:auticare/features/sessions/screens/parent_sessions_screen.dart';

// Screens – Doctor
import 'package:auticare/features/doctor/screens/doctor_home_screen.dart';
import 'package:auticare/features/doctor/screens/doctor_patients_screen.dart';
import 'package:auticare/features/doctor/screens/patient_detail_screen.dart';
import 'package:auticare/features/sessions/screens/doctor_sessions_screen.dart';

// Screens – Therapist
import 'package:auticare/features/therapist/screens/therapist_home_screen.dart';

// Screens – Chat
import 'package:auticare/features/chat/screens/chat_screen.dart';

// Screens – Treatment Plans
import 'package:auticare/features/treatment_plans/screens/treatment_plan_screen.dart';

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
        if (role == 'doctor' || role == 'specialist') {
          return AppRoutes.doctorHome;
        } else if (role == 'therapist') {
          return AppRoutes.therapistHome;
        } else {
          return AppRoutes.parentHome;
        }
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
      GoRoute(
        path: AppRoutes.parentReScreening,
        builder: (_, __) => const ParentReScreeningScreen(),
      ),
      GoRoute(
        path: AppRoutes.parentChat,
        builder: (_, __) => const ChatScreen(),
      ),
      GoRoute(
        path: '/parent/chat/:chatId',
        builder: (_, state) {
          final chatId = state.pathParameters['chatId']!;
          return ChatScreen(initialChatId: chatId);
        },
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
      GoRoute(
        path: AppRoutes.doctorChat,
        builder: (_, __) => const ChatScreen(),
      ),

      // ── Therapist ─────────────────────────────────────────────────────────
      GoRoute(
        path: AppRoutes.therapistHome,
        builder: (_, __) => const TherapistHomeScreen(),
      ),
      GoRoute(
        path: AppRoutes.therapistPatients,
        builder: (_, __) => const DoctorPatientsScreen(),
      ),
      GoRoute(
        path: '/therapist/patients/:id',
        builder: (_, state) {
          final id = state.pathParameters['id']!;
          return PatientDetailScreen(childId: id);
        },
      ),
      GoRoute(
        path: AppRoutes.therapistSessions,
        builder: (_, __) => const DoctorSessionsScreen(),
      ),
      GoRoute(
        path: AppRoutes.therapistChat,
        builder: (_, __) => const ChatScreen(),
      ),

      // ── Shared Treatment Plan Route ────────────────────────────────────────
      GoRoute(
        path: '/treatment-plan/:childId',
        builder: (_, state) {
          final childId = state.pathParameters['childId']!;
          return TreatmentPlanScreen(childId: childId);
        },
      ),
    ],
  );
}
