import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/models/user_model.dart';
import 'role_button.dart';

/// Dialog for role selection with role buttons
class RoleSelectionDialog extends StatelessWidget {
  final Function(UserRole) onRoleSelected;
  final bool includeAdminWithSecurity;
  final VoidCallback? onAdminPressed;

  const RoleSelectionDialog({
    Key? key,
    required this.onRoleSelected,
    this.includeAdminWithSecurity = false,
    this.onAdminPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.secondaryBackground,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        constraints: BoxConstraints(maxWidth: 400),
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Select Your Role',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: AppColors.headerText,
                    ),
              ),
              SizedBox(height: 24),
              RoleButton(
                label: 'Student',
                icon: Icons.school,
                onPressed: () {
                  onRoleSelected(UserRole.student);
                },
              ),
              SizedBox(height: 12),
              RoleButton(
                label: 'Instructor',
                icon: Icons.person,
                onPressed: () {
                  onRoleSelected(UserRole.teacher);
                },
              ),
              SizedBox(height: 12),
              RoleButton(
                label: 'Administrator',
                icon: Icons.admin_panel_settings,
                onPressed: () {
                  print('🎭 [RoleSelectionDialog] Admin button pressed, includeAdminWithSecurity: $includeAdminWithSecurity, hasCallback: ${onAdminPressed != null}');
                  if (includeAdminWithSecurity && onAdminPressed != null) {
                    print('🎭 [RoleSelectionDialog] Calling onAdminPressed callback');
                    onAdminPressed!();
                  } else {
                    print('🎭 [RoleSelectionDialog] Selecting admin directly');
                    onRoleSelected(UserRole.admin);
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
