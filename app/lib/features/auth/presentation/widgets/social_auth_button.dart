import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';

class SocialAuthButton extends StatelessWidget {
  final String text;
  final String iconAsset;
  final VoidCallback onPressed;
  final bool isLoading;

  const SocialAuthButton({
    Key? key,
    required this.text,
    required this.iconAsset,
    required this.onPressed,
    this.isLoading = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppTheme.radiusSm),
        boxShadow: AppTheme.cardShadow,
        border: Border.all(
          color: AppColors.neutral200,
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isLoading ? null : onPressed,
          borderRadius: BorderRadius.circular(AppTheme.radiusSm),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppTheme.space4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (isLoading)
                  const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppColors.deepPurple,
                      ),
                    ),
                  )
                else ...[
                  Image.asset(
                    iconAsset,
                    width: 24,
                    height: 24,
                  ),
                  const SizedBox(width: AppTheme.space3),
                  Text(
                    text,
                    style: AppTypography.textBase.copyWith(
                      color: AppColors.neutral950,
                      fontWeight: AppTypography.medium,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}