import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';

class ManagementActionButton extends StatelessWidget {
  final String text;
  final IconData icon;
  final VoidCallback? onPressed;
  final String? subtitle;
  final bool isEnabled;
  final Color? backgroundColor;

  const ManagementActionButton({
    Key? key,
    required this.text,
    required this.icon,
    this.onPressed,
    this.subtitle,
    this.isEnabled = true,
    this.backgroundColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final effectiveBackgroundColor = backgroundColor ?? AppColors.white;
    
    return Opacity(
      opacity: isEnabled ? 1.0 : 0.6,
      child: Container(
        decoration: BoxDecoration(
          color: effectiveBackgroundColor,
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          boxShadow: AppTheme.cardShadow,
          border: Border.all(
            color: AppColors.neutral200,
            width: 1,
          ),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: isEnabled ? onPressed : null,
            borderRadius: BorderRadius.circular(AppTheme.radiusMd),
            child: Padding(
              padding: const EdgeInsets.all(AppTheme.space4),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppColors.deepPurple.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                    ),
                    child: Icon(
                      icon,
                      size: 24,
                      color: AppColors.deepPurple,
                    ),
                  ),
                  const SizedBox(width: AppTheme.space3),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          text,
                          style: AppTypography.textBase.copyWith(
                            color: AppColors.neutral950,
                            fontWeight: AppTypography.semibold,
                          ),
                        ),
                        if (subtitle != null) ...[
                          const SizedBox(height: AppTheme.space1),
                          Text(
                            subtitle!,
                            style: AppTypography.textXs.copyWith(
                              color: AppColors.neutral600,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: AppColors.neutral400,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}