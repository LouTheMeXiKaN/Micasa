import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../data/repositories/event_repository.dart';
import '../../data/models/event_management_models.dart';
import '../bloc/event_management/event_management_bloc.dart';
import '../bloc/event_management/event_management_event.dart';
import '../bloc/event_management/event_management_state.dart';
import '../widgets/event_header_card.dart';
import '../widgets/event_stats_card.dart';
import '../widgets/management_action_button.dart';
import '../widgets/action_button_group.dart';

class EventManagementScreen extends StatelessWidget {
  final String eventId;

  const EventManagementScreen({
    Key? key,
    required this.eventId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => EventManagementBloc(
        eventRepository: context.read<EventRepository>(),
      )..add(LoadEventManagementData(eventId)),
      child: const EventManagementView(),
    );
  }
}

class EventManagementView extends StatelessWidget {
  const EventManagementView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocListener<EventManagementBloc, EventManagementState>(
      listener: (context, state) {
        if (state.status == EventManagementStatus.failure &&
            state.errorMessage != null) {
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
      child: Scaffold(
        backgroundColor: AppColors.neutral50,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: AppColors.neutral950),
            onPressed: () => context.go('/dashboard'),
          ),
          centerTitle: true,
        ),
        body: BlocBuilder<EventManagementBloc, EventManagementState>(
          builder: (context, state) {
            if (state.status == EventManagementStatus.loading) {
              return const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.deepPurple),
                ),
              );
            }

