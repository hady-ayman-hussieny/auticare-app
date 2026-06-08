import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:auticare/core/theme/app_colors.dart';
import 'package:auticare/data/models/specialist.dart';
import 'package:auticare/data/services/specialists_service.dart';
import 'package:auticare/shared/widgets/specialist_card.dart';
import 'package:auticare/shared/components/app_shell.dart';

class TherapistsScreen extends StatefulWidget {
  const TherapistsScreen({super.key});

  @override
  State<TherapistsScreen> createState() => _TherapistsScreenState();
}

class _TherapistsScreenState extends State<TherapistsScreen> {
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
      final therapists = await specialistsService.getTherapists();
      setState(() {
        _all = therapists;
        _filtered = therapists;
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
      title: 'Therapists',
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: TextField(
              onChanged: _onSearch,
              decoration: InputDecoration(
                hintText: 'Search therapists…',
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: _search.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded),
                        onPressed: () => _onSearch(''),
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
                        child: Text(
                          _search.isNotEmpty ? 'No therapists match "$_search"' : 'No therapists found',
                          style: const TextStyle(color: AppColors.slate500),
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
                              onTap: () => context.go('/parent/specialist/${s.id}?type=therapist'),
                              onBook: () => context.go('/parent/book/${s.id}?type=therapist'),
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
