import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../core/constants.dart';
import '../../core/theme/app_colors.dart';
import '../../models/child.dart';
import '../../models/booking.dart';
import '../../services/children_service.dart';
import '../../services/bookings_service.dart';
import '../../widgets/app_shell.dart';

class ParentHomeScreen extends StatefulWidget {
  const ParentHomeScreen({super.key});

  @override
  State<ParentHomeScreen> createState() => _ParentHomeScreenState();
}

class _ParentHomeScreenState extends State<ParentHomeScreen> {
  List<ChildModel> _children = [];
  List<BookingModel> _upcomingBookings = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final results = await Future.wait([
        childrenService.getChildren(),
        bookingsService.getUpcomingBookings(),
      ]);
      if (mounted) {
        setState(() {
          _children = results[0] as List<ChildModel>;
          _upcomingBookings = results[1] as List<BookingModel>;
        });
      }
    } catch (_) {}
    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final firstName = (auth.user?.name ?? 'there').split(' ').first;

    return AppShell(
      title: '',
      child: RefreshIndicator(
        onRefresh: _load,
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  // Welcome banner
                  _buildWelcomeBanner(isDark, theme, firstName),
                  const SizedBox(height: 24),

                  // Quick Actions
                  _buildQuickActions(context),
                  const SizedBox(height: 24),

                  // Children
                  _buildSectionHeader(context, 'My Children', () => context.go(AppRoutes.addChild)),
                  const SizedBox(height: 12),
                  if (_children.isEmpty)
                    _buildEmptyCard(
                      context,
                      icon: Icons.child_care_rounded,
                      title: 'No children added yet',
                      subtitle: 'Add your child to start the autism screening',
                      action: 'Add Child',
                      onAction: () => context.go(AppRoutes.addChild),
                    )
                  else
                    ..._children.map((c) => _buildChildCard(context, c, isDark, theme)),
                  const SizedBox(height: 24),

                  // Upcoming bookings
                  _buildSectionHeader(context, 'Upcoming Bookings', () => context.go(AppRoutes.myBookings)),
                  const SizedBox(height: 12),
                  if (_upcomingBookings.isEmpty)
                    _buildEmptyCard(
                      context,
                      icon: Icons.calendar_today_rounded,
                      title: 'No upcoming bookings',
                      subtitle: 'Book a specialist to get started',
                      action: 'Find Specialists',
                      onAction: () => context.go(AppRoutes.doctors),
                    )
                  else
                    ..._upcomingBookings.take(3).map((b) => _buildBookingCard(context, b, isDark, theme)),
                ],
              ),
      ),
    );
  }

  Widget _buildWelcomeBanner(bool isDark, ThemeData theme, String name) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: isDark ? AppColors.primaryGradientDark : AppColors.primaryGradientLight,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.orange500.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 6),
          )
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome back, $name 👋',
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Track your child\'s progress and connect with specialists.',
                  style: theme.textTheme.bodySmall?.copyWith(color: Colors.white70),
                ),
              ],
            ),
          ),
          const Icon(Icons.favorite_rounded, color: Colors.white38, size: 48),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    final actions = [
      {'icon': Icons.assignment_rounded, 'label': 'Screening', 'route': AppRoutes.screening},
      {'icon': Icons.medical_services_rounded, 'label': 'Doctors', 'route': AppRoutes.doctors},
      {'icon': Icons.record_voice_over_rounded, 'label': 'Therapists', 'route': AppRoutes.therapists},
      {'icon': Icons.child_care_rounded, 'label': 'Add Child', 'route': AppRoutes.addChild},
    ];

    return GridView.count(
      crossAxisCount: 4,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 8,
      crossAxisSpacing: 8,
      children: actions.map((a) {
        return GestureDetector(
          onTap: () => context.go(a['route'] as String),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: AppColors.accentLight.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(a['icon'] as IconData, color: AppColors.accentLight, size: 26),
              ),
              const SizedBox(height: 6),
              Text(
                a['label'] as String,
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title, VoidCallback onSeeAll) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
        TextButton(onPressed: onSeeAll, child: const Text('See All')),
      ],
    );
  }

  Widget _buildChildCard(BuildContext context, ChildModel child, bool isDark, ThemeData theme) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F172A) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.white.withValues(alpha: 0.08) : AppColors.slate200,
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: AppColors.orange100,
            child: Text(
              child.name.isNotEmpty ? child.name[0].toUpperCase() : 'C',
              style: const TextStyle(color: AppColors.accentLight, fontWeight: FontWeight.w700, fontSize: 18),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(child.name, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
                Text('${child.age} years • ${child.gender}', style: theme.textTheme.bodySmall?.copyWith(color: AppColors.slate500)),
              ],
            ),
          ),
          TextButton(
            onPressed: () => context.go('${AppRoutes.screening}?childId=${child.id}'),
            child: const Text('Screen'),
          ),
        ],
      ),
    );
  }

  Widget _buildBookingCard(BuildContext context, BookingModel booking, bool isDark, ThemeData theme) {
    Color statusColor;
    switch (booking.status) {
      case 'approved': case 'confirmed': statusColor = AppColors.success500;
      case 'pending': statusColor = AppColors.warning500;
      case 'cancelled': statusColor = AppColors.danger500;
      default: statusColor = AppColors.slate500;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F172A) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? Colors.white.withValues(alpha: 0.08) : AppColors.slate200,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              booking.specialistType == 'therapist'
                  ? Icons.record_voice_over_rounded
                  : Icons.medical_services_rounded,
              color: statusColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  booking.specialistName ?? 'Specialist',
                  style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
                ),
                Text(
                  '${booking.appointmentDate} · ${booking.appointmentTime}',
                  style: theme.textTheme.bodySmall?.copyWith(color: AppColors.slate500),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              booking.status.toUpperCase(),
              style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required String action,
    required VoidCallback onAction,
  }) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.slate200, style: BorderStyle.solid),
      ),
      child: Column(
        children: [
          Icon(icon, size: 40, color: AppColors.slate400),
          const SizedBox(height: 12),
          Text(title, style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          Text(subtitle, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.slate500), textAlign: TextAlign.center),
          const SizedBox(height: 14),
          TextButton(onPressed: onAction, child: Text(action)),
        ],
      ),
    );
  }
}
