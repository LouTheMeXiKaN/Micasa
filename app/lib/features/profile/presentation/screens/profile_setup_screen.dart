import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../auth/presentation/widgets/auth_text_field.dart';
import '../../../auth/presentation/widgets/auth_button.dart';
import '../cubits/profile_setup/profile_setup_cubit.dart';
import '../cubits/profile_setup/profile_setup_state.dart';
import '../../data/repositories/profile_repository.dart';

class ProfileSetupScreen extends StatelessWidget {
  const ProfileSetupScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ProfileSetupCubit(context.read<ProfileRepository>()),
      child: const ProfileSetupView(),
    );
  }
}

class ProfileSetupView extends StatelessWidget {
  const ProfileSetupView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.neutral50,
      body: BlocConsumer<ProfileSetupCubit, ProfileSetupState>(
        listener: (context, state) {
          if (state.status.isFailure && state.errorMessage != null) {
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
          return SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppTheme.space5),
                child: _ProfileForm(),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ProfileForm extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Logo placeholder
        Container(
          width: 80,
          height: 80,
          margin: const EdgeInsets.only(bottom: AppTheme.space6),
          decoration: BoxDecoration(
            color: AppColors.deepPurple,
            borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          ),
          child: Center(
            child: Text(
              'M',
              style: AppTypography.text3xl.copyWith(
                color: AppColors.white,
                fontWeight: AppTypography.bold,
              ),
            ),
          ),
        ),
        // Headline
        Text(
          'Welcome to the Community!',
          style: AppTypography.text2xl.copyWith(
            color: AppColors.deepPurple,
            fontWeight: AppTypography.bold,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppTheme.space3),
        Text(
          'Let\'s get your profile ready. What should we call you, and how can we reach you?',
          style: AppTypography.textBase.copyWith(
            color: AppColors.neutral600,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppTheme.space6),
        _UsernameInput(),
        const SizedBox(height: AppTheme.space5),
        _PhoneNumberInput(),
        const SizedBox(height: AppTheme.space6),
        _SubmitButton(),
      ],
    );
  }
}

class _UsernameInput extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileSetupCubit, ProfileSetupState>(
      buildWhen: (previous, current) => previous.username != current.username,
      builder: (context, state) {
        return AuthTextField(
          label: 'Username',
          hint: 'Choose a unique username',
          onChanged: (username) => context.read<ProfileSetupCubit>().usernameChanged(username),
          errorText: state.username.isNotValid && state.username.value.isNotEmpty
              ? 'Username must be at least 3 characters (letters, numbers, underscore only)'
              : null,
        );
      },
    );
  }
}

class _PhoneNumberInput extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileSetupCubit, ProfileSetupState>(
      buildWhen: (previous, current) => previous.phoneNumber != current.phoneNumber,
      builder: (context, state) {
        return AuthTextField(
          label: 'Phone Number',
          hint: 'Enter your phone number',
          onChanged: (phoneNumber) => context.read<ProfileSetupCubit>().phoneNumberChanged(phoneNumber),
          keyboardType: TextInputType.phone,
          errorText: state.phoneNumber.isNotValid && state.phoneNumber.value.isNotEmpty
              ? 'Please enter a valid phone number'
              : null,
        );
      },
    );
  }
}

class _SubmitButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileSetupCubit, ProfileSetupState>(
      builder: (context, state) {
        final isValid = Formz.validate([state.username, state.phoneNumber]);
        return AuthButton(
          text: 'Complete Setup',
          isLoading: state.status.isInProgress,
          onPressed: isValid && !state.status.isInProgress
              ? () => context.read<ProfileSetupCubit>().submitProfile()
              : null,
        );
      },
    );
  }
}

