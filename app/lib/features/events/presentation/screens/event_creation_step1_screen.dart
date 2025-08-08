import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../auth/presentation/widgets/auth_button.dart';
import '../cubits/event_creation_step1/event_creation_step1_cubit.dart';
import '../cubits/event_creation_step1/event_creation_step1_state.dart';
import '../widgets/event_text_field.dart';
import '../widgets/image_picker_widget.dart';
import '../widgets/datetime_picker_field.dart';
import '../models/event_title.dart';
import '../models/event_location.dart';
import '../models/event_datetime.dart';

class EventCreationStep1Screen extends StatelessWidget {
  const EventCreationStep1Screen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => EventCreationStep1Cubit(),
      child: const EventCreationStep1View(),
    );
  }
}

class EventCreationStep1View extends StatelessWidget {
  const EventCreationStep1View({Key? key}) : super(key: key);

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
      body: BlocListener<EventCreationStep1Cubit, EventCreationStep1State>(
        listener: (context, state) {
          if (state.errorMessage != null) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                SnackBar(
                  content: Text(state.errorMessage!),
                  backgroundColor: AppColors.coralRed,
                ),
              );
            context.read<EventCreationStep1Cubit>().clearError();
          }
        },
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppTheme.space5),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Progress indicator
                _buildProgressIndicator(1),
                const SizedBox(height: AppTheme.space6),
                
                // Header
                Text(
                  'The "What & Where"',
                  style: AppTypography.text2xl.copyWith(
                    color: AppColors.deepPurple,
                    fontWeight: AppTypography.bold,
                  ),
                ),
                const SizedBox(height: AppTheme.space2),
                Text(
                  'Essential details to get your event started',
                  style: AppTypography.textBase.copyWith(
                    color: AppColors.neutral600,
                  ),
                ),
                const SizedBox(height: AppTheme.space6),

                // Cover Image Picker
                _CoverImagePicker(),
                const SizedBox(height: AppTheme.space5),

                // Event Title
                _EventTitleInput(),
                const SizedBox(height: AppTheme.space5),

                // Event Description
                _EventDescriptionInput(),
                const SizedBox(height: AppTheme.space5),

                // Start Time
                _StartTimeInput(),
                const SizedBox(height: AppTheme.space5),

                // End Time
                _EndTimeInput(),
                const SizedBox(height: AppTheme.space5),

                // Location
                _LocationInput(),
                const SizedBox(height: AppTheme.space6),

                // Next Button
                _NextButton(),
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
        // Step 1 (current)
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: AppColors.deepPurple,
            borderRadius: BorderRadius.circular(AppTheme.radiusFull),
          ),
          child: Center(
            child: Text(
              '1',
              style: AppTypography.textSm.copyWith(
                color: AppColors.white,
                fontWeight: AppTypography.semibold,
              ),
            ),
          ),
        ),
        Expanded(
          child: Container(
            height: 2,
            color: AppColors.neutral200,
            margin: const EdgeInsets.symmetric(horizontal: AppTheme.space2),
          ),
        ),
        // Step 2 (upcoming)
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: AppColors.neutral200,
            borderRadius: BorderRadius.circular(AppTheme.radiusFull),
          ),
          child: Center(
            child: Text(
              '2',
              style: AppTypography.textSm.copyWith(
                color: AppColors.neutral500,
                fontWeight: AppTypography.semibold,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _CoverImagePicker extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<EventCreationStep1Cubit, EventCreationStep1State>(
      buildWhen: (previous, current) => previous.coverImage != current.coverImage,
      builder: (context, state) {
        return ImagePickerWidget(
          selectedImage: state.coverImage,
          onTap: () => context.read<EventCreationStep1Cubit>().pickCoverImage(),
          onRemove: state.coverImage != null
              ? () => context.read<EventCreationStep1Cubit>().removeCoverImage()
              : null,
        );
      },
    );
  }
}

class _EventTitleInput extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<EventCreationStep1Cubit, EventCreationStep1State>(
      buildWhen: (previous, current) => previous.title != current.title,
      builder: (context, state) {
        return EventTextField(
          label: 'Event Title *',
          hint: 'What\'s your event called?',
          onChanged: (title) => context.read<EventCreationStep1Cubit>().titleChanged(title),
          errorText: state.title.isNotValid && state.title.value.isNotEmpty
              ? _getEventTitleErrorText(state.title.error)
              : null,
          maxLength: 100,
        );
      },
    );
  }

  String? _getEventTitleErrorText(error) {
    switch (error) {
      case EventTitleValidationError.empty:
        return 'Event title is required';
      case EventTitleValidationError.tooLong:
        return 'Event title is too long';
      default:
        return null;
    }
  }
}

