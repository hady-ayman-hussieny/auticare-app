import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:auticare/core/theme/app_colors.dart';
import 'package:auticare/data/models/treatment_plan_model.dart';
import 'package:auticare/data/models/booking.dart';
import 'package:auticare/data/services/treatment_plans_service.dart';
import 'package:auticare/data/services/bookings_service.dart';
import 'package:auticare/features/auth/logic/auth_provider.dart';
import 'package:auticare/shared/components/app_shell.dart';

class TreatmentPlanScreen extends StatefulWidget {
  final String childId;
  const TreatmentPlanScreen({super.key, required this.childId});

  @override
  State<TreatmentPlanScreen> createState() => _TreatmentPlanScreenState();
}

class _TreatmentPlanScreenState extends State<TreatmentPlanScreen> {
  bool _loading = true;
  bool _saving = false;
  bool _editMode = false;
  
  TreatmentPlanModel? _plan;
  
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _goalInputController = TextEditingController();
  final _activityInputController = TextEditingController();
  final _recommendationsController = TextEditingController();
  final _notesController = TextEditingController();
  
  List<String> _goals = [];
  List<String> _homeActivities = [];
  String _status = 'active';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _goalInputController.dispose();
    _activityInputController.dispose();
    _recommendationsController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);
    try {
      // 1. Fetch child profile from bookings
      final bookings = await bookingsService.getMyBookings();
      final booking = bookings.firstWhere(
        (b) => b.childId == widget.childId,
        orElse: () => const BookingModel(
          id: '',
          parentId: '',
          parentName: '',
          childId: '',
          childName: '',
          specialistId: '',
          specialistType: '',
          status: '',
          appointmentDate: '',
          appointmentTime: '',
          duration: 0,
          createdAt: '',
          updatedAt: '',
        ),
      );

      if (booking.childId.isNotEmpty) {
        // Child info available from booking
      }

      // 2. Fetch treatment plans for child
      final plansService = TreatmentPlansService();
      final plans = await plansService.getChildPlans(widget.childId);
      if (plans.isNotEmpty) {
        _plan = plans.first;
        _titleController.text = _plan!.title;
        _descController.text = _plan!.description;
        _goals = List<String>.from(_plan!.goals);
        _homeActivities = List<String>.from(_plan!.homeActivities);
        _recommendationsController.text = _plan!.recommendations.join('\n');
        _notesController.text = _plan!.notes;
        _status = _plan!.status;
      }
    } catch (_) {}
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _savePlan(String specialistId) async {
    if (_titleController.text.trim().isEmpty) return;
    setState(() => _saving = true);

    try {
      final plansService = TreatmentPlansService();
      final finalNotes = _notesController.text.trim().isNotEmpty
          ? _notesController.text.trim()
          : _descController.text.trim().isNotEmpty
              ? _descController.text.trim()
              : 'Development and Clinical Treatment Plan';

      if (_plan != null) {
        // Update plan
        final updatePayload = {
          'goals': _goals,
          'homeActivities': _homeActivities,
          'recommendations': _recommendationsController.text.trim().split('\n'),
          'notes': finalNotes,
          'status': _status,
        };
        await plansService.updatePlan(_plan!.id, updatePayload);
      } else {
        // Create plan
        await plansService.createPlan(
          childId: widget.childId,
          specialistId: specialistId,
          startDate: DateTime.now().toIso8601String(),
          goal: _goals.isNotEmpty ? _goals.join('; ') : _titleController.text.trim(),
          notes: finalNotes,
        );
      }

      // Reload
      await _loadData();
      setState(() => _editMode = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Treatment plan saved successfully.')),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to save treatment plan.')),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _addGoal() {
    final text = _goalInputController.text.trim();
    if (text.isNotEmpty) {
      setState(() {
        _goals.add(text);
        _goalInputController.clear();
      });
    }
  }

  void _addActivity() {
    final text = _activityInputController.text.trim();
    if (text.isNotEmpty) {
      setState(() {
        _homeActivities.add(text);
        _activityInputController.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final isDoctor = auth.user?.role == 'doctor' || auth.user?.role == 'therapist';
    final isParent = auth.user?.role == 'parent';
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return AppShell(
      title: 'Treatment Plan',
      showBack: true,
      child: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isDark ? Colors.white12 : Colors.white,
                          foregroundColor: isDark ? Colors.white : AppColors.slate700,
                        ),
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.arrow_back, size: 16),
                        label: const Text('Back'),
                      ),
                      if (isDoctor && !_editMode)
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.orange500,
                            foregroundColor: Colors.white,
                          ),
                          onPressed: () {
                            setState(() {
                              _editMode = true;
                              if (_goals.isEmpty) {
                                _goals = ['Improve social integration milestones', 'Establish clear visual schedules'];
                              }
                              if (_homeActivities.isEmpty) {
                                _homeActivities = ['15 mins pointing exercises', 'Establish a calm corner routine'];
                              }
                            });
                          },
                          icon: const Icon(Icons.edit_rounded, size: 16),
                          label: Text(_plan != null ? 'Modify Treatment Plan' : 'Create Treatment Plan'),
                        ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  
                  if (isParent)
                    _buildDisclaimerCard(
                      '🛡️ Parent Development Support',
                      'This plan is authored by certified professionals to assist your child\'s learning and clinical progression. Consult your pediatrician before altering therapy frequencies.',
                      AppColors.orange500,
                    ),
                  
                  const SizedBox(height: 20),

                  if (_editMode)
                    _buildEditMode(auth.user?.id ?? '', isDark, theme)
                  else
                    _buildViewMode(isDark, theme),
                ],
              ),
            ),
    );
  }

  Widget _buildDisclaimerCard(String title, String desc, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.05),
        border: Border.all(color: color.withValues(alpha: 0.2)),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 13)),
          const SizedBox(height: 6),
          Text(desc, style: const TextStyle(fontSize: 12, height: 1.4)),
        ],
      ),
    );
  }

  // Edit Mode Screen
  Widget _buildEditMode(String specialistId, bool isDark, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F172A) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: isDark ? Colors.white10 : AppColors.slate200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Configure Clinical Plan', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 16),
          
          TextField(
            controller: _titleController,
            decoration: const InputDecoration(labelText: 'Plan Title', hintText: 'e.g. Behavioral & Sensory Development Plan'),
          ),
          const SizedBox(height: 14),
          
          TextField(
            controller: _descController,
            maxLines: 3,
            decoration: const InputDecoration(labelText: 'Description Summary', hintText: 'e.g. Custom clinical pathway focusing on language stimulation...'),
          ),
          const SizedBox(height: 14),
          
          DropdownButtonFormField<String>(
            initialValue: _status,
            decoration: const InputDecoration(labelText: 'Status'),
            items: const [
              DropdownMenuItem(value: 'active', child: Text('Active')),
              DropdownMenuItem(value: 'completed', child: Text('Completed')),
              DropdownMenuItem(value: 'paused', child: Text('Paused')),
            ],
            onChanged: (val) => setState(() => _status = val ?? 'active'),
          ),
          
          const SizedBox(height: 20),
          const Divider(),
          const SizedBox(height: 16),
          
          Text('Goals Configuration', style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _goalInputController,
                  decoration: const InputDecoration(hintText: 'Add new development target'),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                style: IconButton.styleFrom(
                  backgroundColor: AppColors.orange500,
                  foregroundColor: Colors.white,
                ),
                onPressed: _addGoal,
                icon: const Icon(Icons.add),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _goals.length,
            itemBuilder: (context, i) {
              return ListTile(
                title: Text(_goals[i], style: const TextStyle(fontSize: 13)),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => setState(() => _goals.removeAt(i)),
                ),
              );
            },
          ),
          
          const SizedBox(height: 20),
          const Divider(),
          const SizedBox(height: 16),
          
          Text('Assigned Home Activities', style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _activityInputController,
                  decoration: const InputDecoration(hintText: 'Add daily routine / home homework'),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                style: IconButton.styleFrom(
                  backgroundColor: AppColors.orange500,
                  foregroundColor: Colors.white,
                ),
                onPressed: _addActivity,
                icon: const Icon(Icons.add),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _homeActivities.length,
            itemBuilder: (context, i) {
              return ListTile(
                title: Text(_homeActivities[i], style: const TextStyle(fontSize: 13)),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => setState(() => _homeActivities.removeAt(i)),
                ),
              );
            },
          ),
          
          const SizedBox(height: 20),
          const Divider(),
          const SizedBox(height: 16),
          
          TextField(
            controller: _recommendationsController,
            maxLines: 3,
            decoration: const InputDecoration(labelText: 'Recommendations & Clinical Guidelines'),
          ),
          const SizedBox(height: 14),
          
          TextField(
            controller: _notesController,
            maxLines: 2,
            decoration: const InputDecoration(labelText: 'Clinical Notes'),
          ),
          
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              OutlinedButton(
                onPressed: () => setState(() => _editMode = false),
                child: const Text('Cancel'),
              ),
              const SizedBox(width: 12),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green[600], foregroundColor: Colors.white),
                onPressed: _saving ? null : () => _savePlan(specialistId),
                child: Text(_saving ? 'Publishing...' : 'Publish Treatment Plan'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // View Mode Screen
  Widget _buildViewMode(bool isDark, ThemeData theme) {
    if (_plan == null) {
      return Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Column(
          children: [
            const Text('📋', style: TextStyle(fontSize: 48)),
            const SizedBox(height: 14),
            Text('No Treatment Plan', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            const Text(
              'A detailed clinical treatment plan hasn\'t been designed for this child profile yet.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.slate500, fontSize: 12),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        // Title card
        Container(
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
                  Expanded(
                    child: Text(
                      _plan!.title,
                      style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.green.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _plan!.status.toUpperCase(),
                      style: const TextStyle(color: Colors.green, fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                _plan!.description,
                style: const TextStyle(fontSize: 13, height: 1.4),
              ),
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Start Date', style: TextStyle(fontSize: 10, color: AppColors.slate400, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text(_plan!.startDate.split('T').first, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text('End Date', style: TextStyle(fontSize: 10, color: AppColors.slate400, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text(
                        _plan!.endDate != null && _plan!.endDate!.isNotEmpty
                            ? _plan!.endDate!.split('T').first
                            : 'Continuous Evaluation',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Goals card
        Container(
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
              Text('Active Goals', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 14),
              if (_goals.isEmpty)
                const Text('No structured goals configured.', style: TextStyle(color: AppColors.slate500, fontSize: 12))
              else
                ..._goals.asMap().entries.map((e) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1E293B) : AppColors.slate50,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CircleAvatar(
                          radius: 10,
                          backgroundColor: AppColors.orange100,
                          child: Text('${e.key + 1}', style: const TextStyle(color: AppColors.orange500, fontSize: 9, fontWeight: FontWeight.bold)),
                        ),
                        const SizedBox(width: 10),
                        Expanded(child: Text(e.value, style: const TextStyle(fontSize: 13))),
                      ],
                    ),
                  );
                }),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Home Activities Card
        Container(
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
              Text('Home Activities & Routines', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 14),
              if (_homeActivities.isEmpty)
                const Text('No home routines configured.', style: TextStyle(color: AppColors.slate500, fontSize: 12))
              else
                ..._homeActivities.map((act) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1E293B) : AppColors.slate50,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        const Text('🏡 ', style: TextStyle(fontSize: 14)),
                        Expanded(child: Text(act, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600))),
                      ],
                    ),
                  );
                }),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Recommendations Card
        Container(
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
              Text('Recommendations & Clinical Guidelines', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 14),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E293B) : AppColors.slate50,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Clinical Recommendations', style: TextStyle(fontSize: 10, color: AppColors.slate400, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(
                      _plan!.recommendations.isNotEmpty ? _plan!.recommendations.join('\n') : 'No recommendations recorded.',
                      style: const TextStyle(fontSize: 12, height: 1.4),
                    ),
                    if (_plan!.notes.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      const Divider(),
                      const SizedBox(height: 8),
                      const Text('Clinical Note', style: TextStyle(fontSize: 10, color: AppColors.slate400, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text(_plan!.notes, style: const TextStyle(fontSize: 12, height: 1.4)),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
