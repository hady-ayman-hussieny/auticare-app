import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:auticare/features/auth/logic/auth_provider.dart';
import 'package:auticare/core/constants/app_routes.dart';
import 'package:auticare/core/theme/app_colors.dart';

// Complete mock models to satisfy UI representation
class MockChild {
  final String id;
  final String name;
  final String? profileImage;
  final int age;
  final String gender;

  const MockChild({
    required this.id,
    required this.name,
    this.profileImage,
    required this.age,
    required this.gender,
  });
}

class MockTreatmentPlan {
  final String id;
  final String childId;
  final String title;
  final String description;
  final String status;

  const MockTreatmentPlan({
    required this.id,
    required this.childId,
    required this.title,
    required this.description,
    required this.status,
  });
}

class MockNotification {
  final String id;
  final String title;
  final String message;
  final bool isRead;
  final DateTime createdAt;

  const MockNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.isRead,
    required this.createdAt,
  });
}

class MockNote {
  final String id;
  final String title;
  final String content;
  final DateTime createdAt;

  const MockNote({
    required this.id,
    required this.title,
    required this.content,
    required this.createdAt,
  });
}

class ParentHomeScreen extends StatefulWidget {
  const ParentHomeScreen({super.key});

  @override
  State<ParentHomeScreen> createState() => _ParentHomeScreenState();
}

class _ParentHomeScreenState extends State<ParentHomeScreen> {
  // Static mock data to match React ParentHome.tsx features
  final List<MockChild> _children = [
    const MockChild(id: 'c1', name: 'Liam Archer', age: 4, gender: 'Male'),
    const MockChild(id: 'c2', name: 'Sophia Archer', age: 6, gender: 'Female'),
  ];

  final List<MockTreatmentPlan> _plans = [
    const MockTreatmentPlan(
      id: 'p1',
      childId: 'c1',
      title: 'Speech & Language Protocol',
      description: 'Focusing on phonetics development, visual prompts, and daily vocabulary routines.',
      status: 'Active',
    ),
    const MockTreatmentPlan(
      id: 'p2',
      childId: 'c2',
      title: 'Social Interaction Guideline',
      description: 'Structured group play therapy, emotion regulation, and collaborative learning games.',
      status: 'In Progress',
    ),
  ];