class _EventDescriptionInput extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<EventCreationStep1Cubit, EventCreationStep1State>(
      buildWhen: (previous, current) => previous.description != current.description,
      builder: (context, state) {
        return EventTextField(
          label: 'Event Description',
          hint: 'Tell people what to expect...',
          onChanged: (description) => 
              context.read<EventCreationStep1Cubit>().descriptionChanged(description),
          errorText: state.description.isNotValid
              ? 'Description is too long'
              : null,
          maxLines: 4,
          maxLength: 1000,
        );
      },
    );
  }
}

class _StartTimeInput extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<EventCreationStep1Cubit, EventCreationStep1State>(
      buildWhen: (previous, current) => previous.startTime != current.startTime,
      builder: (context, state) {
        return DateTimePickerField(
          label: 'Start Time *',
          selectedDateTime: state.startTime.value,
          onChanged: (dateTime) => 
              context.read<EventCreationStep1Cubit>().startTimeChanged(dateTime),
          errorText: state.startTime.isNotValid
              ? _getDateTimeErrorText(state.startTime.error)
              : null,
          firstDate: DateTime.now(),
        );
      },
    );
  }

  String? _getDateTimeErrorText(error) {
    switch (error) {
      case EventDateTimeValidationError.empty:
        return 'Start time is required';
      case EventDateTimeValidationError.pastDate:
        return 'Start time cannot be in the past';
      default:
        return null;
    }
  }
}

class _EndTimeInput extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<EventCreationStep1Cubit, EventCreationStep1State>(
      buildWhen: (previous, current) => 
          previous.endTime != current.endTime || previous.startTime != current.startTime,
      builder: (context, state) {
        String? errorText;
        if (state.endTime.isNotValid) {
          errorText = _getDateTimeErrorText(state.endTime.error);
        } else if (state.startTime.value != null && 
                   state.endTime.value != null && 
                   state.endTime.value!.isBefore(state.startTime.value!)) {
          errorText = 'End time must be after start time';
        }

        return DateTimePickerField(
          label: 'End Time *',
          selectedDateTime: state.endTime.value,
          onChanged: (dateTime) => 
              context.read<EventCreationStep1Cubit>().endTimeChanged(dateTime),
          errorText: errorText,
          firstDate: state.startTime.value ?? DateTime.now(),
        );
      },
    );
  }

  String? _getDateTimeErrorText(error) {
    switch (error) {
      case EventDateTimeValidationError.empty:
        return 'End time is required';
      case EventDateTimeValidationError.pastDate:
        return 'End time cannot be in the past';
      default:
        return null;
    }
  }
}

class _LocationInput extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<EventCreationStep1Cubit, EventCreationStep1State>(
      buildWhen: (previous, current) => previous.location != current.location,
      builder: (context, state) {
        return EventTextField(
          label: 'Location *',
          hint: 'Where will this event take place?',
          onChanged: (location) => 
              context.read<EventCreationStep1Cubit>().locationChanged(location),
          errorText: state.location.isNotValid && !state.location.isPure
              ? _getLocationErrorText(state.location.error)
              : null,
          maxLength: 200,
        );
      },
    );
  }

  String? _getLocationErrorText(error) {
    switch (error) {
      case EventLocationValidationError.empty:
        return 'Location is required';
      case EventLocationValidationError.tooLong:
        return 'Location is too long';
      default:
        return null;
    }
  }
}

class _NextButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<EventCreationStep1Cubit, EventCreationStep1State>(
      builder: (context, state) {
        return AuthButton(
          text: 'Next',
          onPressed: () {
            if (state.isValid) {
              // Navigate to Step 2 with the current state data
              context.pushReplacement(
                '/event/create/step2',
                extra: state,
              );
            } else {
              // Validate all fields to show errors
              context.read<EventCreationStep1Cubit>().validateAllFields();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Please fill in all required fields'),
                  backgroundColor: AppColors.coralRed,
                ),
              );
            }
          },
        );
      },
    );
  }
}