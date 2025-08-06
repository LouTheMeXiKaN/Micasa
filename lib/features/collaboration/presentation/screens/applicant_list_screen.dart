import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../data/repositories/collaboration_repository.dart';
import '../cubits/applicants/applicants_cubit.dart';
import '../cubits/applicants/applicants_state.dart';
import '../widgets/applicant_card.dart';

class ApplicantListScreen extends StatelessWidget {
  final String positionId;
  final String positionTitle;

  const ApplicantListScreen({
    Key? key,
    required this.positionId,
    required this.positionTitle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ApplicantsCubit(
        context.read<CollaborationRepository>(),
        positionId,
      )..loadApplications(),
      child: ApplicantListView(positionTitle: positionTitle),
    );
  }
}

class ApplicantListView extends StatelessWidget {
  final String positionTitle;

  const ApplicantListView({
    Key? key,
    required this.positionTitle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.neutral50,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.neutral950),
          onPressed: () => context.pop(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Applications for:',
              style: AppTypography.textSm.copyWith(
                color: AppColors.neutral600,
                fontWeight: AppTypography.regular,
              ),
            ),
            Text(
              positionTitle,
              style: AppTypography.textBase.copyWith(
                color: AppColors.neutral950,
                fontWeight: AppTypography.semibold,
              ),
            ),
          ],
        ),
        toolbarHeight: 72,
      ),
      body: BlocConsumer<ApplicantsCubit, ApplicantsState>(
        listener: (context, state) {
          if (state.status == ApplicantsStatus.failure && state.errorMessage != null) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                SnackBar(
                  content: Text(state.errorMessage!),
                  backgroundColor: AppColors.coralRed,
                ),
              );
          }
        },
        builder: (context, state) {
          if (state.status == ApplicantsStatus.loading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (state.status == ApplicantsStatus.failure) {
            return _buildErrorState(context);
          }

          return Column(
            children: [
              // Application count header
              _buildApplicationCountHeader(state.applications.length),
              // Applications list
              Expanded(
                child: state.applications.isEmpty
                    ? _buildEmptyState()
                    : _buildApplicationsList(context, state),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildApplicationCountHeader(int count) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.space5,
        vertical: AppTheme.space3,
      ),
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border(
          bottom: BorderSide(
            color: AppColors.neutral100,
            width: 1,
          ),
        ),
      ),
      child: Text(
        count == 0
            ? 'No applications yet'
            : count == 1
                ? '1 application'
                : '$count applications',
        style: AppTypography.textSm.copyWith(
          color: AppColors.neutral600,
          fontWeight: AppTypography.medium,
        ),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 48,
            color: AppColors.neutral400,
          ),
          const SizedBox(height: AppTheme.space4),
          Text(
            'Failed to load applications',
            style: AppTypography.textBase.copyWith(
              color: AppColors.neutral600,
            ),
          ),
          const SizedBox(height: AppTheme.space4),
          ElevatedButton(
            onPressed: () {
              context.read<ApplicantsCubit>().refresh();
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.space6),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.neutral100,
                borderRadius: BorderRadius.circular(AppTheme.radiusFull),
              ),
              child: Icon(
                Icons.inbox_outlined,
                size: 40,
                color: AppColors.neutral400,
              ),
            ),
            const SizedBox(height: AppTheme.space4),
            Text(
              'No applications yet',
              style: AppTypography.textLg.copyWith(
                fontWeight: AppTypography.semibold,
                color: AppColors.neutral600,
              ),
            ),
            const SizedBox(height: AppTheme.space2),
            Text(
              'Share your event to attract collaborators!',
              style: AppTypography.textBase.copyWith(
                color: AppColors.neutral500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildApplicationsList(BuildContext context, ApplicantsState state) {
    return RefreshIndicator(
      onRefresh: () async {
        context.read<ApplicantsCubit>().refresh();
      },
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(AppTheme.space5),
        itemCount: state.applications.length,
        itemBuilder: (context, index) {
          final application = state.applications[index];
          return ApplicantCard(
            application: application,
            isExpanded: state.isCardExpanded(application.id),
            isProcessing: state.isApplicationProcessing(application.id),
            onToggleExpansion: () => context
                .read<ApplicantsCubit>()
                .toggleCardExpansion(application.id),
            onAccept: () => _handleAcceptApplication(context, application.id),
            onDecline: () => _handleDeclineApplication(context, application.id),
          );
        },
      ),
    );
  }

  void _handleAcceptApplication(BuildContext context, String applicationId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Accept Application'),
        content: const Text(
          'Are you sure you want to accept this application? The applicant will be added to your team.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.read<ApplicantsCubit>().acceptApplication(applicationId);
            },
            style: TextButton.styleFrom(
              foregroundColor: AppColors.successGreen,
            ),
            child: const Text('Accept'),
          ),
        ],
      ),
    );
  }

  void _handleDeclineApplication(BuildContext context, String applicationId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Decline Application'),
        content: const Text(
          'Are you sure you want to decline this application? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.read<ApplicantsCubit>().declineApplication(applicationId);
            },
            style: TextButton.styleFrom(
              foregroundColor: AppColors.coralRed,
            ),
            child: const Text('Decline'),
          ),
        ],
      ),
    );
  }
}