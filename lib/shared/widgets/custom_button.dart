import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

/// Professional custom button with consistent styling
class CustomButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final ButtonType type;
  final bool isLoading;
  final bool isFullWidth;
  final double? width;
  final double height;
  final IconData? icon;
  final bool isIconOnly;
  final String? tooltipText;

  const CustomButton({
    Key? key,
    required this.label,
    this.onPressed,
    this.type = ButtonType.primary,
    this.isLoading = false,
    this.isFullWidth = false,
    this.width,
    this.height = 44,
    this.icon,
    this.isIconOnly = false,
    this.tooltipText,
  }) : super(key: key);

  Color get _backgroundColor {
    switch (type) {
      case ButtonType.primary:
        return AppColors.buttonPrimary;
      case ButtonType.secondary:
        return AppColors.dividerColor;
      case ButtonType.danger:
        return AppColors.error;
      case ButtonType.success:
        return AppColors.success;
    }
  }

  Color get _foregroundColor {
    switch (type) {
      case ButtonType.primary:
        return Colors.white;
      case ButtonType.secondary:
        return AppColors.headerText;
      case ButtonType.danger:
        return Colors.white;
      case ButtonType.success:
        return Colors.white;
    }
  }

  Color get _hoverColor {
    switch (type) {
      case ButtonType.primary:
        return AppColors.buttonPrimary.withOpacity(0.8);
      case ButtonType.secondary:
        return AppColors.borderColor;
      case ButtonType.danger:
        return AppColors.error.withOpacity(0.8);
      case ButtonType.success:
        return AppColors.success.withOpacity(0.8);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isIconOnly && icon != null) {
      return Tooltip(
        message: tooltipText ?? label,
        child: IconButton(
          onPressed: isLoading ? null : onPressed,
          icon: Icon(icon),
          iconSize: 24,
          color: _backgroundColor,
          hoverColor: _hoverColor.withOpacity(0.15),
          splashRadius: 20,
        ),
      );
    }

    Widget buttonChild;
    if (isLoading) {
      buttonChild = SizedBox(
        height: height - 20,
        width: height - 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(_foregroundColor),
        ),
      );
    } else if (icon != null) {
      buttonChild = Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 18),
          SizedBox(width: 8),
          Text(label),
        ],
      );
    } else {
      buttonChild = Text(label);
    }

    final button = ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: _backgroundColor,
        foregroundColor: _foregroundColor,
        disabledBackgroundColor: AppColors.borderColor.withOpacity(0.5),
        disabledForegroundColor: AppColors.mutedText,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        minimumSize: Size(0, height),
      ),
      child: buttonChild,
    );

    if (isFullWidth) {
      return SizedBox(width: double.infinity, child: button);
    } else if (width != null) {
      return SizedBox(width: width, child: button);
    }
    return button;
  }
}

/// Outlined button variant for secondary actions
class CustomOutlinedButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final Color? color;
  final bool isLoading;
  final bool isFullWidth;
  final double? width;
  final double height;
  final IconData? icon;

  const CustomOutlinedButton({
    Key? key,
    required this.label,
    this.onPressed,
    this.color,
    this.isLoading = false,
    this.isFullWidth = false,
    this.width,
    this.height = 44,
    this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final borderColor = color ?? AppColors.buttonPrimary;
    final textColor = color ?? AppColors.buttonPrimary;

    Widget buttonChild;
    if (isLoading) {
      buttonChild = SizedBox(
        height: height - 20,
        width: height - 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(borderColor),
        ),
      );
    } else if (icon != null) {
      buttonChild = Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 18),
          SizedBox(width: 8),
          Text(label),
        ],
      );
    } else {
      buttonChild = Text(label);
    }

    final button = OutlinedButton(
      onPressed: isLoading ? null : onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: textColor,
        side: BorderSide(
          color: borderColor,
          width: 1.5,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        minimumSize: Size(0, height),
      ),
      child: buttonChild,
    );

    if (isFullWidth) {
      return SizedBox(width: double.infinity, child: button);
    } else if (width != null) {
      return SizedBox(width: width, child: button);
    }
    return button;
  }
}

enum ButtonType {
  primary,
  secondary,
  danger,
  success,
}
