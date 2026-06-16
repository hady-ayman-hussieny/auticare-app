import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:auticare/core/constants/app_routes.dart';
import 'package:auticare/core/theme/app_colors.dart';
import 'package:auticare/data/models/booking.dart';
import 'package:auticare/data/models/dashboard_model.dart';
import 'package:auticare/data/models/note_model.dart';
import 'package:auticare/data/models/notification_model.dart';
import 'package:auticare/data/services/bookings_service.dart';
import 'package:auticare/data/services/dashboard_service.dart';
import 'package:auticare/data/services/notes_service.dart';
import 'package:auticare/data/services/notifications_service.dart';
import 'package:auticare/features/auth/logic/auth_provider.dart';
import 'package:auticare/shared/components/app_shell.dart';
import 'package:auticare/shared/widgets/state_widgets.dart';
import 'package:auticare/shared/widgets/stats_card.dart';

/// Shared home screen for Doctor and Therapist roles.
/// Mirrors DoctorHome.tsx from the React application.
class DoctorHomeScreen extends StatefulWidget {
  const DoctorHomeScreen({super.key});

  @override
  State<DoctorHomeScreen> createState() => _DoctorHomeScreenState();
}

class _DoctorHomeScreenState extends State<DoctorHomeScreen> {
  DashboardSpecialistModel _stats = DashboardSpecialistModel.empty;
  List<BookingModel> _sessions = [];
  List<NotificationModel> _notifications = [];
  List<NoteModel> _notes = [];

  // Derived patients from bookings
  List<Map<String, dynamic>> _patients = [];

  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final results = await Future.wait([
        dashboardService.getSpecialistDashboard(),
        bookingsService.getUpcomingBookings(),
        notificationsService.getNotifications(limit: 5),
        notesService.getMyNotes(),
      ]);

      final stats = results[0] as DashboardSpecialistModel;
      final bookings = results[1] as List<BookingModel>;
      final notifications = results[2] as List<NotificationModel>;
      final notes = results[3] as List<NoteModel>;

      // Extract unique patients from confirmed/approved bookings
      final uniquePatients = <String, Map<String, dynamic>>{};
      for (final b in bookings) {
        if ((b.status == 'confirmed' || b.status == 'approved' || b.status == 'scheduled') &&
            b.childId.isNotEmpty &&
            !uniquePatients.containsKey(b.childId)) {
          uniquePatients[b.childId] = {
            'id': b.childId,
            'name': b.childName.isNotEmpty ? b.childName : 'Patient',
            'parentName': b.parentName,
            'status': 'active',
          };
        }
      }

