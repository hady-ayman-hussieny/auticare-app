import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:auticare/core/constants/app_routes.dart';
import 'package:auticare/core/theme/app_colors.dart';

class ParentReScreeningScreen extends StatelessWidget {
  const ParentReScreeningScreen({super.key});

  Future<void> _handleStartReScreening(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final childId = prefs.getString('latestChildId');
    if (childId != null && childId.isNotEmpty) {
      await prefs.remove('screeningSubmitted_$childId');
      await prefs.remove('screeningResult_$childId');
      await prefs.remove('screening_answers_$childId');
      if (context.mounted) {
        context.go('${AppRoutes.screening}?childId=$childId');
      }
    } else {
      if (context.mounted) {
        context.go(AppRoutes.addChild);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF020617) : AppColors.bgLight,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 550),
            child: Card(
              color: isDark ? const Color(0xFF0F172A) : Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30.0),
              ),
              elevation: 8,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 40.0, horizontal: 28.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      '🔄',
                      style: TextStyle(fontSize: 64),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Ready to Re-take the Screening?',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : AppColors.slate900,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Taking the screening again helps you see how your child’s progress changes over time.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: isDark ? AppColors.slate400 : AppColors.slate600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),
                    Container(
                      padding: const EdgeInsets.all(20.0),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1E293B) : AppColors.slate50,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: isDark ? Colors.white10 : AppColors.slate200,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Why re-screen?',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : AppColors.slate950,
                            ),
                          ),
                          const SizedBox(height: 12),
                          _buildBenefitRow(theme, isDark, 'Track progress with fresh results'),
                          const SizedBox(height: 10),
                          _buildBenefitRow(theme, isDark, 'Receive updated guidance for your child\'s development'),
                          const SizedBox(height: 10),
                          _buildBenefitRow(theme, isDark, 'Compare the latest assessment with past screenings'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: isDark ? Colors.white : AppColors.slate700,
                              side: BorderSide(color: isDark ? Colors.white24 : AppColors.slate300),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            onPressed: () => context.go(AppRoutes.parentHome),
                            child: const Text('Back to Dashboard', style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.orange500,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            onPressed: () => _handleStartReScreening(context),
                            child: const Text('Start Re-Screen', style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBenefitRow(ThemeData theme, bool isDark, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '✓',
          style: TextStyle(color: AppColors.orange500, fontWeight: FontWeight.bold),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: theme.textTheme.bodySmall?.copyWith(
              color: isDark ? AppColors.slate300 : AppColors.slate700,
            ),
          ),
        ),
      ],
    );
  }
}
