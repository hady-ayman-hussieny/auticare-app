import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:auticare/core/theme/app_colors.dart';
import 'package:auticare/data/models/booking.dart';
import 'package:auticare/data/models/child.dart';
import 'package:auticare/data/services/bookings_service.dart';
import 'package:auticare/data/services/dashboard_service.dart';
import 'package:auticare/shared/components/app_shell.dart';
import 'package:auticare/shared/widgets/state_widgets.dart';

class DoctorPatientsScreen extends StatefulWidget {
  const DoctorPatientsScreen({super.key});

  @override
  State<DoctorPatientsScreen> createState() => _DoctorPatientsScreenState();
}

class _DoctorPatientsScreenState extends State<DoctorPatientsScreen> {
  List<ChildModel> _allPatients = [];
  List<ChildModel> _filteredPatients = [];
  bool _loading = true;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      // Fetch bookings and dashboard specialist data in parallel
      final results = await Future.wait([
        bookingsService.getMyBookings(),
        dashboardService.getSpecialistDashboard(),
      ]);

      final List<BookingModel> bookings = results[0] as List<BookingModel>;
      final dashboardData = results[1] as dynamic; // DashboardSpecialistModel
      final patientCards = dashboardData.patientCards ?? [];

      final Map<String, ChildModel> uniqueChildren = {};

      for (final b in bookings) {
        if (b.childId.isNotEmpty && !uniqueChildren.containsKey(b.childId)) {
          // Find matching card in dashboard specialist payload to extract age/gender/dob
          dynamic card;
          try {
            card = patientCards.firstWhere(
              (c) => c['childName'] == b.childName || c['name'] == b.childName,
              orElse: () => null,
            );
          } catch (_) {}

          final age = card != null ? (int.tryParse((card['age'] ?? card['childAge'] ?? card['ageInYears'] ?? '0').toString()) ?? 4) : 4;
          final gender = card != null ? (card['gender'] ?? card['childGender'] ?? card['sex'] ?? 'Unknown').toString() : 'Unknown';
          final dob = card != null ? (card['dateOfBirth'] ?? card['date_of_birth'] ?? card['dob'] ?? card['childDob'] ?? '').toString() : '';

          uniqueChildren[b.childId] = ChildModel(
            id: b.childId,
            parentId: b.parentId,
            name: b.childName.isNotEmpty ? b.childName : 'Unknown Patient',
            age: age,
            gender: gender,
            dateOfBirth: dob,
            createdAt: b.createdAt,
          );
        }
      }

      setState(() {
        _allPatients = uniqueChildren.values.toList();
        _filterPatients(_searchQuery);
      });
    } catch (_) {}
    if (mounted) setState(() => _loading = false);
  }

  void _filterPatients(String query) {
    _searchQuery = query;
    if (query.isEmpty) {
      setState(() {
        _filteredPatients = List.from(_allPatients);
      });
    } else {
      setState(() {
        _filteredPatients = _allPatients
            .where((p) => p.name.toLowerCase().contains(query.toLowerCase()))
            .toList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return AppShell(
      title: 'Patients',
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'My Patients',
              style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800, letterSpacing: -0.5),
            ),
            const SizedBox(height: 4),
            const Text(
              'Manage and view your patients\' information',
              style: TextStyle(color: AppColors.slate500, fontSize: 12),
            ),
            const SizedBox(height: 20),
            
            // Search Input
            TextField(
              controller: _searchController,
              onChanged: _filterPatients,
              decoration: InputDecoration(
                hintText: 'Search patients by name...',
                prefixIcon: const Icon(Icons.search_rounded, color: AppColors.slate400),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                filled: true,
                fillColor: isDark ? const Color(0xFF1E293B) : AppColors.slate100,
              ),
            ),
            const SizedBox(height: 20),

            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : RefreshIndicator(
                      onRefresh: _load,
                      child: _filteredPatients.isEmpty
                          ? const EmptyStateWidget(
                              icon: Icons.people_outline_rounded,
                              message: 'No patients found matching your search.',
                            )
                          : GridView.builder(
                              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                                maxCrossAxisExtent: 400,
                                crossAxisSpacing: 16,
                                mainAxisSpacing: 16,
                                mainAxisExtent: 140,
                              ),
                              itemCount: _filteredPatients.length,
                              itemBuilder: (context, i) {
                                final p = _filteredPatients[i];
                                return Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: isDark ? const Color(0xFF0F172A) : Colors.white,
                                    borderRadius: BorderRadius.circular(24),
                                    border: Border.all(color: isDark ? Colors.white10 : AppColors.slate200),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(alpha: 0.02),
                                        blurRadius: 10,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          CircleAvatar(
                                            radius: 20,
                                            backgroundColor: AppColors.orange100,
                                            child: Text(
                                              p.name.isNotEmpty ? p.name[0].toUpperCase() : 'P',
                                              style: const TextStyle(color: AppColors.orange500, fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  p.name,
                                                  style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                                const SizedBox(height: 2),
                                                Text(
                                                  'Age: ${p.age} yrs · ${p.gender}',
                                                  style: const TextStyle(color: AppColors.slate500, fontSize: 11),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                      const Spacer(),
                                      SizedBox(
                                        width: double.infinity,
                                        height: 32,
                                        child: ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: AppColors.orange500,
                                            foregroundColor: Colors.white,
                                            elevation: 0,
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                          ),
                                          onPressed: () => context.go('/doctor/patients/${p.id}'),
                                          child: const Text('View Details', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
