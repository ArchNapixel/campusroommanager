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
    IconData icon = Icons.error_outline;

    // Check for database/Postgrest errors
    if (errorMessage.contains('foreign key constraint') || errorMessage.contains('23503')) {
      title = 'Account Setup Error';
      displayMessage = 'There was a problem creating your account profile. Please try signing up again. If this persists, contact support.';
      icon = Icons.storage;
    }
    // Check for email_address_invalid from Supabase
    else if (errorMessage.contains('email_address_invalid') || 
        errorMessage.contains('Email address') && errorMessage.contains('invalid')) {
      title = 'Invalid Email Address';
      displayMessage = 'The email address you entered is invalid.\n\nPlease check and try again. Example: student@university.edu';
      icon = Icons.email_outlined;
    } else if (errorMessage.contains('rate limit') || errorMessage.contains('429')) {
      title = 'Too Many Attempts';
      displayMessage = 'Too many signup attempts. Please wait a few minutes before trying again.';
      icon = Icons.hourglass_empty_outlined;
    } else if (errorMessage.contains('already exists') || errorMessage.contains('unique')) {
      title = 'Account Already Exists';
      displayMessage = 'This email is already registered. Please try logging in instead.';
      icon = Icons.person_add_disabled;
    } else if (errorMessage.contains('Weak password') || errorMessage.contains('weak')) {
      title = 'Password Too Weak';
      displayMessage = 'Your password is too weak. Please use a stronger combination of letters, numbers, and symbols.';
      icon = Icons.lock_outline;
    } else if (errorMessage.contains('password')) {
      title = 'Password Error';
      displayMessage = 'Password must be at least 6 characters long and contain a mix of characters.';
      icon = Icons.lock_outline;
    } else if (errorMessage.contains('Admin')) {
      title = 'Admin Creation Error';
      displayMessage = 'Admin accounts can only be created by existing administrators.';
      icon = Icons.admin_panel_settings_outlined;
    } else if (errorMessage.contains('Connection failed') || 
               errorMessage.contains('Unable to connect') ||
               errorMessage.contains('SocketException')) {
      title = 'Connection Error';
      displayMessage = 'Unable to connect to the server. Please check your internet connection and try again.';
      icon = Icons.cloud_off_outlined;
    } else if (errorMessage.contains('timeout') || errorMessage.contains('Timeout')) {
      title = 'Connection Timeout';
      displayMessage = 'The request took too long. Please check your connection and try again.';
      icon = Icons.schedule_outlined;
    } else {
      // Generic fallback - show first 100 chars of error for debugging
      displayMessage = 'An error occurred: ${errorMessage.substring(0, errorMessage.length > 100 ? 100 : errorMessage.length)}...';
      title = 'Signup Failed';
    }

    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => AlertDialog(
        icon: Icon(icon, size: 48, color: Colors.red),
        title: Text(
          title,
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        content: Text(
          displayMessage,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
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
