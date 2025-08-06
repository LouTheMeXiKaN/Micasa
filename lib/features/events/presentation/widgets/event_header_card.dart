import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../data/models/event_management_models.dart';
import '../../data/models/user_role.dart';

class EventHeaderCard extends StatelessWidget {
  final EventManagementData eventData;

  const EventHeaderCard({
    Key? key,
    required this.eventData,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Cover Image
          Container(
            height: 200,
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppColors.neutral100,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(AppTheme.radiusMd),
                topRight: Radius.circular(AppTheme.radiusMd),
              ),
              image: eventData.event.coverImageUrl != null
                  ? DecorationImage(
                      image: NetworkImage(eventData.event.coverImageUrl!),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: eventData.event.coverImageUrl == null
                ? const Center(
                    child: Icon(
                      Icons.image_outlined,
                      size: 48,
                      color: AppColors.neutral400,
                    ),
                  )
                : null,
          ),
          
          // Event Info
          Padding(
            padding: const EdgeInsets.all(AppTheme.space4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Event Title and Role Badge
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        eventData.event.title,
                        style: AppTypography.textXl.copyWith(
                          color: AppColors.neutral950,
                          fontWeight: AppTypography.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppTheme.space2),
                    _buildRoleBadge(),
                  ],
                ),
                const SizedBox(height: AppTheme.space3),
                
                // Date and Time
                Row(
                  children: [
                    const Icon(
                      Icons.calendar_today_outlined,
                      size: 16,
                      color: AppColors.neutral600,
                    ),
                    const SizedBox(width: AppTheme.space2),
                    Text(
                      DateFormat('EEE, MMM d • h:mm a').format(eventData.event.startTime),
                      style: AppTypography.textSm.copyWith(
                        color: AppColors.neutral600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppTheme.space2),
                
                // Location
                Row(
                  children: [
                    const Icon(
                      Icons.location_on_outlined,
                      size: 16,
                      color: AppColors.neutral600,
                    ),
                    const SizedBox(width: AppTheme.space2),
                    Expanded(
                      child: Text(
                        eventData.event.location,
                        style: AppTypography.textSm.copyWith(
                          color: AppColors.neutral600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoleBadge() {
    Color badgeColor;
    switch (eventData.userRole) {
      case UserEventRole.host:
        badgeColor = AppColors.deepPurple;
        break;
      case UserEventRole.cohost:
        badgeColor = AppColors.forestGreen;
        break;
      case UserEventRole.collaborator:
        badgeColor = AppColors.sage;
        break;
      case UserEventRole.attendee:
        badgeColor = AppColors.neutral400;
        break;
    }

    return Transform.rotate(
      angle: -0.02, // Slightly imperfect rotation for personality
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppTheme.space2,
          vertical: AppTheme.space1,
        ),
        decoration: BoxDecoration(
          color: badgeColor,
          borderRadius: BorderRadius.circular(AppTheme.radiusXl),
        ),
        child: Text(
          eventData.userRoleDisplayName.toUpperCase(),
          style: AppTypography.textXs.copyWith(
            color: AppColors.white,
            fontWeight: AppTypography.semibold,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }
}