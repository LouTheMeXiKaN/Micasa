import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';

class ActionButtonGroup extends StatelessWidget {
  final String title;
  final String subtitle;
  final List<Widget> children;

  const ActionButtonGroup({
    Key? key,
    required this.title,
    required this.subtitle,
    required this.children,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppTheme.space1),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTypography.textLg.copyWith(
                  color: AppColors.neutral950,
                  fontWeight: AppTypography.semibold,
                ),
              ),
              const SizedBox(height: AppTheme.space1),
              Text(
                subtitle,
                style: AppTypography.textSm.copyWith(
                  color: AppColors.neutral600,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppTheme.space3),
        ...children.map((child) => Padding(
              padding: const EdgeInsets.only(bottom: AppTheme.space3),
              child: child,
            )),
      ],
    );
  }
}