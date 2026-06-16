import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:auticare/core/theme/app_colors.dart';
import 'package:auticare/data/models/child.dart';
import 'package:auticare/data/models/screening.dart';
import 'package:auticare/data/models/note_model.dart';
import 'package:auticare/data/models/treatment_plan_model.dart';
import 'package:auticare/data/services/children_service.dart';
import 'package:auticare/data/services/screening_service.dart';
import 'package:auticare/data/services/notes_service.dart';
import 'package:auticare/data/services/treatment_plans_service.dart';
import 'package:auticare/data/services/bookings_service.dart';
import 'package:auticare/data/services/dashboard_service.dart';

class PatientDetailScreen extends StatefulWidget {
  final String childId;
  const PatientDetailScreen({super.key, required this.childId});

  @override
  State<PatientDetailScreen> createState() => _PatientDetailScreenState();
}

class _PatientDetailScreenState extends State<PatientDetailScreen> {
  ChildModel? _patient;
  List<ScreeningResult> _screeningResults = [];
  List<NoteModel> _notes = [];
  List<TreatmentPlanModel> _plans = [];
  
  bool _loading = true;
  bool _savingNote = false;
  final TextEditingController _noteController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      // 1. Fetch child profile
      ChildModel? childData;
      try {
        childData = await childrenService.getChild(widget.childId);
      } catch (_) {
        // Fallback: search my bookings to extract basic child info
        final results = await Future.wait([
          bookingsService.getMyBookings(),
          dashboardService.getSpecialistDashboard(),
        ]);
        final bookings = results[0] as List;
        final dashData = results[1] as dynamic;
        final booking = bookings.firstWhere((b) => b.childId == widget.childId, orElse: () => null);
        
        if (booking != null) {
          final patientCards = dashData.patientCards ?? [];
          dynamic card;
          try {
            card = patientCards.firstWhere(
              (c) => c['childName'] == booking.childName || c['name'] == booking.childName,
              orElse: () => null,
            );
          } catch (_) {}

          final age = card != null ? (int.tryParse((card['age'] ?? card['childAge'] ?? card['ageInYears'] ?? '0').toString()) ?? 4) : 4;
          final gender = card != null ? (card['gender'] ?? card['childGender'] ?? card['sex'] ?? 'Unknown').toString() : 'Unknown';
          final dob = card != null ? (card['dateOfBirth'] ?? card['date_of_birth'] ?? card['dob'] ?? card['childDob'] ?? '').toString() : '';

          childData = ChildModel(
            id: booking.childId,
            parentId: booking.parentId,
            name: booking.childName,
            age: age,
            gender: gender,
            dateOfBirth: dob,
            createdAt: booking.createdAt,
          );
        }
      }

      _patient = childData;

      // 2. Fetch screening, notes, and treatment plans in parallel
      final results = await Future.wait([
        screeningService.getResults(widget.childId).catchError((_) => <ScreeningResult>[]),
        notesService.getChildNotes(widget.childId).catchError((_) => <NoteModel>[]),
        treatmentPlansService.getChildPlans(widget.childId).catchError((_) => <TreatmentPlanModel>[]),
      ]);

