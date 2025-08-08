import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';

class ProfitShareBadge extends StatelessWidget {
  final double percentage;
  final bool isTransparent;

  const ProfitShareBadge({
    Key? key,
    required this.percentage,
    this.isTransparent = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.space2,
        vertical: AppTheme.space1,
      ),
      decoration: BoxDecoration(
        color: isTransparent 
            ? AppColors.warmOrange.withOpacity(0.1)
            : AppColors.warmOrange,
        borderRadius: BorderRadius.circular(AppTheme.radiusSm),
        border: Border.all(
          color: AppColors.warmOrange,
          width: 1,
        ),
      ),
      child: Text(
        '${percentage.toStringAsFixed(percentage.truncateToDouble() == percentage ? 0 : 1)}%',
        style: AppTypography.textXs.copyWith(
          color: isTransparent ? AppColors.warmOrange : AppColors.white,
          fontWeight: AppTypography.semibold,
        ),
      ),
    );
  }
}