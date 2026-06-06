import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../core/constants.dart';
import '../../core/theme/app_colors.dart';
import '../../models/child.dart';
import '../../models/specialist.dart';
import '../../services/children_service.dart';
import '../../services/specialists_service.dart';
import '../../services/bookings_service.dart';
import '../../widgets/common/gradient_button.dart';
import '../../widgets/common/feedback_widgets.dart';

class BookSpecialistScreen extends StatefulWidget {
  final String specialistId;
  final String type;
  const BookSpecialistScreen({super.key, required this.specialistId, required this.type});

  @override
  State<BookSpecialistScreen> createState() => _BookSpecialistScreenState();
}

class _BookSpecialistScreenState extends State<BookSpecialistScreen> {
  SpecialistModel? _specialist;
  List<ChildModel> _children = [];
  ChildModel? _selectedChild;
  DateTime? _selectedDate;
  String? _selectedTime;
  final _notesCtrl = TextEditingController();
  bool _loading = true;
  bool _submitting = false;
  String _error = '';

  final _timeSlots = [
    '09:00', '09:30', '10:00', '10:30', '11:00', '11:30',
    '12:00', '13:00', '14:00', '14:30', '15:00', '15:30',
    '16:00', '16:30', '17:00',
  ];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final results = await Future.wait([
        specialistsService.getSpecialist(widget.specialistId),
        childrenService.getChildren(),
      ]);
      setState(() {
        _specialist = results[0] as SpecialistModel;
        _children = results[1] as List<ChildModel>;
        if (_children.isNotEmpty) _selectedChild = _children.first;
      });
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _submit() async {
    if (_selectedChild == null || _selectedDate == null || _selectedTime == null) {
      setState(() => _error = 'Please fill all required fields.');
      return;
    }
    setState(() { _submitting = true; _error = ''; });
    final auth = context.read<AuthProvider>();
    try {
      final date =
          '${_selectedDate!.year}-${_selectedDate!.month.toString().padLeft(2, '0')}-${_selectedDate!.day.toString().padLeft(2, '0')}';
      await bookingsService.createBooking({
        'specialistId': widget.specialistId,
        'specialistType': widget.type,
        'childId': _selectedChild!.id,
        'parentId': auth.user?.id,
        'preferredDate': date,
        'preferredTime': _selectedTime,
        'notes': _notesCtrl.text.trim(),
        'reason': _notesCtrl.text.trim(),
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Booking request sent successfully! ✓')),
      );
      context.go(AppRoutes.myBookings);
    } catch (e) {
      setState(() => _error = e.toString().replaceAll('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(_specialist != null ? 'Book ${_specialist!.name}' : 'Book Appointment'),
      ),
      body: _loading
          ? const FullPageLoader(message: 'Loading...')
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Specialist summary
                  if (_specialist != null) _buildSpecialistBanner(isDark, theme),
                  const SizedBox(height: 20),

                  ErrorBanner(message: _error, onDismiss: () => setState(() => _error = '')),

                  _buildCard(isDark, theme),
                  const SizedBox(height: 20),

                  GradientButton(
                    label: 'Confirm Booking',
                    isLoading: _submitting,
                    onPressed: _submitting ? null : _submit,
                    icon: Icons.check_circle_rounded,
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildSpecialistBanner(bool isDark, ThemeData theme) {
    final s = _specialist!;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.accentLight.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.accentLight.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: AppColors.orange100,
            child: Text(
              s.name.isNotEmpty ? s.name[0].toUpperCase() : 'S',
              style: const TextStyle(color: AppColors.accentLight, fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(s.name, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
              Text(s.specialization, style: TextStyle(color: AppColors.accentLight, fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCard(bool isDark, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F172A) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? Colors.white.withValues(alpha: 0.08) : AppColors.slate200,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Child selection
          Text('Select child', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          if (_children.isEmpty)
            TextButton.icon(
              onPressed: () => context.go(AppRoutes.addChild),
              icon: const Icon(Icons.add_circle_outline),
              label: const Text('Add a child first'),
            )
          else
            DropdownButtonFormField<ChildModel>(
              initialValue: _selectedChild,
              decoration: InputDecoration(
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              items: _children.map((c) =>
                DropdownMenuItem(value: c, child: Text('${c.name} (${c.age}y)'))).toList(),
              onChanged: (v) => setState(() => _selectedChild = v),
            ),
          const SizedBox(height: 20),

          // Date
          Text('Preferred date', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: () async {
              final now = DateTime.now();
              final d = await showDatePicker(
                context: context,
                initialDate: now.add(const Duration(days: 1)),
                firstDate: now,
                lastDate: now.add(const Duration(days: 90)),
              );
              if (d != null) setState(() => _selectedDate = d);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.slate300),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.calendar_today_rounded, size: 18, color: AppColors.slate500),
                  const SizedBox(width: 10),
                  Text(
                    _selectedDate != null
                        ? '${_selectedDate!.year}-${_selectedDate!.month.toString().padLeft(2, '0')}-${_selectedDate!.day.toString().padLeft(2, '0')}'
                        : 'Pick a date',
                    style: TextStyle(
                      color: _selectedDate != null ? null : AppColors.slate400,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Time slots
          Text('Preferred time', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _timeSlots.map((t) {
              final selected = t == _selectedTime;
              return GestureDetector(
                onTap: () => setState(() => _selectedTime = t),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: selected ? AppColors.accentLight : Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: selected ? AppColors.accentLight : AppColors.slate300,
                      width: selected ? 2 : 1,
                    ),
                  ),
                  child: Text(
                    t,
                    style: TextStyle(
                      color: selected ? Colors.white : null,
                      fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                      fontSize: 13,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),

          // Notes
          Text('Notes (optional)', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          TextFormField(
            controller: _notesCtrl,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'Add any notes for the specialist…',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ],
      ),
    );
  }
}
