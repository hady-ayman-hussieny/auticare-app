import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../models/specialist.dart';
import '../../services/specialists_service.dart';
import '../../widgets/common/specialist_card.dart';
import '../../widgets/app_shell.dart';

class DoctorsScreen extends StatefulWidget {
  const DoctorsScreen({super.key});

  @override
  State<DoctorsScreen> createState() => _DoctorsScreenState();
}

class _DoctorsScreenState extends State<DoctorsScreen> {
  List<SpecialistModel> _all = [];
  List<SpecialistModel> _filtered = [];
  bool _loading = true;
  String _search = '';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final docs = await specialistsService.getDoctors();
      setState(() {
        _all = docs;
        _filtered = docs;
      });
    } catch (_) {}
    if (mounted) setState(() => _loading = false);
  }

  void _onSearch(String q) {
    setState(() {
      _search = q;
      _filtered = _all.where((s) =>
          s.name.toLowerCase().contains(q.toLowerCase()) ||
          s.specialization.toLowerCase().contains(q.toLowerCase())).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return AppShell(
      title: 'Doctors',
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: TextField(
              onChanged: _onSearch,
              decoration: InputDecoration(
                hintText: 'Search doctors…',
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: _search.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded),
                        onPressed: () {
                          _onSearch('');
                        },
                      )
                    : null,
              ),
            ),
          ),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _filtered.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.medical_services_outlined, size: 48, color: AppColors.slate400),
                            const SizedBox(height: 12),
                            Text(
                              _search.isNotEmpty ? 'No doctors match "$_search"' : 'No doctors found',
                              style: const TextStyle(color: AppColors.slate500),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _load,
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _filtered.length,
                          itemBuilder: (_, i) {
                            final s = _filtered[i];
                            return SpecialistCard(
                              specialist: s,
                              onTap: () => context.go('/parent/specialist/${s.id}?type=doctor'),
                              onBook: () => context.go('/parent/book/${s.id}?type=doctor'),
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}
