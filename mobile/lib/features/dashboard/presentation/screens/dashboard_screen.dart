import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_theme.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.neutral50,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(AppTheme.space5),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome back',
                      style: AppTypography.textLg.copyWith(
                        color: AppColors.neutral600,
                      ),
                    ),
                    const SizedBox(height: AppTheme.space1),
                    Text(
                      'Dashboard',
                      style: AppTypography.text2xl.copyWith(
                        color: AppColors.deepPurple,
                        fontWeight: AppTypography.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // Upcoming Events Section
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppTheme.space5),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Upcoming Events',
                          style: AppTypography.textXl.copyWith(
                            color: AppColors.neutral950,
                            fontWeight: AppTypography.semibold,
                          ),
                        ),
                        // TODO: Add "View all →" link when > 4 events
                      ],
                    ),
                    const SizedBox(height: AppTheme.space4),
                    
                    // Empty state
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(AppTheme.space6),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                        boxShadow: AppTheme.cardShadow,
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.event_outlined,
                            size: 48,
                            color: AppColors.neutral400,
                          ),
                          const SizedBox(height: AppTheme.space3),
                          Text(
                            'No upcoming events',
                            style: AppTypography.textBase.copyWith(
                              color: AppColors.neutral600,
                              fontWeight: AppTypography.medium,
                            ),
                          ),
                          const SizedBox(height: AppTheme.space2),
                          Text(
                            'Create your first event!',
                            style: AppTypography.textSm.copyWith(
                              color: AppColors.neutral500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // Bottom padding to ensure FAB doesn't overlap content
            const SliverToBoxAdapter(
              child: SizedBox(height: 100),
            ),
          ],
        ),
      ),
      floatingActionButton: _buildFAB(context),
    );
  }
  
  Widget _buildFAB(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppTheme.radiusFull),
        boxShadow: [
          BoxShadow(
            color: AppColors.vibrantOrange.withValues(alpha: 0.3),
            offset: const Offset(0, 4),
            blurRadius: 12,
            spreadRadius: 0,
          ),
        ],
      ),
      child: FloatingActionButton.extended(
        onPressed: () {
          // Navigate to Screen 5: Event Creation
          context.push('/event/create');
        },
        backgroundColor: AppColors.vibrantOrange,
        foregroundColor: AppColors.white,
        elevation: 0,
        label: Row(
          children: [
            const Icon(Icons.add, size: 20),
            const SizedBox(width: AppTheme.space2),
            Text(
              'Create Event',
              style: AppTypography.textBase.copyWith(
                fontWeight: AppTypography.semibold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}