import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:auticare/features/auth/logic/auth_provider.dart';
import 'package:auticare/core/constants/app_routes.dart';
import 'package:auticare/core/theme/app_colors.dart';

/// Shared scaffold with role-based bottom navigation.
class AppShell extends StatelessWidget {
  final Widget child;
  final String title;
  final List<Widget>? actions;
  final bool showBack;

  const AppShell({
    super.key,
    required this.child,
    required this.title,
    this.actions,
    this.showBack = false,
  });

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final role = auth.user?.role ?? 'parent';

    Widget? bottomNav;
    if (role == 'doctor') {
      bottomNav = const _DoctorBottomNav();
    } else if (role == 'therapist') {
      bottomNav = const _TherapistBottomNav();
    } else {
      bottomNav = const _ParentBottomNav();
    }

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: showBack,
        title: Row(
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradientLight,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.favorite_rounded,
                  color: Colors.white, size: 16),
            ),
            const SizedBox(width: 8),
            Text(
              'AutiCare',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                  ),
            ),
            if (title.isNotEmpty) ...[
              const SizedBox(width: 8),
              const Text('·',
                  style:
                      TextStyle(color: AppColors.slate400, fontSize: 18)),
              const SizedBox(width: 8),
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppColors.mutedLight,
                      fontWeight: FontWeight.w500,
                    ),
              ),
            ],
          ],
        ),
        actions: [
          if (actions != null) ...actions!,
          PopupMenuButton<String>(
            icon: CircleAvatar(
              radius: 16,
              backgroundColor: AppColors.orange100,
              child: Text(
                (auth.user?.name ?? 'U').substring(0, 1).toUpperCase(),
                style: const TextStyle(
                  color: AppColors.accentLight,
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
            ),
            onSelected: (value) async {
              if (value == 'logout') {
                await auth.logout();
              }
            },
            itemBuilder: (_) => [
              PopupMenuItem(
                enabled: false,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      auth.user?.name ?? '',
                      style:
                          const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    Text(
                      auth.user?.email ?? '',
                      style: const TextStyle(
                          fontSize: 12, color: AppColors.slate500),
                    ),
                  ],
                ),
              ),
              const PopupMenuDivider(),
              const PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout_rounded, size: 18),
                    SizedBox(width: 10),
                    Text('Sign Out'),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: child,
      bottomNavigationBar: bottomNav,
    );
  }
}

// ─── Parent Bottom Nav ────────────────────────────────────────────────────────
class _ParentBottomNav extends StatelessWidget {
  const _ParentBottomNav();

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    int index = 0;
    if (location.startsWith('/parent/doctors') ||
        location.startsWith('/parent/therapists') ||
        location.startsWith('/parent/specialist')) {
      index = 1;
    } else if (location.startsWith('/parent/book') ||
        location.startsWith('/parent/bookings')) {
      index = 2;
    } else if (location.startsWith('/parent/sessions')) {
      index = 3;
    } else if (location.startsWith('/parent/chat')) {
      index = 4;
    }

    return NavigationBar(
      selectedIndex: index,
      onDestinationSelected: (i) {
        switch (i) {
          case 0:
            context.go(AppRoutes.parentHome);
          case 1:
            context.go(AppRoutes.doctors);
          case 2:
            context.go(AppRoutes.myBookings);
          case 3:
            context.go(AppRoutes.parentSessions);
          case 4:
            context.go(AppRoutes.parentChat);
        }
      },
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.home_outlined),
          selectedIcon: Icon(Icons.home_rounded),
          label: 'Home',
        ),
        NavigationDestination(
          icon: Icon(Icons.medical_services_outlined),
          selectedIcon: Icon(Icons.medical_services_rounded),
          label: 'Specialists',
        ),
        NavigationDestination(
          icon: Icon(Icons.calendar_today_outlined),
          selectedIcon: Icon(Icons.calendar_today_rounded),
          label: 'Bookings',
        ),
        NavigationDestination(
          icon: Icon(Icons.video_call_outlined),
          selectedIcon: Icon(Icons.video_call_rounded),
          label: 'Sessions',
        ),
        NavigationDestination(
          icon: Icon(Icons.chat_bubble_outline_rounded),
          selectedIcon: Icon(Icons.chat_bubble_rounded),
          label: 'Chat',
        ),
      ],
    );
  }
}

// ─── Doctor Bottom Nav ────────────────────────────────────────────────────────
class _DoctorBottomNav extends StatelessWidget {
  const _DoctorBottomNav();

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    int index = 0;
    if (location.startsWith('/doctor/patients')) index = 1;
    if (location.startsWith('/doctor/sessions')) index = 2;
    if (location.startsWith('/doctor/chat')) index = 3;

    return NavigationBar(
      selectedIndex: index,
      onDestinationSelected: (i) {
        switch (i) {
          case 0:
            context.go(AppRoutes.doctorHome);
          case 1:
            context.go(AppRoutes.doctorPatients);
          case 2:
            context.go(AppRoutes.doctorSessions);
          case 3:
            context.go(AppRoutes.doctorChat);
        }
      },
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.dashboard_outlined),
          selectedIcon: Icon(Icons.dashboard_rounded),
          label: 'Dashboard',
        ),
        NavigationDestination(
          icon: Icon(Icons.people_outline_rounded),
          selectedIcon: Icon(Icons.people_rounded),
          label: 'Patients',
        ),
        NavigationDestination(
          icon: Icon(Icons.video_call_outlined),
          selectedIcon: Icon(Icons.video_call_rounded),
          label: 'Sessions',
        ),
        NavigationDestination(
          icon: Icon(Icons.chat_bubble_outline_rounded),
          selectedIcon: Icon(Icons.chat_bubble_rounded),
          label: 'Chat',
        ),
      ],
    );
  }
}

// ─── Therapist Bottom Nav ─────────────────────────────────────────────────────
class _TherapistBottomNav extends StatelessWidget {
  const _TherapistBottomNav();

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    int index = 0;
    if (location.startsWith('/therapist/patients')) index = 1;
    if (location.startsWith('/therapist/sessions')) index = 2;
    if (location.startsWith('/therapist/chat')) index = 3;

    return NavigationBar(
      selectedIndex: index,
      onDestinationSelected: (i) {
        switch (i) {
          case 0:
            context.go(AppRoutes.therapistHome);
          case 1:
            context.go(AppRoutes.therapistPatients);
          case 2:
            context.go(AppRoutes.therapistSessions);
          case 3:
            context.go(AppRoutes.therapistChat);
        }
      },
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.dashboard_outlined),
          selectedIcon: Icon(Icons.dashboard_rounded),
          label: 'Dashboard',
        ),
        NavigationDestination(
          icon: Icon(Icons.people_outline_rounded),
          selectedIcon: Icon(Icons.people_rounded),
          label: 'Patients',
        ),
        NavigationDestination(
          icon: Icon(Icons.video_call_outlined),
          selectedIcon: Icon(Icons.video_call_rounded),
          label: 'Sessions',
        ),
        NavigationDestination(
          icon: Icon(Icons.chat_bubble_outline_rounded),
          selectedIcon: Icon(Icons.chat_bubble_rounded),
          label: 'Chat',
        ),
      ],
    );
  }
}
