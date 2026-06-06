import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../models/notification_model.dart';
import '../../services/sessions_service.dart';
import '../../widgets/app_shell.dart';

class ParentSessionsScreen extends StatefulWidget {
  const ParentSessionsScreen({super.key});

  @override
  State<ParentSessionsScreen> createState() => _ParentSessionsScreenState();
}

class _ParentSessionsScreenState extends State<ParentSessionsScreen> {
  List<TherapySessionModel> _sessions = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final sessions = await sessionsService.getUpcomingSessions();
      setState(() => _sessions = sessions);
    } catch (_) {}
    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return AppShell(
      title: 'Sessions',
      child: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _load,
              child: _sessions.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.video_call_outlined, size: 56, color: AppColors.slate400),
                          const SizedBox(height: 14),
                          Text('No upcoming sessions', style: theme.textTheme.titleMedium),
                          const SizedBox(height: 6),
                          Text('Book a specialist to schedule a session.',
                              style: theme.textTheme.bodySmall?.copyWith(color: AppColors.slate500)),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _sessions.length,
                      itemBuilder: (_, i) => _buildSessionCard(_sessions[i], isDark, theme),
                    ),
            ),
    );
  }

  Widget _buildSessionCard(TherapySessionModel s, bool isDark, ThemeData theme) {
    Color statusColor;
    switch (s.status) {
      case 'scheduled': statusColor = AppColors.primary500;
      case 'ongoing': statusColor = AppColors.success500;
      case 'completed': statusColor = AppColors.slate500;
      case 'cancelled': statusColor = AppColors.danger500;
      default: statusColor = AppColors.slate500;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(Icons.video_call_rounded, color: statusColor, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(s.title,
                    style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
                const SizedBox(height: 2),
                Text(
                  '${s.scheduledDate} · ${s.scheduledTime}',
                  style: theme.textTheme.bodySmall?.copyWith(color: AppColors.slate500),
                ),
                Text(
                  '${s.duration} min',
                  style: theme.textTheme.bodySmall?.copyWith(color: AppColors.slate400),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  s.status.toUpperCase(),
                  style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.w700),
                ),
              ),
              if (s.joinLink != null && s.joinLink!.isNotEmpty) ...[
                const SizedBox(height: 6),
                TextButton(
                  onPressed: () {},
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    minimumSize: Size.zero,
                  ),
                  child: const Text('Join', style: TextStyle(fontSize: 13)),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
