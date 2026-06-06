import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../models/screening.dart';
import '../../services/screening_service.dart';
import '../../widgets/common/feedback_widgets.dart';

class PatientDetailScreen extends StatefulWidget {
  final String childId;
  const PatientDetailScreen({super.key, required this.childId});

  @override
  State<PatientDetailScreen> createState() => _PatientDetailScreenState();
}

class _PatientDetailScreenState extends State<PatientDetailScreen> {
  List<ScreeningResult> _results = [];
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
      final res = await screeningService.getResults(widget.childId);
      setState(() => _results = res);
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
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

    return Scaffold(
      appBar: AppBar(title: const Text('Patient Detail')),
      body: _loading
          ? const FullPageLoader()
          : _error.isNotEmpty
              ? Center(child: Text(_error, style: const TextStyle(color: AppColors.danger500)))
              : _results.isEmpty
                  ? const Center(child: Text('No screening results for this patient.'))
                  : ListView(
                      padding: const EdgeInsets.all(20),
                      children: [
                        Text('Screening History',
                            style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
                        const SizedBox(height: 16),
                        ..._results.map((r) {
                          final color = _riskColor(r.riskLevel);
                          return Container(
                            margin: const EdgeInsets.only(bottom: 14),
                            padding: const EdgeInsets.all(18),
                            decoration: BoxDecoration(
                              color: isDark ? const Color(0xFF0F172A) : Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: color.withValues(alpha: 0.3),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 22,
                                      backgroundColor: color.withValues(alpha: 0.1),
                                      child: Text(
                                        '${r.aqScore}',
                                        style: TextStyle(color: color, fontWeight: FontWeight.w800),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(r.predictionClass,
                                            style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
                                        Text(r.createdAt.split('T').first,
                                            style: theme.textTheme.bodySmall?.copyWith(color: AppColors.slate500)),
                                      ],
                                    ),
                                    const Spacer(),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: color.withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        r.riskLevel.toUpperCase(),
                                        style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w700),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 14),
                                const Divider(),
                                const SizedBox(height: 10),
                                _dimRow('Social Attention', r.socialAttention, theme),
                                _dimRow('Joint Attention', r.jointAttention, theme),
                                _dimRow('Social Communication', r.socialCommunication, theme),
                                _dimRow('Language', r.language, theme),
                              ],
                            ),
                          );
                        }),
                      ],
                    ),
    );
  }

  Widget _dimRow(String label, double score, ThemeData theme) {
    final color = score >= 0.7 ? AppColors.success500 : score >= 0.4 ? AppColors.warning500 : AppColors.danger500;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          SizedBox(width: 160, child: Text(label, style: theme.textTheme.bodySmall)),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: score.clamp(0.0, 1.0),
                minHeight: 6,
                backgroundColor: AppColors.slate200,
                valueColor: AlwaysStoppedAnimation(color),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text('${(score * 100).round()}%',
              style: TextStyle(color: color, fontWeight: FontWeight.w700, fontSize: 12)),
        ],
      ),
    );
  }
}
