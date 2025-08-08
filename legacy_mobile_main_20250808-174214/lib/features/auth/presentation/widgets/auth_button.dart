import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';

class AuthButton extends StatelessWidget {
  final String text;
  // Changed to optional VoidCallback? to handle disabled state properly via Cubit
  final VoidCallback? onPressed; 
  final bool isLoading;
  final bool isPrimary;

  const AuthButton({
    Key? key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.isPrimary = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Design System Adherence: "Intentionally imperfect border" for secondary buttons
    final borderRadius = isPrimary
        ? BorderRadius.circular(AppTheme.radiusSm)
        : BorderRadius.only(
            topLeft: const Radius.circular(AppTheme.radiusSm),
            topRight: const Radius.circular(AppTheme.radiusSm),
            // Imperfect corners
            bottomLeft: Radius.circular(AppTheme.radiusSm * 0.9),
            bottomRight: Radius.circular(AppTheme.radiusSm * 1.2),
          );
          
    final bool isDisabled = isLoading || onPressed == null;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
      height: 52,
      decoration: BoxDecoration(
        // Handle disabled state visuals
        gradient: isPrimary && !isDisabled
            ? const LinearGradient(
                colors: [AppColors.deepPurple, Color(0xFF4A1248)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : null,
        color: isDisabled 
               ? AppColors.lightPurple // Disabled state color from Design System
               : (isPrimary ? null : AppColors.white),
        borderRadius: borderRadius,
        boxShadow: isPrimary && !isDisabled ? AppTheme.buttonShadow : null,
        border: isPrimary || isDisabled
            ? null
            : Border.all(
                color: AppColors.deepPurple,
                width: 2,
              ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          // Disable tap if loading or if onPressed is null
          onTap: isDisabled ? null : onPressed,
          borderRadius: borderRadius,
          child: Center(
            child: isLoading
                ? SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        isPrimary ? AppColors.white : AppColors.deepPurple,
                      ),
                    ),
                  )
                : Text(
                    text,
                    style: AppTypography.textBase.copyWith(
                      color: isPrimary ? AppColors.white : (isDisabled ? AppColors.neutral500 : AppColors.deepPurple),
                      fontWeight: AppTypography.semibold,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}