  final List<MockNotification> _notifications = [
    MockNotification(
      id: 'n1',
      title: 'Treatment Plan Updated',
      message: 'Liam\'s Speech Protocol has been updated by Dr. Sarah Jenkins.',
      isRead: false,
      createdAt: DateTime.now().subtract(const Duration(minutes: 45)),
    ),
    MockNotification(
      id: 'n2',
      title: 'New Session Note',
      message: 'Therapist Emma Watson added guidelines for Sophia\'s home exercises.',
      isRead: false,
      createdAt: DateTime.now().subtract(const Duration(hours: 3)),
    ),
    MockNotification(
      id: 'n3',
      title: 'Booking Confirmed',
      message: 'Consultation with Dr. Jenkins scheduled for Thursday at 10:00 AM.',
      isRead: true,
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
    MockNotification(
      id: 'n4',
      title: 'Assessment Complete',
      message: 'Liam\'s developmental screening scoring has been calculated.',
      isRead: true,
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
  ];

  final List<MockNote> _notes = [
    MockNote(
      id: 'nt1',
      title: 'Communication Exercises',
      content: 'Incorporate 15 minutes of structured pointing and picture exchange communication system (PECS) prompts before dinner.',
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
    MockNote(
      id: 'nt2',
      title: 'Sensory Overload Recovery',
      content: 'In case of sensory triggers, use the noise-cancelling headphones and direct Liam to the designated quiet corner for 10 minutes.',
      createdAt: DateTime.now().subtract(const Duration(days: 3)),
    ),
  ];

  void _handleStartScreening() {
    // Navigate to screening using first child id or generic add-child if empty
    if (_children.isNotEmpty) {
      context.go('${AppRoutes.screening}?childId=${_children.first.id}');
    } else {
      context.go(AppRoutes.addChild);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final firstName = (auth.user?.name ?? 'Parent').split(' ').first;

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async {
          // Trigger a simulated refresh reload state
          await Future.delayed(const Duration(milliseconds: 500));
          if (mounted) setState(() {});
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Welcome Hero Banner
              _buildWelcomeBanner(isDark, theme, firstName),
              const SizedBox(height: 24),

              // 2. Quick Stats Grid
              _buildStatsGrid(theme, isDark),
              const SizedBox(height: 24),

              // 3. Quick Actions
              _buildQuickActions(context, theme, isDark),
              const SizedBox(height: 28),

              // Responsive Two-Column Layout (Dashboard Main Grid)
              LayoutBuilder(
                builder: (context, constraints) {
                  if (constraints.maxWidth > 720) {
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 3,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildChildrenSection(context, theme, isDark),
                              const SizedBox(height: 24),
                              _buildTreatmentPlansSection(context, theme, isDark),
                            ],
                          ),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          flex: 2,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildNotificationsSection(context, theme, isDark),
                              const SizedBox(height: 24),
                              _buildNotesSection(context, theme, isDark),
                            ],
                          ),
                        ),
                      ],
                    );
                  } else {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildChildrenSection(context, theme, isDark),
                        const SizedBox(height: 24),
                        _buildTreatmentPlansSection(context, theme, isDark),
                        const SizedBox(height: 24),
                        _buildNotificationsSection(context, theme, isDark),
                        const SizedBox(height: 24),
                        _buildNotesSection(context, theme, isDark),
                      ],
                    );
                  }
                },
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // 1. Welcome Hero Banner
  Widget _buildWelcomeBanner(bool isDark, ThemeData theme, String name) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [AppColors.orange600, AppColors.orange700]
              : [AppColors.orange500, Colors.deepOrangeAccent],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.orange500.withValues(alpha: 0.25),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text(
              'Parent Dashboard',
              style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Welcome Back, $name! 👋',
            style: theme.textTheme.headlineMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Monitor your children\'s development, review screening results, coordinate with clinical specialists, and access specialized treatment plans.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.white.withValues(alpha: 0.9),
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  // 2. Quick Stats Grid
  Widget _buildStatsGrid(ThemeData theme, bool isDark) {
    final unreadAlerts = _notifications.where((n) => !n.isRead).length;

    final stats = [
      {'label': 'Registered\nChildren', 'value': '${_children.length}', 'icon': '👶', 'color': isDark ? Colors.blue[900]!.withValues(alpha: 0.2) : Colors.blue[50]},
      {'label': 'Active Care\nPlans', 'value': '${_plans.length}', 'icon': '📋', 'color': isDark ? Colors.green[900]!.withValues(alpha: 0.2) : Colors.green[50]},
      {'label': 'Upcoming\nConsultations', 'value': '1', 'icon': '👨‍⚕️', 'color': isDark ? Colors.orange[900]!.withValues(alpha: 0.2) : Colors.orange[50]},
      {'label': 'Unread\nAlerts', 'value': '$unreadAlerts', 'icon': '🔔', 'color': isDark ? Colors.red[900]!.withValues(alpha: 0.2) : Colors.red[50]},
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth > 550 ? 4 : 2;
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: stats.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            mainAxisExtent: 95,
          ),
          itemBuilder: (context, index) {
            final stat = stats[index];
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF0F172A) : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark ? Colors.white10 : AppColors.slate200,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          stat['label'] as String,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: isDark ? AppColors.slate400 : AppColors.slate500,
                            fontWeight: FontWeight.bold,
                            fontSize: 9,
                            letterSpacing: 0.5,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          stat['value'] as String,
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w900,
                            color: isDark ? Colors.white : AppColors.slate900,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 42,
                    height: 42,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: stat['color'] as Color,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      stat['icon'] as String,
                      style: const TextStyle(fontSize: 20),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // 3. Quick Actions
  Widget _buildQuickActions(BuildContext context, ThemeData theme, bool isDark) {
    final actions = [
      {
        'title': 'Add Child Profile',
        'desc': 'Register a new child in AutiCare',
        'action': () => context.go(AppRoutes.addChild),
        'icon': Icons.add_circle_outline_rounded,
      },
      {
        'title': 'AI Autism Screening',
        'desc': 'Perform developmental assessment',
        'action': _handleStartScreening,
        'icon': Icons.assignment_turned_in_outlined,
      },
      {
        'title': 'Book Doctor',
        'desc': 'Schedule specialist consulting',
        'action': () => context.go(AppRoutes.doctors),
        'icon': Icons.calendar_month_outlined,
      },
      {
        'title': 'Book Therapist',
        'desc': 'Coordinate therapy programs',
        'action': () => context.go(AppRoutes.therapists),
        'icon': Icons.analytics_outlined,
      },
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth > 600 ? 4 : 2;
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: actions.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            mainAxisExtent: 140,
          ),
          itemBuilder: (context, index) {
            final act = actions[index];
            return Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF0F172A) : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark ? Colors.white10 : AppColors.slate200,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        act['icon'] as IconData,
                        color: AppColors.orange500,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          act['title'] as String,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Expanded(
                    child: Text(
                      act['desc'] as String,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: isDark ? AppColors.slate400 : AppColors.slate500,
                        fontSize: 10,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    height: 28,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.orange500,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: EdgeInsets.zero,
                      ),
                      onPressed: act['action'] as VoidCallback,
                      child: const Text(
                        'Select Action',
                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // 4. My Children Section
  Widget _buildChildrenSection(BuildContext context, ThemeData theme, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F172A) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark ? Colors.white10 : AppColors.slate200,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '👶 My Children',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.add, color: AppColors.orange500),
                onPressed: () => context.go(AppRoutes.addChild),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (_children.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Center(child: Text('No children added yet.')),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _children.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final child = _children[index];
                return Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E293B) : AppColors.slate50,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundColor: AppColors.orange100,
                        child: Text(
                          child.name.isNotEmpty ? child.name[0] : 'C',
                          style: const TextStyle(
                            color: AppColors.orange500,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              child.name,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Age: ${child.age} yrs · ${child.gender}',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: isDark ? AppColors.slate400 : AppColors.slate500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.orange500,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            onPressed: () => context.go('${AppRoutes.screening}?childId=${child.id}'),
                            child: const Text('Screen', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                          ),
                          const SizedBox(width: 6),
                          OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: isDark ? Colors.white : AppColors.slate700,
                              side: BorderSide(color: isDark ? Colors.white24 : AppColors.slate300),
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            onPressed: () => context.go('/treatment-plan/${child.id}'),
                            child: const Text('View Plan', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  // 5. Active Treatment Plans Section
  Widget _buildTreatmentPlansSection(BuildContext context, ThemeData theme, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F172A) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark ? Colors.white10 : AppColors.slate200,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.file_copy_outlined, color: Colors.green, size: 20),
              const SizedBox(width: 8),
              Text(
                'Active Treatment Plans',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (_plans.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Center(child: Text('No active treatment plans designated.')),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _plans.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final plan = _plans[index];
                return Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.05),
                    border: Border.all(color: Colors.green.withValues(alpha: 0.15)),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            plan.title,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.green.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              plan.status,
                              style: const TextStyle(
                                color: Colors.green,
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        plan.description,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: isDark ? AppColors.slate400 : AppColors.slate600,
                          height: 1.3,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Align(
                        alignment: Alignment.centerRight,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green[600],
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onPressed: () => context.go('/treatment-plan/${plan.childId}'),
                          child: const Text(
                            'Open Pathway',
                            style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  // 6. Care Notifications Section
  Widget _buildNotificationsSection(BuildContext context, ThemeData theme, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F172A) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark ? Colors.white10 : AppColors.slate200,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.notifications_none_outlined, color: AppColors.orange500, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Care Notifications',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              GestureDetector(
                onTap: () => context.go('/notifications'), // Hardcoded path fallback
                child: const Row(
                  children: [
                    Text(
                      'See All',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.orange500,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Icon(Icons.chevron_right, size: 14, color: AppColors.orange500),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (_notifications.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Center(child: Text('No care alerts yet.')),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _notifications.length,
              separatorBuilder: (context, index) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final notif = _notifications[index];
                return Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: notif.isRead
                        ? (isDark ? const Color(0xFF1E293B) : AppColors.slate50)
                        : (isDark ? Colors.orange[900]!.withValues(alpha: 0.15) : AppColors.orange500.withValues(alpha: 0.08)),
                    border: Border.all(
                      color: notif.isRead
                          ? Colors.transparent
                          : (isDark ? Colors.orange[800]!.withValues(alpha: 0.3) : AppColors.orange500.withValues(alpha: 0.2)),
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        notif.title,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        notif.message,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: isDark ? AppColors.slate400 : AppColors.slate500,
                          height: 1.3,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '${notif.createdAt.hour}:${notif.createdAt.minute.toString().padLeft(2, '0')}',
                        style: TextStyle(
                          fontSize: 9,
                          color: isDark ? AppColors.slate500 : AppColors.slate500,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  // 7. Recent Care Notes Section
  Widget _buildNotesSection(BuildContext context, ThemeData theme, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F172A) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark ? Colors.white10 : AppColors.slate200,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.mode_comment_outlined, color: Colors.purple, size: 20),
              const SizedBox(width: 8),
              Text(
                'Recent Notes & Guidelines',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (_notes.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Center(child: Text('No specialist notes added yet.')),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _notes.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final note = _notes[index];
                return Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E293B) : AppColors.slate50,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '📝 ${note.title}',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '"${note.content}"',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: isDark ? AppColors.slate300 : AppColors.slate500,
                          fontStyle: FontStyle.italic,
                          height: 1.35,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          '${note.createdAt.year}-${note.createdAt.month}-${note.createdAt.day}',
                          style: TextStyle(
                            fontSize: 9,
                            color: isDark ? AppColors.slate500 : AppColors.slate500,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}
