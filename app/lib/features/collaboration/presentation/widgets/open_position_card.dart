import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../data/models/position_models.dart';
import 'profit_share_badge.dart';

class OpenPositionCard extends StatelessWidget {
  final OpenPosition position;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const OpenPositionCard({
    Key? key,
    required this.position,
    this.onTap,
    this.onEdit,
    this.onDelete,
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  position.roleTitle,
                                  style: AppTypography.textBase.copyWith(
                                    fontWeight: AppTypography.semibold,
                                    color: AppColors.neutral950,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (position.profitSharePercentage != null) ...[
                                const SizedBox(width: AppTheme.space2),
                                ProfitShareBadge(
                                  percentage: position.profitSharePercentage!,
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: AppTheme.space1),
                          Text(
                            _getApplicationCountText(),
                            style: AppTypography.textSm.copyWith(
                              color: position.applicantCount > 0 
                                  ? AppColors.vibrantOrange 
                                  : AppColors.neutral500,
                              fontWeight: position.applicantCount > 0 
                                  ? AppTypography.medium 
                                  : AppTypography.regular,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (onEdit != null || onDelete != null)
                      PopupMenuButton<String>(
                        onSelected: (value) {
                          switch (value) {
                            case 'edit':
                              onEdit?.call();
                              break;
                            case 'delete':
                              onDelete?.call();
                              break;
                          }
                        },
                        itemBuilder: (context) => [
                          if (onEdit != null)
                            const PopupMenuItem(
                              value: 'edit',
                              child: Row(
                                children: [
                                  Icon(Icons.edit, size: 18),
                                  SizedBox(width: 8),
                                  Text('Edit'),
                                ],
                              ),
                            ),
                          if (onDelete != null)
                            PopupMenuItem(
                              value: 'delete',
                              enabled: position.canDelete,
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.delete,
                                    size: 18,
                                    color: position.canDelete 
                                        ? AppColors.coralRed 
                                        : AppColors.neutral400,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Delete',
                                    style: TextStyle(
                                      color: position.canDelete 
                                          ? AppColors.coralRed 
                                          : AppColors.neutral400,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                        child: Container(
                          padding: const EdgeInsets.all(AppTheme.space2),
                          child: Icon(
                            Icons.more_vert,
                            color: AppColors.neutral500,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: AppTheme.space2),
                Text(
                  position.description,
                  style: AppTypography.textSm.copyWith(
                    color: AppColors.neutral600,
                    height: 1.4,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _getApplicationCountText() {
    if (position.applicantCount == 0) {
      return 'No applications yet';
    } else if (position.applicantCount == 1) {
      return '1 applicant';
    } else {
      return '${position.applicantCount} applicants';
    }
  }
}