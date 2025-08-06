import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';

class DateTimePickerField extends StatelessWidget {
  final String label;
  final DateTime? selectedDateTime;
  final ValueChanged<DateTime?> onChanged;
  final String? errorText;
  final DateTime? firstDate;
  final DateTime? lastDate;

  const DateTimePickerField({
    Key? key,
    required this.label,
    this.selectedDateTime,
    required this.onChanged,
    this.errorText,
    this.firstDate,
    this.lastDate,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTypography.textSm.copyWith(
            color: AppColors.neutral700,
            fontWeight: AppTypography.medium,
          ),
        ),
        const SizedBox(height: AppTheme.space2),
        Container(
          decoration: BoxDecoration(
            color: AppColors.white.withOpacity(0.7),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(AppTheme.radiusSm),
              topRight: Radius.circular(AppTheme.radiusSm),
            ),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => _selectDateTime(context),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(AppTheme.radiusSm),
                topRight: Radius.circular(AppTheme.radiusSm),
              ),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppTheme.space4,
                  vertical: AppTheme.space3,
                ),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: errorText != null 
                          ? AppColors.coralRed 
                          : AppColors.neutral300,
                      width: 2,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        selectedDateTime != null
                            ? DateFormat('MMM d, y • h:mm a').format(selectedDateTime!)
                            : 'Select date and time',
                        style: AppTypography.textBase.copyWith(
                          color: selectedDateTime != null
                              ? AppColors.neutral950
                              : AppColors.neutral400,
                        ),
                      ),
                    ),
                    Icon(
                      Icons.calendar_today_outlined,
                      color: AppColors.neutral500,
                      size: 20,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        if (errorText != null) ...[
          const SizedBox(height: AppTheme.space2),
          Text(
            errorText!,
            style: AppTypography.textSm.copyWith(
              color: AppColors.coralRed,
            ),
          ),
        ],
      ],
    );
  }

  Future<void> _selectDateTime(BuildContext context) async {
    final now = DateTime.now();
    final initialDate = selectedDateTime ?? now.add(const Duration(hours: 1));
    
    // First pick the date
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate ?? now,
      lastDate: lastDate ?? DateTime(now.year + 2),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: AppColors.deepPurple,
              onPrimary: AppColors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null && context.mounted) {
      // Then pick the time
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(initialDate),
        builder: (context, child) {
          return Theme(
            data: Theme.of(context).copyWith(
              colorScheme: Theme.of(context).colorScheme.copyWith(
                primary: AppColors.deepPurple,
                onPrimary: AppColors.white,
              ),
            ),
            child: child!,
          );
        },
      );

      if (pickedTime != null) {
        final DateTime finalDateTime = DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
          pickedTime.hour,
          pickedTime.minute,
        );
        onChanged(finalDateTime);
      }
    }
  }
}