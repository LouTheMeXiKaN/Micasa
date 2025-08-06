import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../auth/presentation/widgets/auth_button.dart';
import '../cubits/event_creation_step1/event_creation_step1_state.dart';
import '../cubits/event_creation_step2/event_creation_step2_cubit.dart';
import '../cubits/event_creation_step2/event_creation_step2_state.dart';
import '../widgets/event_text_field.dart';
import '../../data/models/event_models.dart';
import '../../data/repositories/event_repository.dart';
import '../models/max_capacity.dart';

class EventCreationStep2Screen extends StatelessWidget {
  final EventCreationStep1State step1Data;

  const EventCreationStep2Screen({
    Key? key,
    required this.step1Data,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => EventCreationStep2Cubit(
        context.read<EventRepository>(),
      ),
      child: EventCreationStep2View(step1Data: step1Data),
    );
  }
}

class EventCreationStep2View extends StatelessWidget {
  final EventCreationStep1State step1Data;

  const EventCreationStep2View({
    Key? key,
    required this.step1Data,
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
          'Create Event',
          style: AppTypography.textLg.copyWith(
            color: AppColors.neutral950,
            fontWeight: AppTypography.semibold,
          ),
        ),
        centerTitle: true,
      ),
      body: BlocListener<EventCreationStep2Cubit, EventCreationStep2State>(
        listener: (context, state) {
          if (state.status.isSuccess && state.createdEvent?.id != null) {
            // Navigate to Dynamic Event Management Screen with the created event ID
            context.pushReplacement('/event/manage/${state.createdEvent!.id}');
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Event created successfully! 🎉'),
                backgroundColor: AppColors.successGreen,
              ),
            );
          } else if (state.status.isFailure && state.errorMessage != null) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                SnackBar(
                  content: Text(state.errorMessage!),
                  backgroundColor: AppColors.coralRed,
                ),
              );
            context.read<EventCreationStep2Cubit>().clearError();
          }
        },
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppTheme.space5),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Progress indicator
                _buildProgressIndicator(2),
                const SizedBox(height: AppTheme.space6),
                
                // Header
                Text(
                  'The "Rules & How"',
                  style: AppTypography.text2xl.copyWith(
                    color: AppColors.deepPurple,
                    fontWeight: AppTypography.bold,
                  ),
                ),
                const SizedBox(height: AppTheme.space2),
                Text(
                  'Configure privacy and attendance settings',
                  style: AppTypography.textBase.copyWith(
                    color: AppColors.neutral600,
                  ),
                ),
                const SizedBox(height: AppTheme.space6),

                // Location Visibility Section
                _LocationVisibilitySection(),
                const SizedBox(height: AppTheme.space6),

                // Ticket Pricing Section (Free RSVP only for Stage 1)
                _TicketPricingSection(),
                const SizedBox(height: AppTheme.space6),

                // Max Capacity Section
                _MaxCapacitySection(),
                const SizedBox(height: AppTheme.space6),

                // Guest List Visibility Section
                _GuestListVisibilitySection(),
                const SizedBox(height: AppTheme.space6),

                // Event Privacy Section
                _EventPrivacySection(),
                const SizedBox(height: AppTheme.space6),

                // Publish Button
                _PublishEventButton(),
                const SizedBox(height: AppTheme.space4),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProgressIndicator(int currentStep) {
    return Row(
      children: [
        // Step 1 (completed)
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: AppColors.successGreen,
            borderRadius: BorderRadius.circular(AppTheme.radiusFull),
          ),
          child: const Center(
            child: Icon(
              Icons.check,
              size: 20,
              color: AppColors.white,
            ),
          ),
        ),
        Expanded(
          child: Container(
            height: 2,
            color: AppColors.deepPurple,
            margin: const EdgeInsets.symmetric(horizontal: AppTheme.space2),
          ),
        ),
        // Step 2 (current)
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: AppColors.deepPurple,
            borderRadius: BorderRadius.circular(AppTheme.radiusFull),
          ),
          child: Center(
            child: Text(
              '2',
              style: AppTypography.textSm.copyWith(
                color: AppColors.white,
                fontWeight: AppTypography.semibold,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _LocationVisibilitySection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<EventCreationStep2Cubit, EventCreationStep2State>(
      buildWhen: (previous, current) => 
          previous.locationVisibility != current.locationVisibility,
      builder: (context, state) {
        return _buildSection(
          title: 'Location Visibility',
          child: Column(
            children: [
              _buildRadioOption<LocationVisibility>(
                title: 'Show address immediately',
                subtitle: 'Location visible to everyone right away',
                value: LocationVisibility.immediate,
                groupValue: state.locationVisibility,
                onChanged: (value) => context
                    .read<EventCreationStep2Cubit>()
                    .locationVisibilityChanged(value!),
              ),
              _buildRadioOption<LocationVisibility>(
                title: 'Show address only to confirmed guests',
                subtitle: 'Only people who RSVP can see the address',
                value: LocationVisibility.onConfirmation,
                groupValue: state.locationVisibility,
                onChanged: (value) => context
                    .read<EventCreationStep2Cubit>()
                    .locationVisibilityChanged(value!),
              ),
              _buildRadioOption<LocationVisibility>(
                title: 'Reveal address 24 hours before event',
                subtitle: 'Address becomes visible one day before',
                value: LocationVisibility.twentyFourHoursBefore,
                groupValue: state.locationVisibility,
                onChanged: (value) => context
                    .read<EventCreationStep2Cubit>()
                    .locationVisibilityChanged(value!),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _TicketPricingSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return _buildSection(
      title: 'Ticket Pricing',
      child: Container(
        padding: const EdgeInsets.all(AppTheme.space4),
        decoration: BoxDecoration(
          color: AppColors.lightPeach.withOpacity(0.2),
          borderRadius: BorderRadius.circular(AppTheme.radiusSm),
          border: Border.all(
            color: AppColors.lightPeach.withOpacity(0.5),
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(AppTheme.space2),
              decoration: BoxDecoration(
                color: AppColors.successGreen,
                borderRadius: BorderRadius.circular(AppTheme.radiusFull),
              ),
              child: const Icon(
                Icons.check,
                size: 16,
                color: AppColors.white,
              ),
            ),
            const SizedBox(width: AppTheme.space3),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Free RSVP',
                    style: AppTypography.textBase.copyWith(
                      color: AppColors.neutral950,
                      fontWeight: AppTypography.semibold,
                    ),
                  ),
                  const SizedBox(height: AppTheme.space1),
                  Text(
                    'Guests can RSVP as Going, Maybe, or Not Going',
                    style: AppTypography.textSm.copyWith(
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

class _MaxCapacitySection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<EventCreationStep2Cubit, EventCreationStep2State>(
      buildWhen: (previous, current) => previous.maxCapacity != current.maxCapacity,
      builder: (context, state) {
        return _buildSection(
          title: 'Max Capacity (Optional)',
          child: EventTextField(
            label: 'Maximum number of attendees',
            hint: 'Leave empty for unlimited',
            onChanged: (value) => context
                .read<EventCreationStep2Cubit>()
                .maxCapacityChanged(value),
            keyboardType: TextInputType.number,
            errorText: state.maxCapacity.isNotValid
                ? _getMaxCapacityErrorText(state.maxCapacity.error)
                : null,
          ),
        );
      },
    );
  }

  String? _getMaxCapacityErrorText(error) {
    switch (error) {
      case MaxCapacityValidationError.invalid:
        return 'Please enter a valid number';
      case MaxCapacityValidationError.tooSmall:
        return 'Capacity must be at least 2';
      case MaxCapacityValidationError.tooLarge:
        return 'Capacity cannot exceed 10,000';
      default:
        return null;
    }
  }
}

class _GuestListVisibilitySection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<EventCreationStep2Cubit, EventCreationStep2State>(
      buildWhen: (previous, current) => 
          previous.guestListVisibility != current.guestListVisibility,
      builder: (context, state) {
        return _buildSection(
          title: 'Guest List Visibility',
          child: Column(
            children: [
              _buildRadioOption<GuestListVisibility>(
                title: '🌐 Public',
                subtitle: 'Everyone can see who\'s attending - Create FOMO',
                value: GuestListVisibility.public,
                groupValue: state.guestListVisibility,
                onChanged: (value) => context
                    .read<EventCreationStep2Cubit>()
                    .guestListVisibilityChanged(value!),
              ),
              _buildRadioOption<GuestListVisibility>(
                title: '🎟️ Attendees (Live)',
                subtitle: 'Only attendees see count before, full list during/after',
                value: GuestListVisibility.attendeesLive,
                groupValue: state.guestListVisibility,
                onChanged: (value) => context
                    .read<EventCreationStep2Cubit>()
                    .guestListVisibilityChanged(value!),
              ),
              _buildRadioOption<GuestListVisibility>(
                title: '🔒 Private',
                subtitle: 'Maximum privacy - Only you and co-hosts can see',
                value: GuestListVisibility.private,
                groupValue: state.guestListVisibility,
                onChanged: (value) => context
                    .read<EventCreationStep2Cubit>()
                    .guestListVisibilityChanged(value!),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _EventPrivacySection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<EventCreationStep2Cubit, EventCreationStep2State>(
      buildWhen: (previous, current) => previous.privacy != current.privacy,
      builder: (context, state) {
        return _buildSection(
          title: 'Event Privacy',
          child: CheckboxListTile(
            title: Text(
              'Private Event - Invite Only',
              style: AppTypography.textBase.copyWith(
                color: AppColors.neutral950,
                fontWeight: AppTypography.medium,
              ),
            ),
            subtitle: Text(
              'Only people you invite can see and RSVP to this event',
              style: AppTypography.textSm.copyWith(
                color: AppColors.neutral600,
              ),
            ),
            value: state.privacy == EventPrivacy.inviteOnly,
            onChanged: (value) => context
                .read<EventCreationStep2Cubit>()
                .privacyChanged(
                  value == true ? EventPrivacy.inviteOnly : EventPrivacy.public,
                ),
            activeColor: AppColors.deepPurple,
            contentPadding: EdgeInsets.zero,
            controlAffinity: ListTileControlAffinity.leading,
          ),
        );
      },
    );
  }
}

class _PublishEventButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<EventCreationStep2Cubit, EventCreationStep2State>(
      builder: (context, state) {
        return AuthButton(
          text: 'Publish Event',
          isLoading: state.status.isInProgress,
          onPressed: state.isValid && !state.status.isInProgress
              ? () async {
                  final step1Data = context
                      .findAncestorWidgetOfExactType<EventCreationStep2View>()
                      ?.step1Data;
                  if (step1Data != null) {
                    await context
                        .read<EventCreationStep2Cubit>()
                        .publishEvent(step1Data);
                  }
                }
              : null,
        );
      },
    );
  }
}

// Helper functions
Widget _buildSection({
  required String title,
  required Widget child,
}) {
  return Container(
    padding: const EdgeInsets.all(AppTheme.space5),
    decoration: BoxDecoration(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(AppTheme.radiusMd),
      boxShadow: AppTheme.cardShadow,
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTypography.textLg.copyWith(
            color: AppColors.neutral950,
            fontWeight: AppTypography.semibold,
          ),
        ),
        const SizedBox(height: AppTheme.space4),
        child,
      ],
    ),
  );
}

Widget _buildRadioOption<T>({
  required String title,
  required String subtitle,
  required T value,
  required T groupValue,
  required ValueChanged<T?> onChanged,
}) {
  return Container(
    margin: const EdgeInsets.only(bottom: AppTheme.space3),
    child: RadioListTile<T>(
      title: Text(
        title,
        style: AppTypography.textBase.copyWith(
          color: AppColors.neutral950,
          fontWeight: AppTypography.medium,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: AppTypography.textSm.copyWith(
          color: AppColors.neutral600,
        ),
      ),
      value: value,
      groupValue: groupValue,
      onChanged: onChanged,
      activeColor: AppColors.deepPurple,
      contentPadding: EdgeInsets.zero,
    ),
  );
}