      setState(() {
        _stats = stats;
        _sessions = bookings;
        _notifications = notifications;
        _notes = notes;
        _patients = uniquePatients.values.toList();
      });
    } catch (e) {
      setState(() => _error = 'Failed to load dashboard. Pull to refresh.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _updateBookingStatus(String id, String status) async {
    try {
      await bookingsService.updateBookingStatus(id, status);
      _load();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  bool _isToday(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return false;
    try {
      final date = DateTime.parse(dateStr);
      final now = DateTime.now();
      return date.year == now.year &&
          date.month == now.month &&
          date.day == now.day;
    } catch (_) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final isDoctor = auth.user?.role == 'doctor';
    final firstName = (auth.user?.name ?? 'Specialist').split(' ').first;
    final pendingBookings =
        _sessions.where((s) => s.status == 'pending').toList();
    final confirmedSessions = _sessions
        .where((s) => s.status == 'confirmed' || s.status == 'scheduled' || s.status == 'approved')
        .toList();
    final todaySessions =
        confirmedSessions.where((s) => _isToday(s.appointmentDate)).toList();

    final patientsRoute =
        isDoctor ? AppRoutes.doctorPatients : AppRoutes.therapistPatients;

    return AppShell(
      title: '',
      child: RefreshIndicator(
        onRefresh: _load,
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  // ── Error banner ────────────────────────────────────────
                  if (_error != null)
                    ErrorBanner(message: _error!, onRetry: _load),

                  // ── Welcome Hero Banner ─────────────────────────────────
                  _WelcomeBanner(
                    name: firstName,
                    isDoctor: isDoctor,
                    todaySessions: todaySessions.length,
                    activeCases: _stats.activeCases,
                  ),
                  const SizedBox(height: 20),

                  // ── Dashboard Stats ─────────────────────────────────────
                  const _SectionTitle(title: 'Dashboard Overview'),
                  const SizedBox(height: 12),
                  Row(children: [
                    StatsCard(
                      label: "Today's Sessions",
                      value: _stats.todaySessions,
                      color: AppColors.primary500,
                      icon: Icons.today_rounded,
                    ),
                    const SizedBox(width: 12),
                    StatsCard(
                      label: 'Active Cases',
                      value: _stats.activeCases,
                      color: AppColors.success500,
                      icon: Icons.people_rounded,
                    ),
                  ]),
                  const SizedBox(height: 12),
                  Row(children: [
                    StatsCard(
                      label: 'Pending',
                      value: _stats.pendingRequests,
                      color: AppColors.warning500,
                      icon: Icons.pending_rounded,
                    ),
                    const SizedBox(width: 12),
                    StatsCard(
                      label: 'Completed',
                      value: _stats.completedSessions,
                      color: AppColors.slate500,
                      icon: Icons.check_circle_rounded,
                    ),
                  ]),
                  const SizedBox(height: 24),

                  // ── Your Patients ────────────────────────────────────────
                  if (_patients.isNotEmpty) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const _SectionTitle(title: 'Your Patients'),
                        TextButton(
                          onPressed: () => context.go(patientsRoute),
                          child: const Text('View All'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 100,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: _patients.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 12),
                        itemBuilder: (_, i) {
                          final p = _patients[i];
                          return _PatientChip(
                            name: p['name'] as String,
                            onTap: () => context.go(
                              '${isDoctor ? '/doctor' : '/therapist'}/patients/${p['id']}',
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // ── Today's Sessions ─────────────────────────────────────
                  if (todaySessions.isNotEmpty) ...[
                    const _SectionTitle(title: "Today's Sessions"),
                    const SizedBox(height: 12),
                    ...todaySessions.map((s) => _SessionCard(
                          session: s,
                          isDoctor: isDoctor,
                          badge: 'Today',
                          badgeColor: AppColors.success500,
                          onPatientTap: () => context.go(
                            '${isDoctor ? '/doctor' : '/therapist'}/patients/${s.childId}',
                          ),
                          onJoinZoom: () => _joinZoom(s),
                        )),
                    const SizedBox(height: 20),
                  ],

                  // ── Pending Booking Requests (Doctor only) ───────────────
                  if (isDoctor) ...[
                    _SectionTitle(
                        title: 'Pending Requests (${pendingBookings.length})'),
                    const SizedBox(height: 12),
                    if (pendingBookings.isEmpty)
                      const EmptyStateWidget(
                        icon: Icons.check_circle_outline_rounded,
                        message: 'No pending booking requests',
                      )
                    else
                      ...pendingBookings.map((b) => _PendingRequestCard(
                            booking: b,
                            onApprove: () =>
                                _updateBookingStatus(b.id, 'confirmed'),
                            onReject: () =>
                                _updateBookingStatus(b.id, 'cancelled'),
                            onPatientTap: b.childId.isNotEmpty
                                ? () => context.go(
                                    '/doctor/patients/${b.childId}')
                                : null,
                          )),
                    const SizedBox(height: 20),
                  ],

                  // ── Upcoming Confirmed Sessions ───────────────────────────
                  const _SectionTitle(title: 'Upcoming Confirmed Sessions'),
                  const SizedBox(height: 12),
                  if (confirmedSessions.isEmpty)
                    const EmptyStateWidget(
                      icon: Icons.event_outlined,
                      message: 'No confirmed sessions scheduled',
                    )
                  else
                    ...confirmedSessions.take(5).map((s) => _SessionCard(
                          session: s,
                          isDoctor: isDoctor,
                          badge: 'Confirmed',
                          badgeColor: AppColors.primary500,
                          onPatientTap: s.childId.isNotEmpty
                              ? () => context.go(
                                  '${isDoctor ? '/doctor' : '/therapist'}/patients/${s.childId}')
                              : null,
                          onJoinZoom: () => _joinZoom(s),
                        )),
                  const SizedBox(height: 24),

                  // ── Notifications ────────────────────────────────────────
                  const _SectionTitle(title: 'Action Alerts'),
                  const SizedBox(height: 12),
                  if (_notifications.isEmpty)
                    const EmptyStateWidget(
                      icon: Icons.notifications_none_rounded,
                      message: 'No alerts currently',
                    )
                  else
                    ..._notifications.map((n) => _NotifTile(n: n)),
                  const SizedBox(height: 24),

                  // ── My Recent Notes ──────────────────────────────────────
                  const _SectionTitle(title: 'My Recent Notes'),
                  const SizedBox(height: 12),
                  if (_notes.isEmpty)
                    const EmptyStateWidget(
                      icon: Icons.notes_rounded,
                      message: 'No notes yet',
                    )
                  else
                    ..._notes.take(5).map((note) => _NoteChip(note: note)),

                  const SizedBox(height: 32),
                ],
              ),
      ),
    );
  }

  void _joinZoom(BookingModel session) {
    final url = session.joinLink ?? session.zoomUrl;
    if (url != null && url.isNotEmpty) {
      // Will be handled by url_launcher once added
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Opening: $url')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No Zoom link available for this session')),
      );
    }
  }
}

// ─── Welcome Banner ───────────────────────────────────────────────────────────
class _WelcomeBanner extends StatelessWidget {
  final String name;
  final bool isDoctor;
  final int todaySessions;
  final int activeCases;

  const _WelcomeBanner({
    required this.name,
    required this.isDoctor,
    required this.todaySessions,
    required this.activeCases,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0F172A), Color(0xFF1E1B4B), Color(0xFF0F172A)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF6366F1).withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                  color: const Color(0xFF6366F1).withValues(alpha: 0.3)),
            ),
            child: Text(
              isDoctor ? 'Clinical Specialist' : 'Development Therapist',
              style: const TextStyle(
                color: Color(0xFFA5B4FC),
                fontSize: 11,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.8,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            isDoctor
                ? 'Welcome, Dr. $name 👋'
                : 'Welcome, Therapist $name 👋',
            style: theme.textTheme.headlineSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            isDoctor
                ? 'Monitor patients, review assessments, and guide treatment plans.'
                : 'Support development goals, track sessions, and help children thrive.',
            style: theme.textTheme.bodySmall
                ?.copyWith(color: Colors.white70),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _HeroBadge(label: "Today's Sessions", value: todaySessions),
              const SizedBox(width: 12),
              _HeroBadge(label: 'Active Cases', value: activeCases),
            ],
          ),
        ],
      ),
    );
  }
}

