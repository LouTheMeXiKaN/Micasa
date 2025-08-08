import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../../../auth/presentation/bloc/auth_state.dart';

class ProfileHubScreen extends StatelessWidget {
  const ProfileHubScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.neutral50,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        title: Text(
          'Profile',
          style: AppTypography.textXl.copyWith(
            color: AppColors.neutral950,
            fontWeight: AppTypography.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            final user = state.user;
            
            return SingleChildScrollView(
              child: Column(
                children: [
                  // User info header
                  Container(
                    padding: const EdgeInsets.all(AppTheme.space5),
                    color: AppColors.white,
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 40,
                          backgroundColor: AppColors.lightPurple,
                          child: Text(
                            user?.username?.substring(0, 1).toUpperCase() ?? 'U',
                            style: AppTypography.text2xl.copyWith(
                              color: AppColors.deepPurple,
                              fontWeight: AppTypography.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: AppTheme.space4),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                user?.username ?? 'User',
                                style: AppTypography.textLg.copyWith(
                                  color: AppColors.neutral950,
                                  fontWeight: AppTypography.semibold,
                                ),
                              ),
                              const SizedBox(height: AppTheme.space1),
                              Text(
                                user?.email ?? '',
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
                  
                  const SizedBox(height: AppTheme.space2),
                  
                  // Menu items
                  _buildMenuItem(
                    context,
                    icon: Icons.monetization_on_outlined,
                    title: 'My Earnings',
                    onTap: () {
                      // TODO: Navigate to My Earnings screen
                    },
                  ),
                  _buildMenuItem(
                    context,
                    icon: Icons.mail_outline,
                    title: 'My Invitations',
                    onTap: () {
                      // TODO: Navigate to My Invitations screen
                    },
                  ),
                  _buildMenuItem(
                    context,
                    icon: Icons.edit_outlined,
                    title: 'Edit Profile',
                    onTap: () {
                      // TODO: Navigate to Edit Profile screen
                    },
                  ),
                  _buildMenuItem(
                    context,
                    icon: Icons.visibility_outlined,
                    title: 'View My Public Profile',
                    onTap: () {
                      // TODO: Navigate to public profile view
                    },
                  ),
                  _buildMenuItem(
                    context,
                    icon: Icons.people_outline,
                    title: 'My Community',
                    onTap: () {
                      context.go('/my-community');
                    },
                  ),
                  
                  const SizedBox(height: AppTheme.space5),
                  
                  // Log out button
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppTheme.space5),
                    child: SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: () {
                          context.read<AuthBloc>().add(AuthLogoutRequested());
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.coralRed,
                          padding: const EdgeInsets.symmetric(
                            vertical: AppTheme.space3,
                          ),
                          side: const BorderSide(
                            color: AppColors.coralRed,
                            width: 2,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                          ),
                        ),
                        child: Text(
                          'Log Out',
                          style: AppTypography.textBase.copyWith(
                            fontWeight: AppTypography.semibold,
                          ),
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: AppTheme.space5),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
  
  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Container(
      color: AppColors.white,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppTheme.space5,
              vertical: AppTheme.space4,
            ),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: AppColors.neutral700,
                  size: 24,
                ),
                const SizedBox(width: AppTheme.space4),
                Expanded(
                  child: Text(
                    title,
                    style: AppTypography.textBase.copyWith(
                      color: AppColors.neutral950,
                    ),
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  color: AppColors.neutral400,
                  size: 24,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}