import 'package:flutter/material.dart';
import '../../../core/models/user_model.dart';
import '../login_provider.dart';
import 'role_selection_dialog.dart';
import 'admin_security_code_dialog.dart';

enum AuthFlowState {
  splash,
  authChoice,
  loginForm,
  signupForm,
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
  ) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => RoleSelectionDialog(
        onRoleSelected: (role) async {
          print('🎭 [RoleSelectionDialog] Role selected: $role');
          await loginProvider.loginWithEmail(email, password, role);
          
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

  /// Show role selection dialog for signup (with admin security code)
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
        includeAdminWithSecurity: true,
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
        onAdminPressed: () {
          _showAdminSecurityCode(
            context,
            loginProvider,
            username,
            email,
            password,
            setState,
            onError,
            () {
              // After successful admin signup, close both dialogs
              Navigator.pop(context);
            },
          );
        },
      ),
    );
  }

  static Future<void> _showAdminSecurityCode(
    BuildContext context,
    LoginProvider loginProvider,
    String username,
    String email,
    String password,
    Function(void Function()) setState,
    VoidCallback onError,
    VoidCallback onSuccess,
  ) {
    print('🔐 [_showAdminSecurityCode] Showing admin security code dialog');
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AdminSecurityCodeDialog(
        onCodeSubmitted: (isValid) async {
          print('🔐 [AdminSecurityCodeDialog] Code submitted, isValid: $isValid');
          if (isValid && context.mounted) {
            Navigator.pop(context, true);
            print('🎭 [AdminSecurityCodeDialog] Admin code valid, performing signup');
            await loginProvider.signUp(
              username,
              email,
              password,
              UserRole.admin,
            );
            
            if (context.mounted) {
              if (loginProvider.isAuthenticated) {
                print('🎭 [AdminSecurityCodeDialog] Admin signup successful, closing all dialogs');
                // Close admin dialog first
                // Then call onSuccess to close the role selection dialog
                onSuccess();
              } else if (loginProvider.errorMessage != null) {
                print('🎭 [AdminSecurityCodeDialog] Admin signup failed: ${loginProvider.errorMessage}');
                // Close admin dialog first
                Navigator.pop(context);
                // Then show error dialog
                await _showErrorDialog(context, loginProvider.errorMessage!);
              }
            }
          }
        },
      ),
    );
  }
}
