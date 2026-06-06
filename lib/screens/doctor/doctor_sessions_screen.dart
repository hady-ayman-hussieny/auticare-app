import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../models/notification_model.dart';
import '../../services/sessions_service.dart';

import '../../widgets/app_shell.dart';

class DoctorSessionsScreen extends StatefulWidget {
  const DoctorSessionsScreen({super.key});

  @override
  State<DoctorSessionsScreen> createState() => _DoctorSessionsScreenState();
}

class _DoctorSessionsScreenState extends State<DoctorSessionsScreen> {
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
      final s = await sessionsService.getUpcomingSessions();
      setState(() => _sessions = s);
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
                  ? const Center(
                      child: Text('No upcoming sessions.',
                          style: TextStyle(color: AppColors.slate500)),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _sessions.length,
                      itemBuilder: (_, i) {
                        final s = _sessions[i];
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
                                  color: AppColors.primary500.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: const Icon(Icons.video_call_rounded,
                                    color: AppColors.primary500, size: 24),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(s.title,
                                        style: theme.textTheme.titleSmall
                                            ?.copyWith(fontWeight: FontWeight.w700)),
                                    Text(
                                      '${s.scheduledDate} · ${s.scheduledTime} · ${s.duration}min',
                                      style: theme.textTheme.bodySmall
                                          ?.copyWith(color: AppColors.slate500),
                                    ),
                                  ],
                                ),
                              ),
                              if (s.joinLink != null && s.joinLink!.isNotEmpty)
                                TextButton(
                                  onPressed: () {},
                                  child: const Text('Join'),
                                ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
    );
  }
}
