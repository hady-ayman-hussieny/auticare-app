import 'package:flutter/material.dart';
import 'package:auticare/core/theme/app_colors.dart';
import 'package:auticare/data/models/specialist.dart';

class SpecialistCard extends StatelessWidget {
  final SpecialistModel specialist;
  final VoidCallback? onTap;
  final VoidCallback? onBook;

  const SpecialistCard({
    super.key,
    required this.specialist,
    this.onTap,
    this.onBook,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xD90F172A) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isDark
                ? Colors.white.withValues(alpha: 0.1)
                : AppColors.slate200,
          ),
          boxShadow: isDark
              ? []
              : [
                  BoxShadow(
                    color: AppColors.slate200.withValues(alpha: 0.6),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  )
                ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Avatar
              _buildAvatar(),
              const SizedBox(width: 14),
              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      specialist.name,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      specialist.specialization,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.accentLight,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.star_rounded,
                            size: 15, color: Color(0xFFF59E0B)),
                        const SizedBox(width: 3),
                        Text(
                          specialist.rating.toStringAsFixed(1),
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(Icons.work_outline, size: 14,
                            color: AppColors.slate400),
                        const SizedBox(width: 3),
                        Text(
                          '${specialist.yearsOfExperience}y exp.',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: AppColors.slate500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Book button
              if (onBook != null)
                TextButton(
                  onPressed: onBook,
                  style: TextButton.styleFrom(
                    backgroundColor: AppColors.accentLight.withValues(alpha: 0.1),
                    foregroundColor: AppColors.accentLight,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  ),
                  child: const Text('Book',
                      style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    if (specialist.profileImage != null && specialist.profileImage!.isNotEmpty) {
      return CircleAvatar(
        radius: 28,
        backgroundImage: NetworkImage(specialist.profileImage!),
      );
    }
    final initials = specialist.name.isNotEmpty
        ? specialist.name.substring(0, 1).toUpperCase()
        : 'S';
    return CircleAvatar(
      radius: 28,
      backgroundColor: AppColors.orange100,
      child: Text(
        initials,
        style: const TextStyle(
          color: AppColors.accentLight,
          fontWeight: FontWeight.w700,
          fontSize: 20,
        ),
      ),
    );
  }
}
