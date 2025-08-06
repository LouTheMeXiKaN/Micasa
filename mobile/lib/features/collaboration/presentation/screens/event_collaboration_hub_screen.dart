import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../data/repositories/collaboration_repository.dart';
import '../../data/models/collaborator_models.dart';
import '../../data/models/position_models.dart';
import '../cubits/collaboration_hub/collaboration_hub_cubit.dart';
import '../cubits/collaboration_hub/collaboration_hub_state.dart';
import '../widgets/collaborator_card.dart';
import '../widgets/open_position_card.dart';

class EventCollaborationHubScreen extends StatelessWidget {
  final String eventId;

  const EventCollaborationHubScreen({
    Key? key,
    required this.eventId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => CollaborationHubCubit(
        context.read<CollaborationRepository>(),
        eventId,
      )..loadCollaborationData(),
      child: EventCollaborationHubView(eventId: eventId),
    );
  }
}

class EventCollaborationHubView extends StatelessWidget {
  final String eventId;

  const EventCollaborationHubView({
    Key? key,
    required this.eventId,
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
        title: Text(
          'Manage Team',
          style: AppTypography.textLg.copyWith(
            color: AppColors.neutral950,
            fontWeight: AppTypography.semibold,
          ),
        ),
      ),
      body: BlocConsumer<CollaborationHubCubit, CollaborationHubState>(
        listener: (context, state) {
          if (state.status == CollaborationHubStatus.failure && state.errorMessage != null) {
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
          if (state.status == CollaborationHubStatus.loading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (state.status == CollaborationHubStatus.failure) {
            return _buildErrorState(context);
          }

          if (state.data == null) {
            return const SizedBox.shrink();
          }

          return RefreshIndicator(
            onRefresh: () async {
              context.read<CollaborationHubCubit>().refresh();
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(AppTheme.space5),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildCollaboratorsSection(context, state.data!),
                  const SizedBox(height: AppTheme.space6),
                  _buildOpenPositionsSection(context, state.data!),
                  const SizedBox(height: AppTheme.space6),
                  _buildActionButtons(context),
                ],
              ),
            ),
          );
        },
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
            'Failed to load team data',
            style: AppTypography.textBase.copyWith(
              color: AppColors.neutral600,
            ),
          ),
          const SizedBox(height: AppTheme.space4),
          ElevatedButton(
            onPressed: () {
              context.read<CollaborationHubCubit>().refresh();
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildCollaboratorsSection(BuildContext context, CollaborationHubData data) {
    if (!data.hasCollaborators) {
      return _buildEmptyCollaboratorsState();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Collaborators',
          style: AppTypography.textLg.copyWith(
            fontWeight: AppTypography.semibold,
            color: AppColors.neutral950,
          ),
        ),
        const SizedBox(height: AppTheme.space4),
        
        // Co-hosts section
        if (data.cohosts.isNotEmpty) ...[
          Text(
            'Co-hosts',
            style: AppTypography.textBase.copyWith(
              fontWeight: AppTypography.medium,
              color: AppColors.neutral700,
            ),
          ),
          const SizedBox(height: AppTheme.space3),
          ...data.cohosts.map((cohost) => 
            CollaboratorCard(
              collaborator: cohost,
              onTap: () => _navigateToUserProfile(context, cohost.userId),
            ),
          ),
          const SizedBox(height: AppTheme.space4),
        ],

        // Team members section
        if (data.teamMembers.isNotEmpty) ...[
          Text(
            'Team Members',
            style: AppTypography.textBase.copyWith(
              fontWeight: AppTypography.medium,
              color: AppColors.neutral700,
            ),
          ),
          const SizedBox(height: AppTheme.space3),
          ...data.teamMembers.map((member) => 
            CollaboratorCard(
              collaborator: member,
              onTap: () => _navigateToUserProfile(context, member.userId),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildEmptyCollaboratorsState() {
    return Container(
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
            Icons.people_outline,
            size: 48,
            color: AppColors.neutral400,
          ),
          const SizedBox(height: AppTheme.space3),
          Text(
            'No team members yet',
            style: AppTypography.textBase.copyWith(
              fontWeight: AppTypography.medium,
              color: AppColors.neutral600,
            ),
          ),
          const SizedBox(height: AppTheme.space2),
          Text(
            'Invite collaborators to help make your event amazing!',
            style: AppTypography.textSm.copyWith(
              color: AppColors.neutral500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildOpenPositionsSection(BuildContext context, CollaborationHubData data) {
    if (!data.hasOpenPositions) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Open Positions',
          style: AppTypography.textLg.copyWith(
            fontWeight: AppTypography.semibold,
            color: AppColors.neutral950,
          ),
        ),
        const SizedBox(height: AppTheme.space4),
        ...data.openPositions.map((position) => 
          OpenPositionCard(
            position: position,
            onTap: position.applicantCount > 0 
                ? () => _navigateToApplicantList(context, position.id, position.roleTitle)
                : null,
            onEdit: () => _navigateToEditPosition(context, position),
            onDelete: position.canDelete 
                ? () => _showDeletePositionDialog(context, position)
                : null,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ElevatedButton.icon(
          onPressed: () => _navigateToInviteCollaborator(context),
          icon: const Icon(Icons.person_add),
          label: const Text('Invite Collaborator'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.deepPurple,
            foregroundColor: AppColors.white,
            padding: const EdgeInsets.symmetric(vertical: AppTheme.space4),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppTheme.radiusSm),
            ),
          ),
        ),
        const SizedBox(height: AppTheme.space3),
        OutlinedButton.icon(
          onPressed: () => _navigateToCreatePosition(context),
          icon: const Icon(Icons.add),
          label: const Text('Create Open Position'),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.deepPurple,
            padding: const EdgeInsets.symmetric(vertical: AppTheme.space4),
            side: BorderSide(color: AppColors.deepPurple),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppTheme.radiusSm),
            ),
          ),
        ),
      ],
    );
  }

  void _navigateToUserProfile(BuildContext context, String userId) {
    // TODO: Navigate to user profile screen
    // context.push('/user/$userId');
  }

  void _navigateToApplicantList(BuildContext context, String positionId, String positionTitle) {
    context.push('/collaboration/applicants/$positionId', extra: positionTitle);
  }

  void _navigateToInviteCollaborator(BuildContext context) {
    // TODO: Navigate to invite collaborator screen
    // context.push('/collaboration/$eventId/invite');
  }

  void _navigateToCreatePosition(BuildContext context) {
    context.push('/collaboration/$eventId/position/create');
  }

  void _navigateToEditPosition(BuildContext context, OpenPosition position) {
    context.push('/collaboration/$eventId/position/${position.id}/edit', extra: position);
  }

  void _showDeletePositionDialog(BuildContext context, OpenPosition position) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Position'),
        content: Text(
          'Are you sure you want to delete "${position.roleTitle}"? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.read<CollaborationHubCubit>().deletePosition(position.id);
            },
            style: TextButton.styleFrom(
              foregroundColor: AppColors.coralRed,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}