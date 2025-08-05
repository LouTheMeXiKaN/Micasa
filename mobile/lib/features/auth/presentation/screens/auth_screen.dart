import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:formz/formz.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
// We use the LoginCubit here to handle the loading state and errors for OAuth flows.
import '../cubits/login/login_cubit.dart';
import '../cubits/login/login_state.dart';
import '../widgets/social_auth_button.dart';
import '../../data/repositories/auth_repository.dart';

class AuthScreen extends StatelessWidget {
  const AuthScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Provide LoginCubit to handle OAuth attempts from this screen
    return BlocProvider(
      create: (context) => LoginCubit(context.read<AuthRepository>()),
      child: const AuthView(),
    );
  }
}

class AuthView extends StatelessWidget {
  const AuthView({Key? key}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.neutral50,
       // Design System Adherence: Placeholder for texture overlay ("Digital with Soul")
      body: Container(
        /* decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/textures/noise-texture.png"),
            repeat: ImageRepeat.repeat,
            opacity: 0.05,
          ),
        ), */
        child: BlocListener<LoginCubit, LoginState>(
          listener: (context, state) {
            // Navigation is handled centrally by GoRouter based on AuthBloc.
            // We only listen here for specific errors during the social login attempt.
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
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppTheme.space5),
              child: Column(
                children: [
                  const Spacer(flex: 2),
                  // Logo placeholder
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: AppColors.deepPurple,
                      borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                    ),
                    child: Center(
                      child: Text(
                        'M',
                        style: AppTypography.display3xl.copyWith(
                          color: AppColors.white,
                          fontWeight: AppTypography.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppTheme.space6),
                  // Welcome headline
                  Text(
                    'Welcome to Micasa',
                    style: AppTypography.display2xl.copyWith(
                      color: AppColors.deepPurple,
                      fontWeight: AppTypography.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppTheme.space3),
                  Text(
                    'Create, collaborate, and celebrate events',
                    style: AppTypography.textBase.copyWith(
                      color: AppColors.neutral600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppTheme.space7),
                  // Auth buttons
                  BlocBuilder<LoginCubit, LoginState>(
                    builder: (context, state) {
                      // Use the Cubit's status to show loading indicator for OAuth
                      final isLoading = state.status.isInProgress;
                      
                      return Column(
                        children: [
                          SocialAuthButton(
                            text: 'Continue with Google',
                            iconAsset: 'assets/icons/google.png',
                            isLoading: isLoading,
                            onPressed: () {
                              context.read<LoginCubit>().logInWithGoogle();
                            },
                          ),
                          const SizedBox(height: AppTheme.space5),
                          // Divider with OR
                          Row(
                            children: [
                              Expanded(
                                child: Container(
                                  height: 1,
                                  color: AppColors.neutral200,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: AppTheme.space4,
                                ),
                                child: Text(
                                  'OR',
                                  style: AppTypography.textSm.copyWith(
                                    color: AppColors.neutral500,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Container(
                                  height: 1,
                                  color: AppColors.neutral200,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppTheme.space5),
                          // Email option
                          TextButton(
                            onPressed: isLoading
                                ? null
                                : () {
                                    context.go('/auth/email');
                                  },
                            child: Text(
                              'Continue with Email',
                              style: AppTypography.textBase.copyWith(
                                color: AppColors.deepPurple,
                                fontWeight: AppTypography.medium,
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                  const Spacer(flex: 3),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}