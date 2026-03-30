import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/builders/profile_picture_uploader.dart';
import '../../core/theme/app_theme.dart';
import '../../modules/login/login_provider.dart';
import '../../screens/user_profile_screen.dart';

/// Settings screen with profile picture upload and user settings
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late String _currentProfilePictureUrl;

  @override
  void initState() {
    super.initState();
    final loginProvider = context.read<LoginProvider>();
    _currentProfilePictureUrl = loginProvider.currentUser?.profilePictureUrl ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Settings'),
      ),
      body: Consumer<LoginProvider>(
        builder: (context, loginProvider, child) {
          final user = loginProvider.currentUser;

          if (user == null) {
            return const Center(
              child: Text('User not found'),
            );
          }

          return SingleChildScrollView(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.deepNavy,
                    AppColors.primaryBackground,
                  ],
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Profile Section Header
                    const Text(
                      'Profile Picture',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.headerText,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Profile Picture Upload
                    Center(
                      child: Card(
                        color: AppColors.secondaryBackground,
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: ProfilePictureUploader(
                            userId: user.id,
                            currentImageUrl: _currentProfilePictureUrl.isNotEmpty
                                ? _currentProfilePictureUrl
                                : null,
                            onUploadComplete: (imageUrl) {
                              setState(() {
                                _currentProfilePictureUrl = imageUrl;
                              });
                              print('✅ Profile picture URL updated: $imageUrl');
                            },
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),

                    // Account Information Section
                    const Text(
                      'Account Information',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.headerText,
                      ),
                    ),
                    const SizedBox(height: 16),

                    Card(
                      color: AppColors.secondaryBackground,
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: [
                            _buildSettingRow('Name', user.name),
                            Divider(color: AppColors.dividerColor),
                            _buildSettingRow('Email', user.email),
                            Divider(color: AppColors.dividerColor),
                            _buildSettingRow('Role', user.roleDisplayName),
                            if (user.department != null &&
                                user.department!.isNotEmpty) ...[
                              Divider(color: AppColors.dividerColor),
                              _buildSettingRow('Department', user.department!),
                            ],
                            if (user.studentId != null &&
                                user.studentId!.isNotEmpty) ...[
                              Divider(color: AppColors.dividerColor),
                              _buildSettingRow('Student ID', user.studentId!),
                            ],
                            Divider(color: AppColors.dividerColor),
                            _buildSettingRow(
                              'Member Since',
                              user.createdAt.toString().split(' ')[0],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),

                    // Actions Section
                    const Text(
                      'Actions',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.headerText,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // View Full Profile Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => UserProfileScreen(
                                onBack: () => Navigator.pop(context),
                              ),
                            ),
                          );
                        },
                        icon: const Icon(Icons.person),
                        label: const Text('View Full Profile'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.buttonPrimary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Logout Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          _showLogoutConfirmation(context, loginProvider);
                        },
                        icon: const Icon(Icons.logout),
                        label: const Text('Logout'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.error,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  /// Build a settings row
  Widget _buildSettingRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: AppColors.mutedText,
              fontWeight: FontWeight.w500,
            ),
          ),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: const TextStyle(
                color: AppColors.headerText,
                fontWeight: FontWeight.w600,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  /// Show logout confirmation dialog
  void _showLogoutConfirmation(
    BuildContext context,
    LoginProvider loginProvider,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await loginProvider.logout();
              // Consumer in AppRoot will detect isAuthenticated = false and navigate
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}
