import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../data/models/collaborator_models.dart';
import 'role_badge.dart';
import 'profit_share_badge.dart';

class CollaboratorCard extends StatelessWidget {
  final Collaborator collaborator;
  final VoidCallback? onTap;

  const CollaboratorCard({
    Key? key,
    required this.collaborator,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppTheme.space3),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          child: Container(
            padding: const EdgeInsets.all(AppTheme.space4),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(AppTheme.radiusMd),
              boxShadow: AppTheme.cardShadow,
            ),
            child: Row(
              children: [
                // Profile Picture
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.neutral200,
                    borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                  ),
                  child: collaborator.profilePictureUrl != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                          child: Image.network(
                            collaborator.profilePictureUrl!,
                            width: 48,
                            height: 48,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => 
                                _buildInitialsAvatar(),
                          ),
                        )
                      : _buildInitialsAvatar(),
                ),
                const SizedBox(width: AppTheme.space3),
                // User Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              collaborator.username,
                              style: AppTypography.textBase.copyWith(
                                fontWeight: AppTypography.semibold,
                                color: AppColors.neutral950,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: AppTheme.space2),
                          RoleBadge(
                            role: collaborator.role,
                            customRoleTitle: collaborator.roleTitle,
                          ),
                        ],
                      ),
                      const SizedBox(height: AppTheme.space1),
                      Row(
                        children: [
                          Text(
                            collaborator.roleTitle,
                            style: AppTypography.textSm.copyWith(
                              color: AppColors.neutral600,
                            ),
                          ),
                          const Spacer(),
                          ProfitShareBadge(
                            percentage: collaborator.profitShare,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInitialsAvatar() {
    final initials = collaborator.username.isNotEmpty 
        ? collaborator.username.substring(0, 1).toUpperCase()
        : '?';
    
    return Center(
      child: Text(
        initials,
        style: AppTypography.textLg.copyWith(
          color: AppColors.neutral600,
          fontWeight: AppTypography.semibold,
        ),
      ),
    );
  }
}