            if (state.status == EventManagementStatus.failure) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 48,
                      color: AppColors.coralRed,
                    ),
                    const SizedBox(height: AppTheme.space3),
                    Text(
                      'Failed to load event',
                      style: AppTypography.textLg.copyWith(
                        color: AppColors.neutral950,
                        fontWeight: AppTypography.semibold,
                      ),
                    ),
                    const SizedBox(height: AppTheme.space2),
                    Text(
                      state.errorMessage ?? 'Unknown error occurred',
                      style: AppTypography.textSm.copyWith(
                        color: AppColors.neutral600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppTheme.space4),
                    ElevatedButton(
                      onPressed: () => context.go('/dashboard'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.deepPurple,
                        foregroundColor: AppColors.white,
                      ),
                      child: const Text('Back to Dashboard'),
                    ),
                  ],
                ),
              );
            }

            if (state.eventData == null) {
              return const SizedBox.shrink();
            }

            final eventData = state.eventData!;

            return RefreshIndicator(
              onRefresh: () async {
                context.read<EventManagementBloc>().add(
                      RefreshEventStats(eventData.event.id ?? ''),
                    );
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(AppTheme.space4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Event Header
                    EventHeaderCard(eventData: eventData),
                    const SizedBox(height: AppTheme.space5),

                    // Event Stats
                    EventStatsCard(eventData: eventData),
                    const SizedBox(height: AppTheme.space6),

                    // Action Groups based on event phase
                    if (eventData.phase == EventPhase.preEvent) ...[
                      _buildPreEventActions(context, eventData),
                    ] else if (eventData.phase == EventPhase.liveEvent) ...[
                      _buildLiveEventActions(context, eventData),
                    ] else ...[
                      _buildPostEventActions(context, eventData),
                    ],

                    const SizedBox(height: AppTheme.space8),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildPreEventActions(BuildContext context, EventManagementData eventData) {
    return Column(
      children: [
        // Promotion & Discovery
        ActionButtonGroup(
          title: 'Promotion & Discovery',
          subtitle: 'Getting people interested and signed up',
          children: [
            ManagementActionButton(
              text: 'Preview',
              icon: Icons.visibility_outlined,
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Preview coming soon!')),
                );
              },
            ),
            ManagementActionButton(
              text: 'Share Event',
              icon: Icons.share_outlined,
              subtitle: 'Your referral link - track your impact!',
              onPressed: () {
                context.read<EventManagementBloc>().add(
                      ShareEventRequested(eventData.shareUrl),
                    );
              },
            ),
            ManagementActionButton(
              text: 'Get Event QR',
              icon: Icons.qr_code_outlined,
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('QR Code coming soon!')),
                );
              },
            ),
            ManagementActionButton(
              text: 'Invite Guests',
              icon: Icons.person_add_outlined,
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Invite Guests coming soon!')),
                );
              },
            ),
          ],
        ),
        const SizedBox(height: AppTheme.space6),

        // Operations & Guest Management
        ActionButtonGroup(
          title: 'Operations & Guest Management',
          subtitle: 'Managing the people coming to your event',
          children: [
            ManagementActionButton(
              text: 'View Guest List',
              icon: Icons.people_outline,
              isEnabled: eventData.permissions.canViewGuestList,
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Guest List coming soon!')),
                );
              },
            ),
            if (eventData.isDonationEvent)
              ManagementActionButton(
                text: 'Get Donation QR',
                icon: Icons.qr_code_2_outlined,
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Donation QR coming soon!')),
                  );
                },
              ),
            ManagementActionButton(
              text: 'Message Guests',
              icon: Icons.message_outlined,
              isEnabled: eventData.permissions.canMessageGuests,
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Message Guests coming soon!')),
                );
              },
            ),
          ],
        ),
        const SizedBox(height: AppTheme.space6),

        // Core Event & Team Administration
        ActionButtonGroup(
          title: 'Core Event & Team Administration',
          subtitle: 'Fundamental event setup and management',
          children: [
            ManagementActionButton(
              text: 'Manage Team',
              icon: Icons.group_outlined,
              isEnabled: eventData.permissions.canManageTeam,
              onPressed: () {
                context.push('/collaboration/${eventData.event.id}');
              },
            ),
            if (eventData.permissions.canEditDetails)
              ManagementActionButton(
                text: 'Edit Details',
                icon: Icons.edit_outlined,
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Edit Details coming soon!')),
                  );
                },
              ),
            if (eventData.permissions.canCancelEvent)
              ManagementActionButton(
                text: 'Cancel Event',
                icon: Icons.cancel_outlined,
                backgroundColor: AppColors.coralRed.withOpacity(0.1),
                onPressed: () {
                  _showCancelEventDialog(context);
                },
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildLiveEventActions(BuildContext context, EventManagementData eventData) {
    return ActionButtonGroup(
      title: 'Live Event Management',
      subtitle: 'Manage your event in real-time',
      children: [
        ManagementActionButton(
          text: 'Check In Guests',
          icon: Icons.check_circle_outline,
          isEnabled: eventData.permissions.canCheckInGuests,
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Check In Guests coming soon!')),
            );
          },
        ),
        ManagementActionButton(
          text: 'View Guest List',
          icon: Icons.people_outline,
          isEnabled: eventData.permissions.canViewGuestList,
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Guest List coming soon!')),
            );
          },
        ),
        ManagementActionButton(
          text: 'Message Guests',
          icon: Icons.message_outlined,
          isEnabled: eventData.permissions.canMessageGuests,
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Message Guests coming soon!')),
            );
          },
        ),
      ],
    );
  }

  Widget _buildPostEventActions(BuildContext context, EventManagementData eventData) {
    return ActionButtonGroup(
      title: 'Post-Event Management',
      subtitle: 'Wrap up your event and manage payouts',
      children: [
        if (eventData.permissions.canConfirmPayouts)
          ManagementActionButton(
            text: 'Confirm Payouts',
            icon: Icons.payment_outlined,
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Confirm Payouts coming soon!')),
              );
            },
          ),
        ManagementActionButton(
          text: 'View Event Summary',
          icon: Icons.analytics_outlined,
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Event Summary coming soon!')),
            );
          },
        ),
      ],
    );
  }

  void _showCancelEventDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text(
            'Cancel Event?',
            style: AppTypography.textLg.copyWith(
              fontWeight: AppTypography.bold,
              color: AppColors.neutral950,
            ),
          ),
          content: Text(
            'This action cannot be undone. All registered guests will be notified via email that the event has been canceled, and any payments will be refunded.',
            style: AppTypography.textSm.copyWith(
              color: AppColors.neutral700,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(
                'Nevermind',
                style: AppTypography.textSm.copyWith(
                  color: AppColors.neutral600,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Cancel Event functionality coming soon!'),
                    backgroundColor: AppColors.coralRed,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.coralRed,
                foregroundColor: AppColors.white,
              ),
              child: const Text('Yes, Cancel Event'),
            ),
          ],
        );
      },
    );
  }
}