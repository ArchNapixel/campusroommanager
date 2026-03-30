import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/models/user_model.dart';
import '../core/theme/app_theme.dart';
import '../modules/login/login_provider.dart';

/// Screen for email-based signup (alternative to Google OAuth)
class EmailSignupScreen extends StatefulWidget {
  final VoidCallback onBackPressed;

  const EmailSignupScreen({
    Key? key,
    required this.onBackPressed,
  }) : super(key: key);

  @override
  State<EmailSignupScreen> createState() => _EmailSignupScreenState();
}

class _EmailSignupScreenState extends State<EmailSignupScreen> {
  final _emailController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _agreeToTerms = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _handleContinue() {
    // Validation
    if (_emailController.text.isEmpty ||
        _usernameController.text.isEmpty ||
        _passwordController.text.isEmpty ||
        _confirmPasswordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill all fields')),
      );
      return;
    }

    if (!_emailController.text.contains('@')) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter a valid email')),
      );
      return;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Passwords do not match')),
      );
      return;
    }

    if (_passwordController.text.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Password must be at least 6 characters')),
      );
      return;
    }

    if (!_agreeToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please agree to Terms and Conditions')),
      );
      return;
    }

    setState(() => _isLoading = true);

    // Show role selection dialog
    _showRoleSelectionDialog();
  }

  void _showRoleSelectionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text('Select Your Role'),
        content: Text('Are you a Student or an Instructor?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _completeSignup(UserRole.student);
            },
            child: Padding(
              padding: EdgeInsets.all(8),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.school, size: 32, color: AppColors.buttonPrimary),
                  SizedBox(height: 8),
                  Text('Student'),
                ],
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _completeSignup(UserRole.teacher);
            },
            child: Padding(
              padding: EdgeInsets.all(8),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.person, size: 32, color: AppColors.buttonPrimary),
                  SizedBox(height: 8),
                  Text('Instructor'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _completeSignup(UserRole role) async {
    final loginProvider = context.read<LoginProvider>();

    await loginProvider.signUpWithEmailDirect(
      email: _emailController.text,
      username: _usernameController.text,
      password: _passwordController.text,
      role: role,
    );

    setState(() => _isLoading = false);

    if (!mounted) return;

    if (loginProvider.isAuthenticated) {
      // Success - AppRoot will handle navigation to AppShell
      print('✅ Signup successful, navigating back');
      Navigator.of(context).popUntil((route) => route.isFirst);
    } else if (loginProvider.errorMessage != null) {
      // Show error dialog
      print('❌ Signup failed: ${loginProvider.errorMessage}');
      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          icon: Icon(Icons.error_outline, size: 48, color: Colors.red),
          title: Text('Signup Failed'),
          content: Text(loginProvider.errorMessage!),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Try Again'),
            ),
          ],
        ),
      );

      // Clear the error
      loginProvider.clearError();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: _isLoading ? null : widget.onBackPressed,
        ),
      ),
      body: Consumer<LoginProvider>(
        builder: (context, loginProvider, _) {
          bool isLoadingNow = _isLoading || loginProvider.isLoading;

          return SingleChildScrollView(
            child: Container(
              constraints: BoxConstraints(
                minHeight: MediaQuery.of(context).size.height - 100,
              ),
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 24),
                  Text(
                    'Create Account',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: AppColors.headerText,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Sign up with your email to get started',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.mutedText,
                        ),
                  ),
                  SizedBox(height: 32),

                  // Email Field
                  Text('Email Address', style: TextStyle(fontWeight: FontWeight.w600)),
                  SizedBox(height: 8),
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      hintText: 'your.email@example.com',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      enabled: !isLoadingNow,
                    ),
                  ),
                  SizedBox(height: 20),

                  // Username Field
                  Text('Username', style: TextStyle(fontWeight: FontWeight.w600)),
                  SizedBox(height: 8),
                  TextFormField(
                    controller: _usernameController,
                    decoration: InputDecoration(
                      hintText: 'Choose your username',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      enabled: !isLoadingNow,
                    ),
                  ),
                  SizedBox(height: 20),

                  // Password Field
                  Text('Password', style: TextStyle(fontWeight: FontWeight.w600)),
                  SizedBox(height: 8),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    decoration: InputDecoration(
                      hintText: 'At least 6 characters',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword ? Icons.visibility_off : Icons.visibility,
                        ),
                        onPressed: () {
                          setState(() => _obscurePassword = !_obscurePassword);
                        },
                      ),
                      enabled: !isLoadingNow,
                    ),
                  ),
                  SizedBox(height: 20),

                  // Confirm Password Field
                  Text('Confirm Password', style: TextStyle(fontWeight: FontWeight.w600)),
                  SizedBox(height: 8),
                  TextFormField(
                    controller: _confirmPasswordController,
                    obscureText: _obscureConfirmPassword,
                    decoration: InputDecoration(
                      hintText: 'Repeat your password',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureConfirmPassword ? Icons.visibility_off : Icons.visibility,
                        ),
                        onPressed: () {
                          setState(() => _obscureConfirmPassword = !_obscureConfirmPassword);
                        },
                      ),
                      enabled: !isLoadingNow,
                    ),
                  ),
                  SizedBox(height: 24),

                  // Terms Checkbox
                  Row(
                    children: [
                      Checkbox(
                        value: _agreeToTerms,
                        onChanged: isLoadingNow
                            ? null
                            : (value) {
                                setState(() => _agreeToTerms = value ?? false);
                              },
                      ),
                      Expanded(
                        child: Text(
                          'I agree to Terms and Conditions',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 32),

                  // Sign Up Button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: isLoadingNow ? null : _handleContinue,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.buttonPrimary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: isLoadingNow
                          ? SizedBox(
                              height: 24,
                              width: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation(Colors.white),
                              ),
                            )
                          : Text(
                              'Create Account',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ),
                  SizedBox(height: 24),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
