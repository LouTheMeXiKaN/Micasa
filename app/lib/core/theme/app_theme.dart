import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_typography.dart';

class AppTheme {
  static const double radiusSm = 6.0;
  static const double radiusMd = 12.0;
  static const double radiusLg = 16.0;
  static const double radiusXl = 24.0;
  static const double radiusFull = 9999.0;
  
  // Spacing
  static const double space1 = 4.0;
  static const double space2 = 8.0;
  static const double space3 = 12.0;
  static const double space4 = 16.0;
  static const double space5 = 24.0;
  static const double space6 = 40.0;
  static const double space7 = 64.0;
  static const double space8 = 104.0;
  
  // Shadows
  static List<BoxShadow> get cardShadow => [
    BoxShadow(
      color: Colors.black.withOpacity(0.04),
      offset: const Offset(0, 1),
      blurRadius: 3,
    ),
    BoxShadow(
      color: Colors.black.withOpacity(0.08),
      offset: const Offset(0, 4),
      blurRadius: 16,
    ),
  ];
  
  static List<BoxShadow> get buttonShadow => [
    BoxShadow(
      color: AppColors.deepPurple.withOpacity(0.25),
      offset: const Offset(0, 4),
      blurRadius: 12,
    ),
  ];
  
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.deepPurple,
        primary: AppColors.deepPurple,
        secondary: AppColors.vibrantOrange,
        surface: AppColors.white,
        background: AppColors.neutral50,
        error: AppColors.coralRed,
      ),
      scaffoldBackgroundColor: AppColors.neutral50,
      textTheme: TextTheme(
        displayLarge: AppTypography.display3xl.copyWith(color: AppColors.neutral950),
        displayMedium: AppTypography.display2xl.copyWith(color: AppColors.neutral950),
        displaySmall: AppTypography.displayXl.copyWith(color: AppColors.neutral950),
        headlineLarge: AppTypography.text3xl.copyWith(color: AppColors.neutral950),
        headlineMedium: AppTypography.text2xl.copyWith(color: AppColors.neutral950),
        headlineSmall: AppTypography.textXl.copyWith(color: AppColors.neutral950),
        titleLarge: AppTypography.textLg.copyWith(color: AppColors.neutral950, fontWeight: AppTypography.semibold),
        titleMedium: AppTypography.textBase.copyWith(color: AppColors.neutral950, fontWeight: AppTypography.semibold),
        titleSmall: AppTypography.textSm.copyWith(color: AppColors.neutral950, fontWeight: AppTypography.semibold),
        bodyLarge: AppTypography.textBase.copyWith(color: AppColors.neutral950),
        bodyMedium: AppTypography.textSm.copyWith(color: AppColors.neutral950),
        bodySmall: AppTypography.textXs.copyWith(color: AppColors.neutral950),
        labelLarge: AppTypography.textBase.copyWith(color: AppColors.neutral950, fontWeight: AppTypography.medium),
        labelMedium: AppTypography.textSm.copyWith(color: AppColors.neutral950, fontWeight: AppTypography.medium),
        labelSmall: AppTypography.textXs.copyWith(color: AppColors.neutral950, fontWeight: AppTypography.medium),
      ),
    );
  }
}