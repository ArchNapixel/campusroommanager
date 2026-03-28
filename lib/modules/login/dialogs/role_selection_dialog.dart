import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/models/user_model.dart';
import 'role_button.dart';

/// Dialog for role selection with role buttons
class RoleSelectionDialog extends StatelessWidget {
  final Function(UserRole) onRoleSelected;

  const RoleSelectionDialog({
    Key? key,
    required this.onRoleSelected,
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
            ],
          ),
        ),
      ),
    );
  }
}
