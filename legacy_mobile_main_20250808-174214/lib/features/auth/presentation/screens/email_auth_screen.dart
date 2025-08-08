import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:formz/formz.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../data/repositories/auth_repository.dart';
import '../cubits/login/login_cubit.dart';
import '../cubits/login/login_state.dart';
import '../cubits/signup/signup_cubit.dart';
import '../cubits/signup/signup_state.dart';
import '../widgets/auth_button.dart';
import '../widgets/auth_text_field.dart';

class EmailAuthScreen extends StatelessWidget {
  const EmailAuthScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Provide both Cubits to the view hierarchy
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => LoginCubit(context.read<AuthRepository>()),
        ),
        BlocProvider(
          create: (context) => SignUpCubit(context.read<AuthRepository>()),
        ),
      ],
      child: const EmailAuthView(),
    );
  }
}

class EmailAuthView extends StatefulWidget {
  const EmailAuthView({Key? key}) : super(key: key);

  @override
  State<EmailAuthView> createState() => _EmailAuthViewState();
}

// Removed all local state management (TextEditingControllers, FormKeys, _acceptedTerms)
class _EmailAuthViewState extends State<EmailAuthView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

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
      ),
      // Use MultiBlocListener to listen for submission errors from both Cubits
      body: MultiBlocListener(
        listeners: [
          BlocListener<LoginCubit, LoginState>(
            listener: (context, state) {
              if (state.status.isFailure && state.errorMessage != null) {
                _showError(context, state.errorMessage!);
              }
            },
          ),
          BlocListener<SignUpCubit, SignUpState>(
            listener: (context, state) {
              if (state.status.isFailure && state.errorMessage != null) {
                 _showError(context, state.errorMessage!);
              }
            },
          ),
        ],
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppTheme.space5),
            child: Column(
              children: [
                // Tab Bar
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.neutral100,
                    borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                  ),
                  child: TabBar(
                    controller: _tabController,
                    indicator: BoxDecoration(
                      color: AppColors.deepPurple,
                      borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                    ),
                    labelColor: AppColors.white,
                    unselectedLabelColor: AppColors.neutral600,
                    labelStyle: AppTypography.textBase.copyWith(
                      fontWeight: AppTypography.semibold,
                    ),
                    tabs: const [
                      Tab(text: 'Sign Up'),
                      Tab(text: 'Log In'),
                    ],
                  ),
                ),
                const SizedBox(height: AppTheme.space6),
                // Tab Views
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: const [
                      _SignUpForm(),
                      _LoginForm(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  void _showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: AppColors.coralRed,
        ),
      );
  }
}

// Extracted Forms and Inputs for cleaner state management

class _SignUpForm extends StatelessWidget {
  const _SignUpForm({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _SignUpEmailInput(),
          const SizedBox(height: AppTheme.space5),
          _SignUpPasswordInput(),
          const SizedBox(height: AppTheme.space5),
          _TermsCheckbox(),
          const SizedBox(height: AppTheme.space6),
          _SignUpButton(),
        ],
      ),
    );
  }
}

// Implementations of _SignUpEmailInput, _SignUpPasswordInput, _TermsCheckbox, _SignUpButton
// Example: _SignUpEmailInput
class _SignUpEmailInput extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SignUpCubit, SignUpState>(
      buildWhen: (previous, current) => previous.email != current.email,
      builder: (context, state) {
        return AuthTextField(
          label: 'Email',
          hint: 'Enter your email',
          onChanged: (email) => context.read<SignUpCubit>().emailChanged(email),
          keyboardType: TextInputType.emailAddress,
          errorText: state.email.isNotValid && state.email.value.isNotEmpty ? 'Invalid email' : null,
        );
      },
    );
  }
}

class _SignUpPasswordInput extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SignUpCubit, SignUpState>(
      buildWhen: (previous, current) => previous.password != current.password,
      builder: (context, state) {
        return AuthTextField(
          label: 'Password',
          hint: 'Create a password',
          onChanged: (password) => context.read<SignUpCubit>().passwordChanged(password),
          isPassword: true,
          errorText: state.password.isNotValid && state.password.value.isNotEmpty
              ? 'Password must be at least 8 characters'
              : null,
        );
      },
    );
  }
}

class _TermsCheckbox extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SignUpCubit, SignUpState>(
      buildWhen: (previous, current) => previous.termsAcceptance != current.termsAcceptance,
      builder: (context, state) {
        return Row(
          children: [
            Checkbox(
              value: state.termsAcceptance.value,
              onChanged: (value) {
                context.read<SignUpCubit>().termsAcceptanceChanged(value ?? false);
              },
              activeColor: AppColors.deepPurple,
            ),
            Expanded(
              child: Text(
                'I accept the Terms & Conditions',
                style: AppTypography.textSm.copyWith(
                  color: AppColors.neutral700,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _SignUpButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SignUpCubit, SignUpState>(
      builder: (context, state) {
        final isValid = Formz.validate([state.email, state.password, state.termsAcceptance]);
        return AuthButton(
          text: 'Create Account',
          isLoading: state.status.isInProgress,
          onPressed: isValid && !state.status.isInProgress
              ? () => context.read<SignUpCubit>().signUpFormSubmitted()
              : null,
        );
      },
    );
  }
}

class _LoginForm extends StatelessWidget {
  const _LoginForm({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _LoginEmailInput(),
          const SizedBox(height: AppTheme.space5),
          _LoginPasswordInput(),
          const SizedBox(height: AppTheme.space3),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () {
                // TODO: Navigate to forgot password
              },
              child: Text(
                'Forgot Password?',
                style: AppTypography.textSm.copyWith(
                  color: AppColors.deepPurple,
                ),
              ),
            ),
          ),
          const SizedBox(height: AppTheme.space6),
          _LoginButton(),
        ],
      ),
    );
  }
}

// Implementations of _LoginEmailInput, _LoginPasswordInput, _LoginButton
class _LoginEmailInput extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LoginCubit, LoginState>(
      buildWhen: (previous, current) => previous.email != current.email,
      builder: (context, state) {
        return AuthTextField(
          label: 'Email / Username',
          hint: 'Enter your email or username',
          onChanged: (email) => context.read<LoginCubit>().emailChanged(email),
          keyboardType: TextInputType.emailAddress,
          errorText: state.email.isNotValid && state.email.value.isNotEmpty ? 'Invalid email' : null,
        );
      },
    );
  }
}

class _LoginPasswordInput extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LoginCubit, LoginState>(
      buildWhen: (previous, current) => previous.password != current.password,
      builder: (context, state) {
        return AuthTextField(
          label: 'Password',
          hint: 'Enter your password',
          onChanged: (password) => context.read<LoginCubit>().passwordChanged(password),
          isPassword: true,
          errorText: state.password.isNotValid && state.password.value.isNotEmpty
              ? 'Password is required'
              : null,
        );
      },
    );
  }
}

class _LoginButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LoginCubit, LoginState>(
      builder: (context, state) {
        final isValid = Formz.validate([state.email, state.password]);
        return AuthButton(
          text: 'Log In',
          isLoading: state.status.isInProgress,
          // Enable button only if form is valid and not already submitting
          onPressed: isValid && !state.status.isInProgress
              ? () => context.read<LoginCubit>().logInWithCredentials()
              : null,
        );
      },
    );
  }
}