class _HeroBadge extends StatelessWidget {
  final String label;
  final int value;
  const _HeroBadge({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(12),
        border:
            Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$value',
            style: const TextStyle(
              color: Color(0xFFA5B4FC),
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Section Title ────────────────────────────────────────────────────────────
class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
    );
  }
}

// ─── Patient Chip (horizontal carousel) ──────────────────────────────────────
class _PatientChip extends StatelessWidget {
  final String name;
  final VoidCallback onTap;
  const _PatientChip({required this.name, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 90,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E293B) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.08)
                  : AppColors.slate200),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor:
                  AppColors.primary500.withValues(alpha: 0.12),
              child: Text(
                name.substring(0, 1).toUpperCase(),
                style: const TextStyle(
                  color: AppColors.primary500,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              name.split(' ').first,
              style: theme.textTheme.bodySmall
                  ?.copyWith(fontWeight: FontWeight.w600),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Session Card ─────────────────────────────────────────────────────────────
class _SessionCard extends StatelessWidget {
  final BookingModel session;
  final bool isDoctor;
  final String badge;
  final Color badgeColor;
  final VoidCallback? onPatientTap;
  final VoidCallback onJoinZoom;

  const _SessionCard({
    required this.session,
    required this.isDoctor,
    required this.badge,
    required this.badgeColor,
    this.onPatientTap,
    required this.onJoinZoom,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final hasZoom = (session.joinLink?.isNotEmpty ?? false) ||
        (session.zoomUrl?.isNotEmpty ?? false);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F172A) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : AppColors.slate200,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  session.reason?.isNotEmpty == true
                      ? session.reason!
                      : "${session.childName}'s Session",
                  style: theme.textTheme.titleSmall
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: badgeColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  badge,
                  style: TextStyle(
                    color: badgeColor,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _InfoRow(
              label: 'Child',
              value: session.childName.isNotEmpty
                  ? session.childName
                  : 'Not provided'),
          _InfoRow(
              label: 'Parent',
              value: session.parentName.isNotEmpty
                  ? session.parentName
                  : 'Not provided'),
          _InfoRow(
              label: 'Date & Time',
              value:
                  '${session.appointmentDate} · ${session.appointmentTime}'),
          if (session.notes?.isNotEmpty == true)
            _InfoRow(label: 'Notes', value: session.notes!),
          const SizedBox(height: 10),
          Row(
            children: [
              if (onPatientTap != null)
                TextButton(
                  onPressed: onPatientTap,
                  style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap),
                  child: const Text('🔎 View Patient',
                      style: TextStyle(fontSize: 12)),
                ),
              const Spacer(),
              if (hasZoom)
                ElevatedButton.icon(
                  onPressed: onJoinZoom,
                  icon: const Icon(Icons.video_call_rounded, size: 16),
                  label: Text(
                    isDoctor ? 'Start Session' : 'Join Session',
                    style: const TextStyle(fontSize: 12),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary500,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 8),
                  ),
                )
              else
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.danger500.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'No Zoom link',
                    style:
                        TextStyle(color: AppColors.danger500, fontSize: 11),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: RichText(
        text: TextSpan(
          style: Theme.of(context)
              .textTheme
              .bodySmall
              ?.copyWith(color: AppColors.slate500),
          children: [
            TextSpan(
              text: '$label: ',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            TextSpan(text: value),
          ],
        ),
      ),
    );
  }
}

// ─── Pending Request Card ─────────────────────────────────────────────────────
class _PendingRequestCard extends StatelessWidget {
  final BookingModel booking;
  final VoidCallback onApprove;
  final VoidCallback onReject;
  final VoidCallback? onPatientTap;

  const _PendingRequestCard({
    required this.booking,
    required this.onApprove,
    required this.onReject,
    this.onPatientTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F172A) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
            color: AppColors.warning500.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.person_rounded,
                  color: AppColors.warning500, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Appointment Request',
                  style: theme.textTheme.titleSmall
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.warning500.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'PENDING',
                  style: TextStyle(
                      color: AppColors.warning500,
                      fontSize: 10,
                      fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '${booking.appointmentDate} · ${booking.appointmentTime}',
            style: theme.textTheme.bodySmall
                ?.copyWith(color: AppColors.slate500),
          ),
          if (booking.notes?.isNotEmpty == true)
            Text(
              'Reason: ${booking.notes}',
              style: theme.textTheme.bodySmall
                  ?.copyWith(color: AppColors.slate400),
            ),
          if (onPatientTap != null)
            TextButton(
              onPressed: onPatientTap,
              style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap),
              child: const Text('🔎 Review Patient Profile',
                  style: TextStyle(fontSize: 12)),
            ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: onReject,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.danger500,
                    side: const BorderSide(color: AppColors.danger500),
                  ),
                  child: const Text('Reject'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  onPressed: onApprove,
                  style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.success500),
                  child: const Text('Approve',
                      style: TextStyle(color: Colors.white)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Notification Tile ────────────────────────────────────────────────────────
class _NotifTile extends StatelessWidget {
  final NotificationModel n;
  const _NotifTile({required this.n});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: n.isRead
            ? (theme.brightness == Brightness.dark
                ? const Color(0xFF0F172A)
                : AppColors.slate50)
            : AppColors.primary500.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: n.isRead ? AppColors.slate100 : AppColors.primary500.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            n.title,
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            n.message,
            style: theme.textTheme.bodySmall
                ?.copyWith(color: AppColors.slate500),
          ),
        ],
      ),
    );
  }
}

// ─── Note Chip ────────────────────────────────────────────────────────────────
class _NoteChip extends StatelessWidget {
  final NoteModel note;
  const _NoteChip({required this.note});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F172A) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: isDark
                ? Colors.white.withValues(alpha: 0.08)
                : AppColors.slate200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            note.title,
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            note.content,
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppColors.slate500,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
