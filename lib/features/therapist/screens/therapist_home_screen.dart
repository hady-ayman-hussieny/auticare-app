import 'package:flutter/material.dart';
import 'package:auticare/features/doctor/screens/doctor_home_screen.dart';

/// TherapistHomeScreen re-uses DoctorHomeScreen exactly.
/// Per React source: TherapistHome = DoctorHome (TherapistPages.tsx).
/// The DoctorHomeScreen reads the user role from AuthProvider to
/// differentiate "Dr." vs "Therapist" greeting and adjust navigation.
class TherapistHomeScreen extends StatelessWidget {
  const TherapistHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const DoctorHomeScreen();
  }
}
