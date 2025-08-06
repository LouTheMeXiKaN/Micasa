import 'dart:io';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';

class ImagePickerWidget extends StatelessWidget {
  final File? selectedImage;
  final VoidCallback onTap;
  final VoidCallback? onRemove;

  const ImagePickerWidget({
    Key? key,
    this.selectedImage,
    required this.onTap,
    this.onRemove,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      width: double.infinity,
      decoration: BoxDecoration(
        color: selectedImage != null ? null : AppColors.neutral100,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        boxShadow: AppTheme.cardShadow,
        image: selectedImage != null
            ? DecorationImage(
                image: FileImage(selectedImage!),
                fit: BoxFit.cover,
              )
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          child: selectedImage != null
              ? Stack(
                  children: [
                    // Overlay for better contrast
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                        color: Colors.black.withOpacity(0.3),
                      ),
                    ),
                    // Remove button
                    if (onRemove != null)
                      Positioned(
                        top: AppTheme.space3,
                        right: AppTheme.space3,
                        child: GestureDetector(
                          onTap: onRemove,
                          child: Container(
                            padding: const EdgeInsets.all(AppTheme.space2),
                            decoration: BoxDecoration(
                              color: AppColors.coralRed,
                              borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                            ),
                            child: Icon(
                              Icons.close,
                              size: 20,
                              color: AppColors.white,
                            ),
                          ),
                        ),
                      ),
                    // Change image text
                    Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppTheme.space4,
                          vertical: AppTheme.space2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.white.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                        ),
                        child: Text(
                          'Tap to change image',
                          style: AppTypography.textSm.copyWith(
                            color: AppColors.neutral950,
                            fontWeight: AppTypography.medium,
                          ),
                        ),
                      ),
                    ),
                  ],
                )
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.add_photo_alternate_outlined,
                      size: 48,
                      color: AppColors.neutral500,
                    ),
                    const SizedBox(height: AppTheme.space3),
                    Text(
                      'Add Cover Image',
                      style: AppTypography.textLg.copyWith(
                        color: AppColors.neutral700,
                        fontWeight: AppTypography.medium,
                      ),
                    ),
                    const SizedBox(height: AppTheme.space2),
                    Text(
                      'Tap to select from gallery',
                      style: AppTypography.textSm.copyWith(
                        color: AppColors.neutral500,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}