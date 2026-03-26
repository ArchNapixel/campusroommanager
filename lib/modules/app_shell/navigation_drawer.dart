import 'package:flutter/material.dart';
import '../../core/models/user_model.dart';
import '../../core/theme/app_theme.dart';
import 'app_shell.dart';

/// Navigation drawer widget for app shell
class NavigationDrawerWidget extends StatelessWidget {
  final List<NavigationItem> items;
  final Function(int) onItemSelected;
  final UserRole userRole;
  final VoidCallback onLogout;
  final bool expanded;

  const NavigationDrawerWidget({
    Key? key,
    required this.items,
    required this.onItemSelected,
    required this.userRole,
    required this.onLogout,
    this.expanded = false,
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

  @override
  Widget build(BuildContext context) {
    if (expanded) {
      // Expanded sidebar for desktop
      return Container(
        width: 220,
        color: AppColors.secondaryBackground,
        child: Column(
          children: [
            // Header
            Container(
              padding: EdgeInsets.all(16),
              color: AppColors.primaryBackground,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.meeting_room,
                    color: AppColors.available,
                    size: 32,
                  ),
                  SizedBox(height: 12),
                  Text(
                    'Campus Room',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  Text(
                    'Manager',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.mutedText,
                    ),
                  ),
                  SizedBox(height: 8),
                  Chip(
                    label: Text(_getRoleLabel(userRole)),
                    backgroundColor: AppColors.buttonPrimary.withOpacity(0.2),
                    labelStyle: TextStyle(
                      color: AppColors.buttonPrimary,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16),

            // Navigation items
            Expanded(
              child: ListView(
                children: items
                    .asMap()
                    .entries
                    .map((entry) => _buildNavItem(context, entry.key,
                        entry.value))
                    .toList(),
              ),
            ),

            // Logout button
            Padding(
              padding: EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                child: TextButton.icon(
                  onPressed: onLogout,
                  icon: Icon(Icons.logout),
                  label: Text('Logout'),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.error,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    } else {
      // Drawer for mobile
      return Drawer(
        backgroundColor: AppColors.secondaryBackground,
        child: Column(
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: AppColors.primaryBackground,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Icon(
                    Icons.meeting_room,
                    color: AppColors.available,
                    size: 40,
                  ),
                  SizedBox(height: 12),
                  Text(
                    'Campus Room Manager',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  Text(
                    _getRoleLabel(userRole),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                children: items
                    .asMap()
                    .entries
                    .map((entry) => _buildNavItem(context, entry.key,
                        entry.value))
                    .toList(),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                child: TextButton.icon(
                  onPressed: onLogout,
                  icon: Icon(Icons.logout),
                  label: Text('Logout'),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.error,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }
  }

  Widget _buildNavItem(
      BuildContext context, int index, NavigationItem item) {
    final isActive = index == -1;

    return ListTile(
      leading: Icon(item.icon),
      title: Text(item.label),
      selected: isActive,
      selectedTileColor: AppColors.buttonPrimary.withOpacity(0.2),
      selectedColor: AppColors.buttonPrimary,
      onTap: () => onItemSelected(index),
    );
  }
}
