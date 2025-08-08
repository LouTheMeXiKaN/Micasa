import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';

class AuthTextField extends StatefulWidget {
  final String label;
  final String? hint;
  // Removed controller and validator, added onChanged and errorText
  final ValueChanged<String> onChanged;
  final String? errorText;
  final bool isPassword;
  final TextInputType keyboardType;
  final bool autofocus;

  const AuthTextField({
    Key? key,
    required this.label,
    this.hint,
    required this.onChanged,
    this.errorText,
    this.isPassword = false,
    this.keyboardType = TextInputType.text,
    this.autofocus = false,
  }) : super(key: key);

  @override
  State<AuthTextField> createState() => _AuthTextFieldState();
}

class _AuthTextFieldState extends State<AuthTextField> {
  bool _obscureText = true;
  // Use FocusNode for better focus management
  late FocusNode _focusNode;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _focusNode.addListener(_handleFocusChange);
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
            // Design System Adherence: Input field background color
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
            focusNode: _focusNode,
            onChanged: widget.onChanged,
            obscureText: widget.isPassword ? _obscureText : false,
            keyboardType: widget.keyboardType,
            autofocus: widget.autofocus,
            style: AppTypography.textBase.copyWith(
              color: AppColors.neutral950,
            ),
            decoration: InputDecoration(
              hintText: widget.hint,
              hintStyle: AppTypography.textBase.copyWith(
                color: AppColors.neutral400,
              ),
              // Added errorText display
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
              suffixIcon: widget.isPassword
                  ? IconButton(
                      icon: Icon(
                        _obscureText ? Icons.visibility : Icons.visibility_off,
                        color: AppColors.neutral500,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscureText = !_obscureText;
                        });
                      },
                    )
                  : null,
            ),
          ),
        ),
      ],
    );
  }
}