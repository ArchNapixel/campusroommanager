import 'package:flutter/material.dart';
import '../../core/models/user_model.dart';
import '../../core/theme/app_theme.dart';

/// Role selector widget for login screen
class RoleSelector extends StatelessWidget {
  final List<UserRole> availableRoles;
  final UserRole? selectedRole;
  final Function(UserRole) onRoleSelected;

  const RoleSelector({
    Key? key,
    required this.availableRoles,
    this.selectedRole,
    required this.onRoleSelected,
  }) : super(key: key);

  String _getRoleLabel(UserRole role) {
    switch (role) {
      case UserRole.student:
        return 'Student';
      case UserRole.teacher:
        return 'Instructor';
      case UserRole.admin:
        return 'Administrator';
    }
  }

  IconData _getRoleIcon(UserRole role) {
    switch (role) {
      case UserRole.student:
        return Icons.school;
      case UserRole.teacher:
        return Icons.person_outline;
      case UserRole.admin:
        return Icons.admin_panel_settings;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 16,
      runSpacing: 16,
      children: availableRoles
          .map((role) => GestureDetector(
                onTap: () => onRoleSelected(role),
                child: AnimatedContainer(
                  duration: Duration(milliseconds: 200),
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: selectedRole == role
                        ? AppColors.buttonPrimary.withOpacity(0.2)
                        : AppColors.secondaryBackground,
                    border: Border.all(
                      color: selectedRole == role
                          ? AppColors.buttonPrimary
                          : AppColors.borderColor,
                      width: selectedRole == role ? 2 : 1,
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        _getRoleIcon(role),
                        size: 32,
                        color: selectedRole == role
                            ? AppColors.available
                            : AppColors.bodyText,
                      ),
                      SizedBox(height: 8),
                      Text(
                        _getRoleLabel(role),
                        style: TextStyle(
                          color: selectedRole == role
                              ? AppColors.headerText
                              : AppColors.bodyText,
                          fontWeight: selectedRole == role
                              ? FontWeight.w600
                              : FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
              ))
          .toList(),
    );
  }
}