      setState(() {
        _screeningResults = results[0] as List<ScreeningResult>;
        _notes = results[1] as List<NoteModel>;
        _plans = results[2] as List<TreatmentPlanModel>;
      });
    } catch (_) {}
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _handleSaveNote() async {
    final noteText = _noteController.text.trim();
    if (noteText.isEmpty || _patient == null) return;
    setState(() => _savingNote = true);

    try {
      final addedNote = await notesService.createNote(
        title: 'Session Note',
        content: noteText,
        childId: widget.childId,
      );
      if (addedNote != null) {
        setState(() {
          _notes.insert(0, addedNote);
          _noteController.clear();
        });
      }
    } catch (_) {} finally {
      if (mounted) setState(() => _savingNote = false);
    }
  }

  Color _riskColor(String risk) {
    switch (risk.toLowerCase()) {
      case 'low': return AppColors.success500;
      case 'medium': case 'moderate': return AppColors.warning500;
      case 'high': return AppColors.danger500;
      default: return AppColors.slate500;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (_loading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Patient Detail')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_patient == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Patient Detail')),
        body: const Center(child: Text('Patient not found')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_patient!.name),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Patient Info Header
            Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: AppColors.orange100,
                  child: Text(
                    _patient!.name.isNotEmpty ? _patient!.name[0].toUpperCase() : 'P',
                    style: const TextStyle(color: AppColors.orange500, fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_patient!.name, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(
                      'Age: ${_patient!.age} yrs · Gender: ${_patient!.gender}',
                      style: const TextStyle(color: AppColors.slate500, fontSize: 13),
                    ),
                  ],
                ),
              ],
            ),
            
            const SizedBox(height: 24),

            // Responsive Layout: Screening, Treatment plans, and Notes
            LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth > 800;

                if (isWide) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          children: [
                            _buildScreeningResultsCard(isDark, theme),
                            const SizedBox(height: 20),
                            _buildTreatmentPlansCard(isDark, theme),
                          ],
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          children: [
                            _buildPastNotesCard(isDark, theme),
                            const SizedBox(height: 20),
                            _buildAddNoteCard(isDark, theme),
                          ],
                        ),
                      ),
                    ],
                  );
                } else {
                  return Column(
                    children: [
                      _buildScreeningResultsCard(isDark, theme),
                      const SizedBox(height: 20),
                      _buildTreatmentPlansCard(isDark, theme),
                      const SizedBox(height: 20),
                      _buildPastNotesCard(isDark, theme),
                      const SizedBox(height: 20),
                      _buildAddNoteCard(isDark, theme),
                    ],
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  // Column 1 component: Screening Results
  Widget _buildScreeningResultsCard(bool isDark, ThemeData theme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F172A) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: isDark ? Colors.white10 : AppColors.slate200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Screening Results', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          if (_screeningResults.isEmpty)
            const Text('No screening results available', style: TextStyle(color: AppColors.slate500, fontSize: 12))
          else
            ..._screeningResults.map((result) {
              final color = _riskColor(result.riskLevel);
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E293B) : AppColors.slate50,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: color.withValues(alpha: 0.2)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(result.predictionClass, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${result.riskLevel.toUpperCase()} RISK',
                            style: TextStyle(color: color, fontSize: 9, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        const Text('AQ Score: ', style: TextStyle(color: AppColors.slate500, fontSize: 11)),
                        Text('${result.aqScore}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
                        const SizedBox(width: 16),
                        const Text('Probability: ', style: TextStyle(color: AppColors.slate500, fontSize: 11)),
                        Text(result.probability, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      result.createdAt.split('T').first,
                      style: const TextStyle(color: AppColors.slate400, fontSize: 9),
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }

  // Column 1 component: Treatment Plans
  Widget _buildTreatmentPlansCard(bool isDark, ThemeData theme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F172A) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: isDark ? Colors.white10 : AppColors.slate200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Treatment Plans', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
              TextButton(
                onPressed: () => context.go('/treatment-plan/${widget.childId}'),
                child: Text(
                  _plans.isNotEmpty ? 'Edit Plan' : 'Create Plan',
                  style: const TextStyle(color: AppColors.orange500, fontWeight: FontWeight.bold, fontSize: 12),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (_plans.isEmpty)
            Center(
              child: Column(
                children: [
                  const Text('No treatment plan configured', style: TextStyle(color: AppColors.slate500, fontSize: 12)),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () => context.go('/treatment-plan/${widget.childId}'),
                    child: const Text('Design Plan'),
                  ),
                ],
              ),
            )
          else
            ..._plans.map((p) {
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.orange500.withValues(alpha: 0.05),
                  border: Border.all(color: AppColors.orange500.withValues(alpha: 0.15)),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(p.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    const SizedBox(height: 4),
                    Text(p.description, style: const TextStyle(color: AppColors.slate600, fontSize: 11), maxLines: 2, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Status: ${p.status.toUpperCase()}', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                        TextButton(
                          onPressed: () => context.go('/treatment-plan/${widget.childId}'),
                          child: const Text('View Details', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }

  // Column 2 component: Past Notes
  Widget _buildPastNotesCard(bool isDark, ThemeData theme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F172A) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: isDark ? Colors.white10 : AppColors.slate200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Past Notes', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          if (_notes.isEmpty)
            const Text('No notes yet', style: TextStyle(color: AppColors.slate500, fontSize: 12))
          else
            Container(
              constraints: const BoxConstraints(maxHeight: 250),
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: _notes.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, i) {
                  final n = _notes[i];
                  return Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1E293B) : AppColors.slate50,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(n.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                        const SizedBox(height: 4),
                        Text(n.content, style: const TextStyle(fontSize: 11, fontStyle: FontStyle.italic)),
                        const SizedBox(height: 6),
                        Align(
                          alignment: Alignment.bottomRight,
                          child: Text(
                            n.createdAt.split('T').first,
                            style: const TextStyle(color: AppColors.slate400, fontSize: 9),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  // Column 2 component: Add Note
  Widget _buildAddNoteCard(bool isDark, ThemeData theme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F172A) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: isDark ? Colors.white10 : AppColors.slate200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Add Session Note', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 14),
          TextField(
            controller: _noteController,
            maxLines: 4,
            decoration: InputDecoration(
              hintText: 'Add notes about this patient...',
              contentPadding: const EdgeInsets.all(16),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: AppColors.slate200)),
              filled: true,
              fillColor: isDark ? const Color(0xFF1E293B) : Colors.white,
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            height: 40,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.orange500, foregroundColor: Colors.white),
              onPressed: _savingNote ? null : _handleSaveNote,
              child: _savingNote
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Text('Save Note', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }
}
