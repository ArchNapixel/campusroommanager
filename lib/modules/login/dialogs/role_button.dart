import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

/// Reusable role button widget
class RoleButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onPressed;

  const RoleButton({
    Key? key,
    required this.label,
    required this.icon,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon),
        label: Text(label),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.buttonPrimary,
          foregroundColor: AppColors.headerText,
          padding: EdgeInsets.symmetric(vertical: 12),
        ),
      ),
    );
  }
}
