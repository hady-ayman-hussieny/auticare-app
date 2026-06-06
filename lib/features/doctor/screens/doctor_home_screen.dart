import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:auticare/features/auth/logic/auth_provider.dart';
import 'package:auticare/core/constants/app_routes.dart';
import 'package:auticare/core/theme/app_colors.dart';
import 'package:auticare/data/models/booking.dart';
import 'package:auticare/data/services/bookings_service.dart';
import 'package:auticare/shared/components/app_shell.dart';

class DoctorHomeScreen extends StatefulWidget {
  const DoctorHomeScreen({super.key});

  @override
  State<DoctorHomeScreen> createState() => _DoctorHomeScreenState();
}

class _DoctorHomeScreenState extends State<DoctorHomeScreen> {
  List<BookingModel> _pending = [];
  List<BookingModel> _upcoming = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final bookings = await bookingsService.getMyBookings();
      setState(() {
        _pending = bookings.where((b) => b.status == 'pending').toList();
        _upcoming = bookings
            .where((b) => b.status == 'approved' || b.status == 'confirmed')
            .toList();
      });
    } catch (_) {}
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _approve(String id) async {
    try {
      await bookingsService.approveBooking(id);
      _load();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  Future<void> _decline(String id) async {
    try {
      await bookingsService.cancelBooking(id, reason: 'Declined by specialist');
      _load();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final name = (auth.user?.name ?? 'Doctor').split(' ').first;
    final isTherapist = auth.user?.role == 'therapist';

    return AppShell(
      title: '',
      child: RefreshIndicator(
        onRefresh: _load,
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  // Welcome
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: isDark ? AppColors.primaryGradientDark : AppColors.primaryGradientLight,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Hello, ${isTherapist ? "" : "Dr. "}$name 👋',
                                style: theme.textTheme.titleLarge?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Manage your appointments and patients.',
                                style: theme.textTheme.bodySmall?.copyWith(color: Colors.white70),
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.local_hospital_rounded, color: Colors.white38, size: 44),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Stats row
                  Row(
                    children: [
                      _statCard('Pending', _pending.length, AppColors.warning500, Icons.pending_rounded, isDark, theme),
                      const SizedBox(width: 12),
                      _statCard('Upcoming', _upcoming.length, AppColors.primary500, Icons.event_rounded, isDark, theme),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Quick nav
                  Row(
                    children: [
                      Expanded(
                        child: _navButton(
                          context,
                          icon: Icons.people_rounded,
                          label: 'Patients',
                          route: AppRoutes.doctorPatients,
                          isDark: isDark,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _navButton(
                          context,
                          icon: Icons.video_call_rounded,
                          label: 'Sessions',
                          route: AppRoutes.doctorSessions,
                          isDark: isDark,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Pending bookings
                  if (_pending.isNotEmpty) ...[
                    Text('Pending Requests',
                        style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                    const SizedBox(height: 12),
                    ..._pending.map((b) => _buildPendingCard(b, isDark, theme)),
                    const SizedBox(height: 20),
                  ],

                  // Upcoming
                  Text('Upcoming Appointments',
                      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 12),
                  if (_upcoming.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(20),
                      child: Center(
                        child: Text('No upcoming appointments', style: TextStyle(color: AppColors.slate500)),
                      ),
                    )
                  else
                    ..._upcoming.take(5).map((b) => _buildUpcomingCard(b, isDark, theme)),
                ],
              ),
      ),
    );
  }

  Widget _statCard(String label, int count, Color color, IconData icon, bool isDark, ThemeData theme) {
    return Expanded(
      child: Container(
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
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('$count', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800, color: color)),
                Text(label, style: theme.textTheme.bodySmall?.copyWith(color: AppColors.slate500)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _navButton(BuildContext context, {required IconData icon, required String label, required String route, required bool isDark}) {
    return GestureDetector(
      onTap: () => context.go(route),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.accentLight.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.accentLight.withValues(alpha: 0.2)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: AppColors.accentLight, size: 20),
            const SizedBox(width: 8),
            Text(label, style: const TextStyle(color: AppColors.accentLight, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }

  Widget _buildPendingCard(BookingModel b, bool isDark, ThemeData theme) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F172A) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.warning500.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.person_rounded, color: AppColors.warning500, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Patient Request',
                  style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.warning500.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text('PENDING',
                    style: TextStyle(color: AppColors.warning500, fontSize: 10, fontWeight: FontWeight.w700)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text('${b.appointmentDate} · ${b.appointmentTime}',
              style: theme.textTheme.bodySmall?.copyWith(color: AppColors.slate500)),
          if (b.notes != null && b.notes!.isNotEmpty)
            Text('Note: ${b.notes}', style: theme.textTheme.bodySmall?.copyWith(color: AppColors.slate400)),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => _decline(b.id),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.danger500,
                    side: const BorderSide(color: AppColors.danger500),
                  ),
                  child: const Text('Decline'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => _approve(b.id),
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.success500),
                  child: const Text('Approve'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildUpcomingCard(BookingModel b, bool isDark, ThemeData theme) {
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
          const Icon(Icons.event_rounded, color: AppColors.primary500, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Patient Appointment',
                    style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
                Text('${b.appointmentDate} · ${b.appointmentTime}',
                    style: theme.textTheme.bodySmall?.copyWith(color: AppColors.slate500)),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded, color: AppColors.slate400),
        ],
      ),
    );
  }
}
