import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

/// Professional custom text field with consistent styling across app
class CustomTextField extends StatefulWidget {
  final String label;
  final String? hint;
  final TextEditingController? controller;
  final FormFieldValidator<String>? validator;
  final TextInputType keyboardType;
  final int maxLines;
  final int? maxLength;
  final bool obscureText;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final VoidCallback? onSuffixIconTap;
  final Function(String)? onChanged;
  final bool isRequired;
  final String? errorText;
  final String? helperText;

  const CustomTextField({
    Key? key,
    required this.label,
    this.hint,
    this.controller,
    this.validator,
    this.keyboardType = TextInputType.text,
    this.maxLines = 1,
    this.maxLength,
    this.obscureText = false,
    this.prefixIcon,
    this.suffixIcon,
    this.onSuffixIconTap,
    this.onChanged,
    this.isRequired = false,
    this.errorText,
    this.helperText,
  }) : super(key: key);

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  late FocusNode _focusNode;
  bool _isFocused = false;
  bool _showPassword = false;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _focusNode.addListener(_handleFocusChange);
  }

  @override
  void dispose() {
    _focusNode.removeListener(_handleFocusChange);
    _focusNode.dispose();
    super.dispose();
  }

  void _handleFocusChange() {
    setState(() {
      _isFocused = _focusNode.hasFocus;
    });
  }

  @override
  Widget build(BuildContext context) {
    final hasError = widget.errorText != null && widget.errorText!.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Label with required indicator
        Padding(
          padding: EdgeInsets.only(bottom: 8),
          child: Row(
            children: [
              Text(
                widget.label,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.headerText,
                ),
              ),
              if (widget.isRequired) ...[
                SizedBox(width: 4),
                Text(
                  '*',
                  style: TextStyle(
                    color: AppColors.error,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ],
          ),
        ),

        // Text field
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              if (_isFocused)
                BoxShadow(
                  color: AppColors.buttonPrimary.withOpacity(0.15),
                  blurRadius: 8,
                  spreadRadius: 0,
                  offset: Offset(0, 2),
                ),
            ],
          ),
          child: TextFormField(
            controller: widget.controller,
            focusNode: _focusNode,
            validator: widget.validator,
            keyboardType: widget.keyboardType,
            maxLines: widget.obscureText ? 1 : widget.maxLines,
            maxLength: widget.maxLength,
            obscureText: widget.obscureText && !_showPassword,
            onChanged: widget.onChanged,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.bodyText,
            ),
            cursorColor: AppColors.buttonPrimary,
            decoration: InputDecoration(
              hintText: widget.hint,
              hintStyle: TextStyle(
                color: AppColors.mutedText.withOpacity(0.6),
              ),
              filled: true,
              fillColor: AppColors.dividerColor.withOpacity(0.3),
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              prefixIcon: widget.prefixIcon != null
                  ? Icon(
                widget.prefixIcon,
                color: _isFocused ? AppColors.buttonPrimary : AppColors.mutedText,
                size: 20,
              )
                  : null,
              suffixIcon: widget.suffixIcon != null
                  ? GestureDetector(
                onTap: widget.onSuffixIconTap,
                child: Icon(
                  widget.suffixIcon,
                  color: _isFocused ? AppColors.buttonPrimary : AppColors.mutedText,
                  size: 20,
                ),
              )
                  : (widget.obscureText
                  ? GestureDetector(
                onTap: () {
                  setState(() {
                    _showPassword = !_showPassword;
                  });
                },
                child: Icon(
                  _showPassword ? Icons.visibility : Icons.visibility_off,
                  color: _isFocused ? AppColors.buttonPrimary : AppColors.mutedText,
                  size: 20,
                ),
              )
                  : null),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color: AppColors.borderColor,
                  width: 1,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color: hasError ? AppColors.error : AppColors.borderColor,
                  width: 1.5,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color: hasError ? AppColors.error : AppColors.buttonPrimary,
                  width: 2,
                ),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color: AppColors.error,
                  width: 1.5,
                ),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color: AppColors.error,
                  width: 2,
                ),
              ),
              counterStyle: TextStyle(
                color: AppColors.mutedText,
                fontSize: 12,
              ),
            ),
          ),
        ),

        // Error message
        if (hasError) ...[
          SizedBox(height: 6),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 4),
            child: Row(
              children: [
                Icon(
                  Icons.error_outline,
                  size: 14,
                  color: AppColors.error,
                ),
                SizedBox(width: 6),
                Expanded(
                  child: Text(
                    widget.errorText!,
                    style: TextStyle(
                      color: AppColors.error,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],

        // Helper text
        if (widget.helperText != null && !hasError) ...[
          SizedBox(height: 6),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 4),
            child: Text(
              widget.helperText!,
              style: TextStyle(
                color: AppColors.mutedText,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ],
    );
  }
}
