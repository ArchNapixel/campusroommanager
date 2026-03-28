import 'package:flutter/material.dart';
import '../login_provider.dart';
import 'role_selection_dialog.dart';

enum AuthFlowState {
  splash,
  authChoice,
  loginForm,
  signupForm,
  adminLogin,
  roleSelection,
  authenticated,
}

/// Manages auth flow dialogs and user interactions
class AuthFlowDialogs {
  /// Show error dialog with better error messaging
  static Future<void> _showErrorDialog(
    BuildContext context,
    String errorMessage,
  ) {
    // Check for specific error types and provide better messages
    String displayMessage = errorMessage;
    String title = 'Error';

    if (errorMessage.contains('rate limit') || errorMessage.contains('429')) {
      title = 'Too Many Attempts';
      displayMessage = 'Too many signup attempts. Please wait a few minutes before trying again.';
    } else if (errorMessage.contains('invalid format') || errorMessage.contains('validation_failed')) {
      title = 'Invalid Email';
      displayMessage = 'Please enter a valid email address (e.g., user@example.com)';
    } else if (errorMessage.contains('already exists') || errorMessage.contains('unique')) {
      title = 'Account Exists';
      displayMessage = 'This email is already registered. Please try logging in instead.';
    } else if (errorMessage.contains('password')) {
      title = 'Password Error';
      displayMessage = 'Password must be at least 6 characters long.';
    }

    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(displayMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  /// Show role selection dialog for login
  static Future<void> showLoginRoleSelection(
    BuildContext context,
    LoginProvider loginProvider,
    String email,
    String password,
    Function(void Function()) setState,
    VoidCallback onError,
    {bool isGoogleLogin = false}
  ) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => RoleSelectionDialog(
        onRoleSelected: (role) async {
          print('🎭 [RoleSelectionDialog] Role selected: $role');
          
          if (isGoogleLogin) {
            await loginProvider.loginWithGoogle(role);
          } else {
            await loginProvider.loginWithEmail(email, password, role);
          }
          
          if (context.mounted) {
            if (loginProvider.isAuthenticated) {
              print('🎭 [RoleSelectionDialog] Auth successful, closing dialog');
              // Close dialog on successful login
              Navigator.pop(context);
            } else if (loginProvider.errorMessage != null) {
              print('🎭 [RoleSelectionDialog] Auth failed: ${loginProvider.errorMessage}');
              // Close role dialog first
              Navigator.pop(context);
              // Then show error dialog
              await _showErrorDialog(context, loginProvider.errorMessage!);
            }
          }
        },
      ),
    );
  }

  /// Show role selection dialog for signup (student or teacher only)
  static Future<void> showSignupRoleSelection(
    BuildContext context,
    LoginProvider loginProvider,
    String username,
    String email,
    String password,
    Function(void Function()) setState,
    VoidCallback onError,
  ) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => RoleSelectionDialog(
        onRoleSelected: (role) async {
          print('🎭 [RoleSelectionDialog] Role selected for signup: $role');
          await loginProvider.signUp(username, email, password, role);
          
          if (context.mounted) {
            if (loginProvider.isAuthenticated) {
              print('🎭 [RoleSelectionDialog] Signup successful, closing dialog');
              // Close dialog on successful signup
              Navigator.pop(context);
            } else if (loginProvider.errorMessage != null) {
              print('🎭 [RoleSelectionDialog] Signup failed: ${loginProvider.errorMessage}');
              // Close role dialog first
              Navigator.pop(context);
              // Then show error dialog
              await _showErrorDialog(context, loginProvider.errorMessage!);
            }
          }
        },
      ),
    );
  }
}
