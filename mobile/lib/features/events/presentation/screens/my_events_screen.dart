import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_theme.dart';

class MyEventsScreen extends StatelessWidget {
  const MyEventsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: AppColors.neutral50,
        appBar: AppBar(
          backgroundColor: AppColors.white,
          elevation: 0,
          title: Text(
            'My Events',
            style: AppTypography.textXl.copyWith(
              color: AppColors.neutral950,
              fontWeight: AppTypography.bold,
            ),
          ),
          bottom: TabBar(
            labelColor: AppColors.deepPurple,
            unselectedLabelColor: AppColors.neutral500,
            indicatorColor: AppColors.deepPurple,
            labelStyle: AppTypography.textBase.copyWith(
              fontWeight: AppTypography.semibold,
            ),
            tabs: const [
              Tab(text: 'Pending'),
              Tab(text: 'Upcoming'),
              Tab(text: 'Past'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // Pending Tab
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.pending_outlined,
                    size: 64,
                    color: AppColors.neutral400,
                  ),
                  const SizedBox(height: AppTheme.space4),
                  Text(
                    'No pending proposals or applications',
                    style: AppTypography.textBase.copyWith(
                      color: AppColors.neutral600,
                    ),
                  ),
                ],
              ),
            ),
            // Upcoming Tab
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.event_note_outlined,
                    size: 64,
                    color: AppColors.neutral400,
                  ),
                  const SizedBox(height: AppTheme.space4),
                  Text(
                    'No upcoming events',
                    style: AppTypography.textBase.copyWith(
                      color: AppColors.neutral600,
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
            // Past Tab
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.history_outlined,
                    size: 64,
                    color: AppColors.neutral400,
                  ),
                  const SizedBox(height: AppTheme.space4),
                  Text(
                    'Your past events will appear here',
                    style: AppTypography.textBase.copyWith(
                      color: AppColors.neutral600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}