import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/models/user_model.dart';
import '../core/theme/app_theme.dart';
import '../modules/login/login_provider.dart';

/// Sign up form screen with username, email, and password
class SignUpFormScreen extends StatefulWidget {
  final VoidCallback onBackPressed;
  final Function(String username, String email, String password) onSignUpPressed;

  const SignUpFormScreen({
    Key? key,
    required this.onBackPressed,
    required this.onSignUpPressed,
  }) : super(key: key);

  @override
  State<SignUpFormScreen> createState() => _SignUpFormScreenState();
}

class _SignUpFormScreenState extends State<SignUpFormScreen> {
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _agreeToTerms = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _handleSignUp() {
    // Validation
    if (_usernameController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _passwordController.text.isEmpty ||
        _confirmPasswordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill all fields')),
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
    widget.onSignUpPressed(
      _usernameController.text,
      _emailController.text,
      _passwordController.text,
    );
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
          onPressed: widget.onBackPressed,
        ),
      ),
      body: Consumer<LoginProvider>(
        builder: (context, loginProvider, _) {
          // Reset local loading state if provider is no longer loading
          if (!loginProvider.isLoading && _isLoading) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                setState(() => _isLoading = false);
              }
            });
          }

          final isLoading = _isLoading || loginProvider.isLoading;

          return Container(
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
            child: Center(
              child: SingleChildScrollView(
                child: Container(
                  constraints: BoxConstraints(maxWidth: 400),
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 24),
                      Text(
                        'Create Account',
                        style: Theme.of(context).textTheme.displaySmall?.copyWith(
                              color: AppColors.headerText,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Join us today to book rooms',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: AppColors.mutedText,
                            ),
                      ),
                      SizedBox(height: 40),

                      // Username field
                      Text(
                        'Username',
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                              color: AppColors.headerText,
                            ),
                      ),
                      SizedBox(height: 8),
                      TextField(
                        controller: _usernameController,
                        enabled: !isLoading,
                        decoration: InputDecoration(
                          hintText: 'Choose a username',
                          prefixIcon: Icon(Icons.person),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      SizedBox(height: 24),

                      // Email field
                      Text(
                        'Email Address',
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                              color: AppColors.headerText,
                            ),
                      ),
                      SizedBox(height: 8),
                      TextField(
                        controller: _emailController,
                        enabled: !isLoading,
                        decoration: InputDecoration(
                          hintText: 'Enter your email',
                          prefixIcon: Icon(Icons.email),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        keyboardType: TextInputType.emailAddress,
                      ),
                      SizedBox(height: 24),

                      // Password field
                      Text(
                        'Password',
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                              color: AppColors.headerText,
                            ),
                      ),
                      SizedBox(height: 8),
                      TextField(
                        controller: _passwordController,
                        enabled: !isLoading,
                        decoration: InputDecoration(
                          hintText: 'Create a password',
                          prefixIcon: Icon(Icons.lock),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                            ),
                            onPressed: () {
                              setState(() => _obscurePassword = !_obscurePassword);
                            },
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        obscureText: _obscurePassword,
                      ),
                      SizedBox(height: 24),

                      // Confirm Password field
                      Text(
                        'Confirm Password',
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                              color: AppColors.headerText,
                            ),
                      ),
                      SizedBox(height: 8),
                      TextField(
                        controller: _confirmPasswordController,
                        enabled: !isLoading,
                        decoration: InputDecoration(
                          hintText: 'Confirm your password',
                          prefixIcon: Icon(Icons.lock),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureConfirmPassword
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                            ),
                            onPressed: () {
                              setState(
                                  () => _obscureConfirmPassword = !_obscureConfirmPassword);
                            },
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        obscureText: _obscureConfirmPassword,
                      ),
                      SizedBox(height: 24),

                      // Terms and Conditions
                      Row(
                        children: [
                          Checkbox(
                            value: _agreeToTerms,
                            onChanged: isLoading
                                ? null
                                : (value) {
                                    setState(() => _agreeToTerms = value ?? false);
                                  },
                          ),
                          Expanded(
                            child: Text(
                              'I agree to Terms and Conditions',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: AppColors.bodyText,
                                  ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 24),

                      // Sign Up button
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: isLoading ? null : _handleSignUp,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.buttonPrimary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: isLoading
                              ? SizedBox(
                                  height: 24,
                                  width: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      AppColors.headerText,
                                    ),
                                  ),
                                )
                              : Text(
                                  'Sign Up',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                        ),
                      ),
                      SizedBox(height: 16),

                      // Google Sign Up Button
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: OutlinedButton(
                          onPressed: isLoading ? null : () async {
                            setState(() => _isLoading = true);
                            await loginProvider.loginWithGoogle(UserRole.student);
                            setState(() => _isLoading = false);
                            
                            if (context.mounted && loginProvider.isAuthenticated) {
                              // Close and navigate (handled by Consumer in main.dart)
                            } else if (context.mounted && loginProvider.errorMessage != null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Google Sign-up Failed: ${loginProvider.errorMessage}'),
                                  backgroundColor: AppColors.error,
                                ),
                              );
                            }
                          },
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(
                              color: AppColors.buttonPrimary,
                              width: 2,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.g_mobiledata, size: 24, color: AppColors.buttonPrimary),
                              SizedBox(width: 12),
                              Text(
                                'Sign Up with Google',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.buttonPrimary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 16),

                      // Divider
                      Row(
                        children: [
                          Expanded(child: Divider(color: AppColors.mutedText, thickness: 1)),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 12),
                            child: Text(
                              'or',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: AppColors.mutedText,
                                  ),
                            ),
                          ),
                          Expanded(child: Divider(color: AppColors.mutedText, thickness: 1)),
                        ],
                      ),
                      SizedBox(height: 16),

                      // Already have account
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Already have an account? ',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: AppColors.mutedText,
                                ),
                          ),
                          TextButton(
                            onPressed: isLoading ? null : widget.onBackPressed,
                            child: Text(
                              'Login',
                              style: TextStyle(color: AppColors.buttonPrimary),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
