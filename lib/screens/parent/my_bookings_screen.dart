import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../models/booking.dart';
import '../../services/bookings_service.dart';
import '../../widgets/app_shell.dart';

class MyBookingsScreen extends StatefulWidget {
  const MyBookingsScreen({super.key});

  @override
  State<MyBookingsScreen> createState() => _MyBookingsScreenState();
}

class _MyBookingsScreenState extends State<MyBookingsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;
  List<BookingModel> _all = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 4, vsync: this);
    _load();
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final bookings = await bookingsService.getMyBookings();
      setState(() => _all = bookings);
    } catch (_) {}
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _cancel(String id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Cancel Booking?'),
        content: const Text('Are you sure you want to cancel this booking?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('No')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Yes, Cancel', style: TextStyle(color: AppColors.danger500)),
          ),
        ],
      ),
    );
    if (confirm != true) return;
    try {
      await bookingsService.cancelBooking(id);
      _load();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  List<BookingModel> _filter(String status) {
    if (status == 'all') return _all;
    return _all.where((b) => b.status == status).toList();
  }

  @override
  Widget build(BuildContext context) {
    return AppShell(
      title: 'Bookings',
      child: Column(
        children: [
          TabBar(
            controller: _tabCtrl,
            isScrollable: true,
            tabs: const [
              Tab(text: 'All'),
              Tab(text: 'Pending'),
              Tab(text: 'Approved'),
              Tab(text: 'Cancelled'),
            ],
          ),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : TabBarView(
                    controller: _tabCtrl,
                    children: [
                      _buildList('all'),
                      _buildList('pending'),
                      _buildList('approved'),
                      _buildList('cancelled'),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildList(String status) {
    final items = _filter(status);
    if (items.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.calendar_today_outlined, size: 48, color: AppColors.slate400),
            const SizedBox(height: 12),
            Text('No ${status == 'all' ? '' : '$status '}bookings',
                style: const TextStyle(color: AppColors.slate500)),
          ],
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: _load,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: items.length,
        itemBuilder: (_, i) => _buildBookingCard(items[i]),
      ),
    );
  }

  Widget _buildBookingCard(BookingModel b) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    Color statusColor;
    switch (b.status) {
      case 'approved': case 'confirmed': statusColor = AppColors.success500;
      case 'pending': statusColor = AppColors.warning500;
      case 'cancelled': statusColor = AppColors.danger500;
      case 'completed': statusColor = AppColors.primary500;
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  b.specialistType == 'therapist'
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
                      b.specialistName ?? 'Specialist',
                      style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    Text(
                      b.specialistType == 'therapist' ? 'Therapist' : 'Doctor',
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
                  b.status.toUpperCase(),
                  style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.calendar_today_rounded, size: 14, color: AppColors.slate500),
              const SizedBox(width: 6),
              Text(b.appointmentDate, style: theme.textTheme.bodySmall),
              const SizedBox(width: 16),
              const Icon(Icons.access_time_rounded, size: 14, color: AppColors.slate500),
              const SizedBox(width: 6),
              Text(b.appointmentTime, style: theme.textTheme.bodySmall),
            ],
          ),
          if (b.notes != null && b.notes!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text('Notes: ${b.notes}',
                style: theme.textTheme.bodySmall?.copyWith(color: AppColors.slate500)),
          ],
          if (b.status == 'pending') ...[
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: () => _cancel(b.id),
                icon: const Icon(Icons.cancel_outlined, size: 16),
                label: const Text('Cancel'),
                style: TextButton.styleFrom(foregroundColor: AppColors.danger500),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
