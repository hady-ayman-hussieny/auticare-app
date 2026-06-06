import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants.dart';
import '../../core/theme/app_colors.dart';
import '../../models/screening.dart';
import '../../services/screening_service.dart';
import '../../widgets/common/feedback_widgets.dart';
import '../../widgets/common/gradient_button.dart';

class ScreeningResultsScreen extends StatefulWidget {
  final String childId;
  const ScreeningResultsScreen({super.key, required this.childId});

  @override
  State<ScreeningResultsScreen> createState() => _ScreeningResultsScreenState();
}

class _ScreeningResultsScreenState extends State<ScreeningResultsScreen> {
  ScreeningResult? _result;
  bool _loading = true;
  String _error = '';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = ''; });
    try {
      final results = await screeningService.getResults(widget.childId);
      if (results.isNotEmpty) {
        setState(() => _result = results.last);
      } else {
        setState(() => _error = 'No results found for this child.');
      }
    } catch (e) {
      setState(() => _error = e.toString().replaceAll('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Color _riskColor(String riskLevel) {
    switch (riskLevel.toLowerCase()) {
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

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.go(AppRoutes.parentHome),
        ),
        title: const Text('Screening Results'),
      ),
      body: _loading
          ? const FullPageLoader(message: 'Loading results...')
          : _error.isNotEmpty && _result == null
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.error_outline, size: 48, color: AppColors.danger500),
                      const SizedBox(height: 12),
                      Text(_error, textAlign: TextAlign.center),
                      const SizedBox(height: 16),
                      ElevatedButton(onPressed: _load, child: const Text('Retry')),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _load,
                  child: ListView(
                    padding: const EdgeInsets.all(20),
                    children: [
                      _buildResultSummary(isDark, theme),
                      const SizedBox(height: 20),
                      _buildScoreBreakdown(isDark, theme),
                      const SizedBox(height: 20),
                      _buildRecommendations(isDark, theme),
                      const SizedBox(height: 24),
                      GradientButton(
                        label: 'Find a Specialist',
                        icon: Icons.medical_services_rounded,
                        onPressed: () => context.go(AppRoutes.doctors),
                      ),
                      const SizedBox(height: 12),
                      OutlinedButton(
                        onPressed: () => context.go(AppRoutes.parentHome),
                        child: const Text('Back to Dashboard'),
                      ),
                    ],
                  ),
                ),
    );
  }

  Widget _buildResultSummary(bool isDark, ThemeData theme) {
    final r = _result!;
    final riskColor = _riskColor(r.riskLevel);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: riskColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: riskColor.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 40,
            backgroundColor: riskColor.withValues(alpha: 0.15),
            child: Text(
              '${r.aqScore}',
              style: TextStyle(
                color: riskColor,
                fontSize: 28,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            r.childName.isNotEmpty ? r.childName : 'Child',
            style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: riskColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '${r.riskLevel.toUpperCase()} RISK',
              style: TextStyle(
                color: riskColor,
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            r.predictionClass,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColors.mutedLight,
              fontWeight: FontWeight.w500,
            ),
          ),
          if (r.probability.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              'Confidence: ${(double.tryParse(r.probability) ?? r.confidenceScore * 100).toStringAsFixed(1)}%',
              style: theme.textTheme.bodySmall?.copyWith(color: AppColors.slate500),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildScoreBreakdown(bool isDark, ThemeData theme) {
    final r = _result!;
    final dims = [
      ('Social Attention', r.socialAttention),
      ('Joint Attention', r.jointAttention),
      ('Social Communication', r.socialCommunication),
      ('Language', r.language),
      ('Imagination', r.imagination),
      ('Repetitive Behavior', r.repetitiveBehavior),
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F172A) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? Colors.white.withValues(alpha: 0.08) : AppColors.slate200,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Score Breakdown',
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 16),
          ...dims.map((d) => _buildDimensionRow(d.$1, d.$2, theme)),
        ],
      ),
    );
  }

  Widget _buildDimensionRow(String label, double score, ThemeData theme) {
    final color = score >= 0.7 ? AppColors.success500 : score >= 0.4 ? AppColors.warning500 : AppColors.danger500;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w500)),
              Text('${(score * 100).round()}%',
                  style: TextStyle(color: color, fontWeight: FontWeight.w700, fontSize: 13)),
            ],
          ),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: score.clamp(0.0, 1.0),
              minHeight: 7,
              backgroundColor: AppColors.slate200,
              valueColor: AlwaysStoppedAnimation(color),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendations(bool isDark, ThemeData theme) {
    final r = _result!;
    final isHighRisk = r.riskLevel.toLowerCase() == 'high';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F172A) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? Colors.white.withValues(alpha: 0.08) : AppColors.slate200,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Recommendations',
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 14),
          if (isHighRisk) ...[
            _buildRecItem(Icons.priority_high_rounded, AppColors.danger500,
                'Consult a specialist immediately.'),
            _buildRecItem(Icons.medical_services_rounded, AppColors.danger500,
                'Schedule an appointment with a qualified autism specialist.'),
          ] else ...[
            _buildRecItem(Icons.monitor_heart_rounded, AppColors.warning500,
                'Continue monitoring your child\'s development.'),
            _buildRecItem(Icons.calendar_today_rounded, AppColors.warning500,
                'Consider a follow-up screening in 3–6 months.'),
          ],
          _buildRecItem(Icons.people_rounded, AppColors.primary500,
              'Engage in social and play activities with your child.'),
        ],
      ),
    );
  }

  Widget _buildRecItem(IconData icon, Color color, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 10),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 14))),
        ],
      ),
    );
  }
}
