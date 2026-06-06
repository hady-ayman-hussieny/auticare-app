import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../models/booking.dart';
import '../../services/bookings_service.dart';
import '../../widgets/app_shell.dart';

class DoctorPatientsScreen extends StatefulWidget {
  const DoctorPatientsScreen({super.key});

  @override
  State<DoctorPatientsScreen> createState() => _DoctorPatientsScreenState();
}

class _DoctorPatientsScreenState extends State<DoctorPatientsScreen> {
  List<BookingModel> _bookings = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final b = await bookingsService.getMyBookings();
      setState(() => _bookings = b);
    } catch (_) {}
    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return AppShell(
      title: 'Patients',
      child: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _load,
              child: _bookings.isEmpty
                  ? const Center(
                      child: Text('No patient bookings found.',
                          style: TextStyle(color: AppColors.slate500)),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _bookings.length,
                      itemBuilder: (_, i) {
                        final b = _bookings[i];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: AppColors.orange100,
                              child: Text(
                                'P',
                                style: const TextStyle(color: AppColors.accentLight, fontWeight: FontWeight.w700),
                              ),
                            ),
                            title: Text('Patient Booking #${b.id.length > 8 ? b.id.substring(0, 8) : b.id}'),
                            subtitle: Text('${b.appointmentDate} · ${b.status}'),
                            trailing: const Icon(Icons.chevron_right_rounded),
                            onTap: () => context.go('/doctor/patients/${b.childId}'),
                            tileColor: isDark ? const Color(0xFF0F172A) : Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        );
                      },
                    ),
            ),
    );
  }
}
