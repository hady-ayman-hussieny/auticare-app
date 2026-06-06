import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../models/specialist.dart';
import '../../services/specialists_service.dart';
import '../../widgets/common/gradient_button.dart';
import '../../widgets/common/feedback_widgets.dart';

class SpecialistDetailScreen extends StatefulWidget {
  final String specialistId;
  final String type;
  const SpecialistDetailScreen({super.key, required this.specialistId, required this.type});

  @override
  State<SpecialistDetailScreen> createState() => _SpecialistDetailScreenState();
}

class _SpecialistDetailScreenState extends State<SpecialistDetailScreen> {
  SpecialistModel? _specialist;
  bool _loading = true;
  String _error = '';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final s = await specialistsService.getSpecialist(widget.specialistId);
      setState(() => _specialist = s);
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.type == 'therapist' ? 'Therapist Profile' : 'Doctor Profile'),
      ),
      body: _loading
          ? const FullPageLoader()
          : _error.isNotEmpty
              ? Center(child: Text(_error))
              : _buildContent(isDark, theme),
      bottomNavigationBar: _specialist != null
          ? Padding(
              padding: const EdgeInsets.all(16),
              child: GradientButton(
                label: 'Book Appointment',
                icon: Icons.calendar_today_rounded,
                onPressed: () => context.go(
                    '/parent/book/${widget.specialistId}?type=${widget.type}'),
              ),
            )
          : null,
    );
  }

  Widget _buildContent(bool isDark, ThemeData theme) {
    final s = _specialist!;
    return ListView(
      children: [
        // Hero header
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF0F172A) : Colors.white,
          ),
          child: Column(
            children: [
              CircleAvatar(
                radius: 48,
                backgroundColor: AppColors.orange100,
                backgroundImage: s.profileImage != null && s.profileImage!.isNotEmpty
                    ? NetworkImage(s.profileImage!) : null,
                child: s.profileImage == null || s.profileImage!.isEmpty
                    ? Text(
                        s.name.isNotEmpty ? s.name[0].toUpperCase() : 'S',
                        style: const TextStyle(color: AppColors.accentLight, fontSize: 32, fontWeight: FontWeight.w700),
                      )
                    : null,
              ),
              const SizedBox(height: 14),
              Text(s.name, style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700)),
              const SizedBox(height: 4),
              Text(s.specialization, style: TextStyle(color: AppColors.accentLight, fontWeight: FontWeight.w500)),
              const SizedBox(height: 14),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _statChip(Icons.star_rounded, '${s.rating.toStringAsFixed(1)} Rating', const Color(0xFFF59E0B)),
                  const SizedBox(width: 12),
                  _statChip(Icons.work_outline, '${s.yearsOfExperience}y Exp.', AppColors.primary500),
                  const SizedBox(width: 12),
                  _statChip(Icons.group_outlined, '${s.reviewCount} Reviews', AppColors.secondary500),
                ],
              ),
            ],
          ),
        ),

        Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (s.bio != null && s.bio!.isNotEmpty) ...[
                _sectionTitle('About', theme),
                Text(s.bio!, style: theme.textTheme.bodyMedium?.copyWith(height: 1.5, color: AppColors.mutedLight)),
                const SizedBox(height: 20),
              ],

              if (s.certifications.isNotEmpty) ...[
                _sectionTitle('Certifications', theme),
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: s.certifications.map((c) => Chip(label: Text(c))).toList(),
                ),
                const SizedBox(height: 20),
              ],

              if (s.email != null && s.email!.isNotEmpty) ...[
                _sectionTitle('Contact', theme),
                ListTile(
                  leading: const Icon(Icons.email_outlined),
                  title: Text(s.email!),
                  contentPadding: EdgeInsets.zero,
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _statChip(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(title, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
    );
  }
}
