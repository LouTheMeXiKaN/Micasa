import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';

class EventTextField extends StatefulWidget {
  final String label;
  final String? hint;
  final ValueChanged<String> onChanged;
  final String? errorText;
  final TextInputType keyboardType;
  final bool autofocus;
  final int? maxLines;
  final int? maxLength;
  final String? initialValue;

  const EventTextField({
    Key? key,
    required this.label,
    this.hint,
    required this.onChanged,
    this.errorText,
    this.keyboardType = TextInputType.text,
    this.autofocus = false,
    this.maxLines = 1,
    this.maxLength,
    this.initialValue,
  }) : super(key: key);

  @override
  State<EventTextField> createState() => _EventTextFieldState();
}

class _EventTextFieldState extends State<EventTextField> {
  late FocusNode _focusNode;
  late TextEditingController _controller;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _focusNode.addListener(_handleFocusChange);
    _controller = TextEditingController(text: widget.initialValue ?? '');
  }

  void _handleFocusChange() {
    if (mounted) {
      setState(() {
        _isFocused = _focusNode.hasFocus;
      });
    }
  }

  @override
  void dispose() {
    _focusNode.removeListener(_handleFocusChange);
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: AppTypography.textSm.copyWith(
            color: AppColors.neutral700,
            fontWeight: AppTypography.medium,
          ),
        ),
        const SizedBox(height: AppTheme.space2),
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: _isFocused
                ? AppColors.white
                : AppColors.white.withOpacity(0.7),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(AppTheme.radiusSm),
              topRight: Radius.circular(AppTheme.radiusSm),
            ),
            boxShadow: _isFocused
                ? [
                    BoxShadow(
                      color: AppColors.deepPurple.withOpacity(0.1),
                      offset: const Offset(0, 4),
                      blurRadius: 12,
                    ),
                  ]
                : null,
          ),
          child: TextFormField(
            controller: _controller,
            focusNode: _focusNode,
            onChanged: widget.onChanged,
            keyboardType: widget.keyboardType,
            autofocus: widget.autofocus,
            maxLines: widget.maxLines,
            maxLength: widget.maxLength,
            style: AppTypography.textBase.copyWith(
              color: AppColors.neutral950,
            ),
            decoration: InputDecoration(
              hintText: widget.hint,
              hintStyle: AppTypography.textBase.copyWith(
                color: AppColors.neutral400,
              ),
              errorText: widget.errorText,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: AppTheme.space4,
                vertical: AppTheme.space3,
              ),
              border: UnderlineInputBorder(
                borderSide: BorderSide(
                  color: AppColors.neutral300,
                  width: 2,
                ),
              ),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(
                  color: AppColors.neutral300,
                  width: 2,
                ),
              ),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(
                  color: AppColors.deepPurple,
                  width: 2,
                ),
              ),
              errorBorder: UnderlineInputBorder(
                borderSide: BorderSide(
                  color: AppColors.coralRed,
                  width: 2,
                ),
              ),
              counterText: widget.maxLength != null ? null : '',
            ),
          ),
        ),
      ],
    );
  }
}