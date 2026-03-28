import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/builders/profile_picture_uploader.dart';
import '../core/theme/app_theme.dart';
import '../modules/login/login_provider.dart';

/// User profile screen with profile picture upload
class UserProfileScreen extends StatefulWidget {
  final VoidCallback? onBack;

  const UserProfileScreen({
    Key? key,
    this.onBack,
  }) : super(key: key);

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  late String _currentProfilePictureUrl;

  @override
  void initState() {
    super.initState();
    // Get current profile picture from login provider
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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: widget.onBack ?? () => Navigator.pop(context),
        ),
        title: const Text('User Profile'),
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
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Profile Picture Upload Section
                    Card(
                      color: AppColors.secondaryBackground,
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          children: [
                            const Text(
                              'Profile Picture',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppColors.headerText,
                              ),
                            ),
                            const SizedBox(height: 20),
                            ProfilePictureUploader(
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
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // User Information Section
                    Card(
                      color: AppColors.secondaryBackground,
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Account Information',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppColors.headerText,
                              ),
                            ),
                            const SizedBox(height: 20),
                            _buildInfoRow('Name', user.name),
                            const SizedBox(height: 12),
                            _buildInfoRow('Email', user.email),
                            const SizedBox(height: 12),
                            _buildInfoRow('Role', user.roleDisplayName),
                            if (user.department != null && user.department!.isNotEmpty)
                              ...[
                                const SizedBox(height: 12),
                                _buildInfoRow('Department', user.department!),
                              ],
                            if (user.studentId != null && user.studentId!.isNotEmpty)
                              ...[
                                const SizedBox(height: 12),
                                _buildInfoRow('Student ID', user.studentId!),
                              ],
                            const SizedBox(height: 12),
                            _buildInfoRow(
                              'Member Since',
                              user.createdAt.toString().split(' ')[0],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Logout Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          _showLogoutConfirmation(context, loginProvider);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.error,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const Text(
                          'Logout',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
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

  /// Build info row for displaying user information
  Widget _buildInfoRow(String label, String value) {
    return Row(
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
            onPressed: () {
              Navigator.pop(context);
              loginProvider.logout();
              Navigator.of(context).pushNamedAndRemoveUntil(
                '/',
                (route) => false,
              );
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
