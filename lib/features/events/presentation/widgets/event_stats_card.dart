import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../data/models/event_management_models.dart';
import '../../data/models/event_models.dart';

class EventStatsCard extends StatelessWidget {
  final EventManagementData eventData;

  const EventStatsCard({
    Key? key,
    required this.eventData,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.space4),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Event Stats',
            style: AppTypography.textLg.copyWith(
              color: AppColors.neutral950,
              fontWeight: AppTypography.semibold,
            ),
          ),
          const SizedBox(height: AppTheme.space4),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  label: 'Registered',
                  value: eventData.stats.registeredDisplay,
                  icon: Icons.people_outline,
                ),
              ),
              const SizedBox(width: AppTheme.space4),
              Expanded(
                child: _buildStatItem(
                  label: 'Team Size',
                  value: '${eventData.stats.teamSize}',
                  icon: Icons.group_outlined,
                ),
              ),
              const SizedBox(width: AppTheme.space4),
              Expanded(
                child: _buildStatItem(
                  label: 'Revenue',
                  value: _formatRevenue(eventData.stats.revenue, eventData.event.pricingModel),
                  icon: Icons.attach_money_outlined,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required String label,
    required String value,
    required IconData icon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              icon,
              size: 16,
              color: AppColors.neutral600,
            ),
            const SizedBox(width: AppTheme.space1),
            Text(
              label,
              style: AppTypography.textXs.copyWith(
                color: AppColors.neutral600,
                fontWeight: AppTypography.medium,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppTheme.space1),
        Text(
          value,
          style: AppTypography.textLg.copyWith(
            color: AppColors.neutral950,
            fontWeight: AppTypography.semibold,
          ),
        ),
      ],
    );
  }

  String _formatRevenue(double revenue, PricingModel pricingModel) {
    if (pricingModel == PricingModel.freeRsvp) {
      return '\$0';
    }
    return '\$${revenue.toInt()}';
  }
}