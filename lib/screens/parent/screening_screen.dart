import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants.dart';
import '../../core/theme/app_colors.dart';
import '../../models/screening.dart';
import '../../services/screening_service.dart';
import '../../widgets/common/gradient_button.dart';

class ScreeningScreen extends StatefulWidget {
  final String? childId;
  const ScreeningScreen({super.key, this.childId});

  @override
  State<ScreeningScreen> createState() => _ScreeningScreenState();
}

class _ScreeningScreenState extends State<ScreeningScreen> {
  List<ScreeningQuestion> _questions = [];
  Map<String, String> _answers = {}; // questionId → optionId
  int _currentPage = 1;
  bool _loading = true;
  bool _submitting = false;
  String _error = '';
  String? _childId;
  String _childName = '';


  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final prefs = await SharedPreferences.getInstance();
    final resolvedId = widget.childId ??
        prefs.getString('latestChildId');

    if (resolvedId == null || resolvedId.isEmpty) {
      if (mounted) context.go(AppRoutes.addChild);
      return;
    }

    _childId = resolvedId;
    _childName = prefs.getString('latestChildName') ?? '';

    // Try to start a backend session
    try {
      await screeningService.startScreening(resolvedId);
    } catch (_) {}

    // Always use hardcoded questions (matches web app behaviour)
    setState(() {
      _questions = kLocalScreeningQuestions;
      _loading = false;
    });
  }

  Future<void> _handleNext() async {
    if (_currentPage < _questions.length) {
      setState(() => _currentPage++);
    } else {
      await _submit();
    }
  }

  void _handlePrev() {
    if (_currentPage > 1) setState(() => _currentPage--);
  }

  Future<void> _submit() async {
    setState(() { _submitting = true; _error = ''; });
    try {
      final payloadAnswers = _answers.entries.map((entry) {
        final q = _questions.firstWhere((q) => q.id == entry.key);
        final opt = q.options.firstWhere((o) => o.id == entry.value);
        final qNum = int.tryParse(q.id.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
        return {'questionId': qNum, 'answerValue': opt.value};
      }).toList();

      await screeningService.submitScreening(_childId!, payloadAnswers);

      // Cache result
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('screeningSubmitted_$_childId', true);

      if (!mounted) return;
      context.go('${AppRoutes.screeningResults}?childId=$_childId');
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

    if (_loading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Screening')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final question = _questions[_currentPage - 1];
    final progress = _currentPage / _questions.length;
    final selected = _answers[question.id];

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () async {
            final confirm = await showDialog<bool>(
              context: context,
              builder: (_) => AlertDialog(
                title: const Text('Exit Screening?'),
                content: const Text('Your progress will be lost.'),
                actions: [
                  TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
                  TextButton(
                    onPressed: () => Navigator.pop(context, true),
                    child: const Text('Exit', style: TextStyle(color: AppColors.danger500)),
                  ),
                ],
              ),
            );
            if ((confirm ?? false) && mounted) context.go(AppRoutes.parentHome);
          },
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Autism Screening'),
            if (_childName.isNotEmpty)
              Text('for $_childName',
                  style: theme.textTheme.bodySmall?.copyWith(color: AppColors.mutedLight)),
          ],
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // Progress bar
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Question $_currentPage of ${_questions.length}',
                          style: theme.textTheme.bodySmall?.copyWith(color: AppColors.slate500)),
                      Text('${(progress * 100).round()}%',
                          style: theme.textTheme.bodySmall?.copyWith(
                              color: AppColors.accentLight, fontWeight: FontWeight.w600)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 8,
                      backgroundColor: isDark
                          ? Colors.white.withValues(alpha: 0.1)
                          : AppColors.orange100,
                      valueColor: const AlwaysStoppedAnimation(AppColors.accentLight),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 28),

              // Question card
              Expanded(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF0F172A) : Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.08)
                          : AppColors.slate200,
                    ),
                    boxShadow: isDark
                        ? []
                        : [
                            BoxShadow(
                              color: AppColors.slate200.withValues(alpha: 0.5),
                              blurRadius: 16,
                              offset: const Offset(0, 4),
                            )
                          ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.accentLight.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'Question $_currentPage',
                          style: TextStyle(
                            color: AppColors.accentLight,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        question.question,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Answer options
                      ...question.options.map((opt) {
                        final isSelected = selected == opt.id;
                        return GestureDetector(
                          onTap: () => setState(() => _answers[question.id] = opt.id),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppColors.accentLight.withValues(alpha: 0.1)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: isSelected ? AppColors.accentLight : AppColors.slate300,
                                width: isSelected ? 2 : 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  width: 20,
                                  height: 20,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: isSelected ? AppColors.accentLight : Colors.transparent,
                                    border: Border.all(
                                      color: isSelected ? AppColors.accentLight : AppColors.slate400,
                                      width: 2,
                                    ),
                                  ),
                                  child: isSelected
                                      ? const Icon(Icons.check, size: 12, color: Colors.white)
                                      : null,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    opt.label,
                                    style: TextStyle(
                                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                                      color: isSelected ? AppColors.accentLight : null,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }),

                      if (_error.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.danger500.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(_error,
                              style: const TextStyle(color: AppColors.danger500, fontSize: 13)),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Navigation bar
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF0F172A) : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isDark ? Colors.white.withValues(alpha: 0.08) : AppColors.slate200,
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _currentPage == 1 || _submitting ? null : _handlePrev,
                        child: const Text('← Previous'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: GradientButton(
                        label: _currentPage == _questions.length ? '✓ Submit' : 'Continue →',
                        isLoading: _submitting,
                        onPressed: selected == null || _submitting ? null : _handleNext,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
