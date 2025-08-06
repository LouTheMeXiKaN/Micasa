import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../data/models/application_models.dart';

class ApplicantCard extends StatelessWidget {
  final Application application;
  final bool isExpanded;
  final bool isProcessing;
  final VoidCallback? onToggleExpansion;
  final VoidCallback? onAccept;
  final VoidCallback? onDecline;

  const ApplicantCard({
    Key? key,
    required this.application,
    this.isExpanded = false,
    this.isProcessing = false,
    this.onToggleExpansion,
    this.onAccept,
    this.onDecline,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppTheme.space3),
      child: Material(
        color: Colors.transparent,
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(AppTheme.radiusMd),
            boxShadow: AppTheme.cardShadow,
          ),
          child: Column(
            children: [
              // Main card content
              InkWell(
                onTap: onToggleExpansion,
                borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                child: Padding(
                  padding: const EdgeInsets.all(AppTheme.space4),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          // Profile Picture
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: AppColors.neutral200,
                              borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                            ),
                            child: application.profilePictureUrl != null
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                                    child: Image.network(
                                      application.profilePictureUrl!,
                                      width: 40,
                                      height: 40,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) => 
                                          _buildInitialsAvatar(),
                                    ),
                                  )
                                : _buildInitialsAvatar(),
                          ),
                          const SizedBox(width: AppTheme.space3),
                          // User Info
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  application.username,
                                  style: AppTypography.textBase.copyWith(
                                    fontWeight: AppTypography.semibold,
                                    color: AppColors.neutral950,
                                  ),
                                ),
                                Text(
                                  _formatApplicationDate(),
                                  style: AppTypography.textSm.copyWith(
                                    color: AppColors.neutral500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Expand/Collapse indicator
                          Icon(
                            isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                            color: AppColors.neutral500,
                          ),
                        ],
                      ),
                      const SizedBox(height: AppTheme.space3),
                      // Message Preview
                      Text(
                        isExpanded ? application.applicationMessage : application.messagePreview,
                        style: AppTypography.textSm.copyWith(
                          color: AppColors.neutral700,
                          height: 1.4,
                        ),
                        maxLines: isExpanded ? null : 2,
                        overflow: isExpanded ? null : TextOverflow.ellipsis,
                      ),
                      // Expanded content
                      if (isExpanded) ...[
                        const SizedBox(height: AppTheme.space4),
                        _buildExpandedContent(),
                      ],
                    ],
                  ),
                ),
              ),
              // Action buttons (always visible)
              Container(
                padding: const EdgeInsets.all(AppTheme.space4),
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(
                      color: AppColors.neutral100,
                      width: 1,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildActionButton(
                        text: 'Decline',
                        onPressed: isProcessing ? null : onDecline,
                        isPrimary: false,
                      ),
                    ),
                    const SizedBox(width: AppTheme.space3),
                    Expanded(
                      child: _buildActionButton(
                        text: 'Accept',
                        onPressed: isProcessing ? null : onAccept,
                        isPrimary: true,
                        isLoading: isProcessing,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInitialsAvatar() {
    final initials = application.username.isNotEmpty 
        ? application.username.substring(0, 1).toUpperCase()
        : '?';
    
    return Center(
      child: Text(
        initials,
        style: AppTypography.textBase.copyWith(
          color: AppColors.neutral600,
          fontWeight: AppTypography.semibold,
        ),
      ),
    );
  }

  Widget _buildExpandedContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (application.bio?.isNotEmpty == true) ...[
          Text(
            'About',
            style: AppTypography.textSm.copyWith(
              fontWeight: AppTypography.semibold,
              color: AppColors.neutral950,
            ),
          ),
          const SizedBox(height: AppTheme.space2),
          Text(
            application.bio!,
            style: AppTypography.textSm.copyWith(
              color: AppColors.neutral700,
              height: 1.4,
            ),
          ),
          const SizedBox(height: AppTheme.space3),
        ],
        if (application.hasSocialLinks) ...[
          Text(
            'Links',
            style: AppTypography.textSm.copyWith(
              fontWeight: AppTypography.semibold,
              color: AppColors.neutral950,
            ),
          ),
          const SizedBox(height: AppTheme.space2),
          Row(
            children: [
              if (application.instagramHandle?.isNotEmpty == true)
                _buildSocialLink(
                  icon: Icons.camera_alt,
                  text: '@${application.instagramHandle}',
                  url: 'https://instagram.com/${application.instagramHandle}',
                ),
              if (application.instagramHandle?.isNotEmpty == true &&
                  application.personalWebsite?.isNotEmpty == true)
                const SizedBox(width: AppTheme.space4),
              if (application.personalWebsite?.isNotEmpty == true)
                _buildSocialLink(
                  icon: Icons.language,
                  text: 'Website',
                  url: application.personalWebsite!,
                ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildSocialLink({
    required IconData icon,
    required String text,
    required String url,
  }) {
    return InkWell(
      onTap: () => _launchUrl(url),
      borderRadius: BorderRadius.circular(AppTheme.radiusSm),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppTheme.space3,
          vertical: AppTheme.space2,
        ),
        decoration: BoxDecoration(
          color: AppColors.neutral50,
          borderRadius: BorderRadius.circular(AppTheme.radiusSm),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: AppColors.deepPurple,
            ),
            const SizedBox(width: AppTheme.space2),
            Text(
              text,
              style: AppTypography.textSm.copyWith(
                color: AppColors.deepPurple,
                fontWeight: AppTypography.medium,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required String text,
    required VoidCallback? onPressed,
    required bool isPrimary,
    bool isLoading = false,
  }) {
    return Container(
      height: 44,
      child: Material(
        color: isPrimary ? AppColors.deepPurple : Colors.transparent,
        borderRadius: BorderRadius.circular(AppTheme.radiusSm),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(AppTheme.radiusSm),
          child: Container(
            decoration: BoxDecoration(
              border: isPrimary ? null : Border.all(
                color: AppColors.neutral300,
                width: 1,
              ),
              borderRadius: BorderRadius.circular(AppTheme.radiusSm),
            ),
            child: Center(
              child: isLoading
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          isPrimary ? AppColors.white : AppColors.deepPurple,
                        ),
                      ),
                    )
                  : Text(
                      text,
                      style: AppTypography.textSm.copyWith(
                        color: isPrimary ? AppColors.white : AppColors.neutral700,
                        fontWeight: AppTypography.semibold,
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }

  String _formatApplicationDate() {
    final now = DateTime.now();
    final difference = now.difference(application.appliedAt);
    
    if (difference.inDays > 0) {
      return 'Applied ${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return 'Applied ${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return 'Applied ${difference.inMinutes}m ago';
    } else {
      return 'Applied just now';
    }
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }
}