import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../core/constants.dart';
import '../core/theme/app_colors.dart';

/// Shared scaffold with bottom navigation for parent & doctor roles.
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
    final isDoctor = role == 'doctor' || role == 'therapist';

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
              child: const Icon(Icons.favorite_rounded, color: Colors.white, size: 16),
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
                  style: TextStyle(color: AppColors.slate400, fontSize: 18)),
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
                      style: const TextStyle(fontWeight: FontWeight.w600),
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
      bottomNavigationBar: isDoctor
          ? _DoctorBottomNav(context: context)
          : _ParentBottomNav(context: context),
    );
  }
}

class _ParentBottomNav extends StatelessWidget {
  final BuildContext context;
  const _ParentBottomNav({required this.context});

  @override
  Widget build(BuildContext ctx) {
    final location = GoRouterState.of(ctx).matchedLocation;
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
    }

    return NavigationBar(
      selectedIndex: index,
      onDestinationSelected: (i) {
        switch (i) {
          case 0:
            ctx.go(AppRoutes.parentHome);
          case 1:
            ctx.go(AppRoutes.doctors);
          case 2:
            ctx.go(AppRoutes.myBookings);
          case 3:
            ctx.go(AppRoutes.parentSessions);
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
      ],
    );
  }
}

class _DoctorBottomNav extends StatelessWidget {
  final BuildContext context;
  const _DoctorBottomNav({required this.context});

  @override
  Widget build(BuildContext ctx) {
    final location = GoRouterState.of(ctx).matchedLocation;
    int index = 0;
    if (location.startsWith('/doctor/patients')) index = 1;
    if (location.startsWith('/doctor/sessions')) index = 2;

    return NavigationBar(
      selectedIndex: index,
      onDestinationSelected: (i) {
        switch (i) {
          case 0:
            ctx.go(AppRoutes.doctorHome);
          case 1:
            ctx.go(AppRoutes.doctorPatients);
          case 2:
            ctx.go(AppRoutes.doctorSessions);
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
      ],
    );
  }
}
