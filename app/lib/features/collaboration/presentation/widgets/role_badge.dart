import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../data/models/collaborator_models.dart';

class RoleBadge extends StatelessWidget {
  final CollaboratorRole role;
  final String? customRoleTitle;
  final bool showCustomRole;

  const RoleBadge({
    Key? key,
    required this.role,
    this.customRoleTitle,
    this.showCustomRole = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final (backgroundColor, textColor, displayText) = _getBadgeProperties();

    // Slightly imperfect rotation for personality
    return Transform.rotate(
      angle: -0.02,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppTheme.space3,
          vertical: AppTheme.space1,
        ),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(AppTheme.radiusFull),
        ),
        child: Text(
          displayText,
          style: AppTypography.textXs.copyWith(
            color: textColor,
            fontWeight: AppTypography.semibold,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }

  (Color, Color, String) _getBadgeProperties() {
    switch (role) {
      case CollaboratorRole.host:
        return (
          AppColors.deepPurple,
          AppColors.white,
          'HOST',
        );
      case CollaboratorRole.cohost:
        return (
          AppColors.forestGreen,
          AppColors.white,
          'CO-HOST',
        );
      case CollaboratorRole.member:
        final displayText = showCustomRole && customRoleTitle != null
            ? customRoleTitle!.toUpperCase()
            : 'MEMBER';
        return (
          AppColors.sage,
          AppColors.white,
          displayText,
        );
    }
  }
}