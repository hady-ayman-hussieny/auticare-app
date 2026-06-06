import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants.dart';
import '../../core/theme/app_colors.dart';
import '../../services/children_service.dart';
import '../../widgets/common/gradient_button.dart';
import '../../widgets/common/app_text_field.dart';
import '../../widgets/common/feedback_widgets.dart';

class AddChildScreen extends StatefulWidget {
  const AddChildScreen({super.key});

  @override
  State<AddChildScreen> createState() => _AddChildScreenState();
}

class _AddChildScreenState extends State<AddChildScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _dobCtrl = TextEditingController();
  final _medHistoryCtrl = TextEditingController();
  String _gender = 'Male';
  bool _familyAutism = false;
  bool _jaundice = false;
  bool _loading = false;
  String _error = '';

  final _genders = ['Male', 'Female', 'Other'];

  @override
  void dispose() {
    _nameCtrl.dispose();
    _dobCtrl.dispose();
    _medHistoryCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() { _loading = true; _error = ''; });
    try {
      final child = await childrenService.createChild({
        'name': _nameCtrl.text.trim(),
        'dateOfBirth': _dobCtrl.text.trim(),
        'gender': _gender,
        'medicalHistory': _medHistoryCtrl.text.trim(),
        'familyAutismHistory': _familyAutism,
        'jaundiceHistory': _jaundice,
      });

      // Persist child ID like web app (latestChildId / latestChildName)
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('latestChildId', child.id);
      await prefs.setString('latestChildName', child.name);

      if (!mounted) return;
      context.go('${AppRoutes.screening}?childId=${child.id}');
    } catch (e) {
      setState(() => _error = e.toString().replaceAll('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(now.year - 3),
      firstDate: DateTime(now.year - 18),
      lastDate: now,
    );
    if (picked != null) {
      _dobCtrl.text =
          '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.go(AppRoutes.parentHome),
        ),
        title: const Text('Add Child'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Header
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: isDark ? AppColors.primaryGradientDark : AppColors.primaryGradientLight,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      children: [
                        const Icon(Icons.child_care_rounded, color: Colors.white, size: 40),
                        const SizedBox(height: 10),
                        Text(
                          'Register Your Child',
                          style: theme.textTheme.titleLarge?.copyWith(color: Colors.white, fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Fill in the details to start the autism screening',
                          style: theme.textTheme.bodySmall?.copyWith(color: Colors.white70),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  ErrorBanner(message: _error, onDismiss: () => setState(() => _error = '')),

                  AppTextField(
                    label: 'Child\'s full name',
                    controller: _nameCtrl,
                    textInputAction: TextInputAction.next,
                    prefixIcon: const Icon(Icons.person_outline_rounded),
                    validator: (v) => v == null || v.trim().isEmpty ? 'Name is required' : null,
                  ),
                  const SizedBox(height: 16),

                  // Date of birth
                  GestureDetector(
                    onTap: _pickDate,
                    child: AbsorbPointer(
                      child: AppTextField(
                        label: 'Date of birth',
                        hint: 'YYYY-MM-DD',
                        controller: _dobCtrl,
                        prefixIcon: const Icon(Icons.cake_rounded),
                        validator: (v) => v == null || v.trim().isEmpty ? 'Date of birth is required' : null,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Gender dropdown
                  DropdownButtonFormField<String>(
                    initialValue: _gender,
                    decoration: InputDecoration(
                      labelText: 'Gender',
                      prefixIcon: const Icon(Icons.wc_rounded),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    items: _genders
                        .map((g) => DropdownMenuItem(value: g, child: Text(g)))
                        .toList(),
                    onChanged: (v) => setState(() => _gender = v!),
                  ),
                  const SizedBox(height: 16),

                  AppTextField(
                    label: 'Medical history (optional)',
                    controller: _medHistoryCtrl,
                    maxLines: 3,
                    prefixIcon: const Icon(Icons.medical_information_outlined),
                  ),
                  const SizedBox(height: 20),

                  // Checkboxes
                  _buildCheckTile(
                    'Family history of autism',
                    _familyAutism,
                    (v) => setState(() => _familyAutism = v!),
                  ),
                  _buildCheckTile(
                    'History of jaundice',
                    _jaundice,
                    (v) => setState(() => _jaundice = v!),
                  ),
                  const SizedBox(height: 24),

                  GradientButton(
                    label: 'Save & Start Screening',
                    isLoading: _loading,
                    onPressed: _loading ? null : _submit,
                    icon: Icons.arrow_forward_rounded,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCheckTile(String label, bool value, ValueChanged<bool?> onChange) {
    return CheckboxListTile(
      title: Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
      value: value,
      onChanged: onChange,
      contentPadding: EdgeInsets.zero,
      controlAffinity: ListTileControlAffinity.leading,
    );
  }
}
