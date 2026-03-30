import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme/app_theme.dart';
import '../modules/login/login_provider.dart';
import 'google_signup_credentials_screen.dart';
import 'email_signup_screen.dart';

/// Sign up form screen - Google OAuth only
class SignUpFormScreen extends StatefulWidget {
  final VoidCallback onBackPressed;

  const SignUpFormScreen({
    Key? key,
    required this.onBackPressed,
  }) : super(key: key);

  @override
  State<SignUpFormScreen> createState() => _SignUpFormScreenState();
}

class _SignUpFormScreenState extends State<SignUpFormScreen> {
  bool _isLoading = false;

  void _handleGoogleSignUp() async {
    setState(() => _isLoading = true);
    
    final loginProvider = context.read<LoginProvider>();
    
    // Start Google OAuth flow
    await loginProvider.startGoogleSignUpFlow();
    
    if (!mounted) return;

    if (loginProvider.googleSignUpData != null) {
      // OAuth successful, navigate to credentials screen
      final data = loginProvider.googleSignUpData!;
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => GoogleSignupCredentialsScreen(
            userId: data['id']!,
            googleEmail: data['email']!,
            googleName: data['display_name']!,
            googleAvatarUrl: data['photo_url'],
            onBackPressed: () {
              Navigator.of(context).pop();
              setState(() => _isLoading = false);
            },
          ),
        ),
      );
    } else if (loginProvider.errorMessage != null) {
      // Show error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(loginProvider.errorMessage!)),
      );
      setState(() => _isLoading = false);
    } else {
      // Cancelled by user
      setState(() => _isLoading = false);
    }
  }

  void _handleEmailSignUp() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => EmailSignupScreen(
          onBackPressed: () => Navigator.of(context).pop(),
        ),
      ),
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
          onPressed: _isLoading ? null : widget.onBackPressed,
        ),
      ),
      body: Consumer<LoginProvider>(
        builder: (context, loginProvider, _) {
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
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(height: 48),
                      Text(
                        'Create Account',
                        style: Theme.of(context).textTheme.displaySmall?.copyWith(
                              color: AppColors.headerText,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Sign up with your Google account or email to get started',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: AppColors.mutedText,
                            ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 80),

                      // Google Sign Up Button
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton.icon(
                          onPressed: isLoading ? null : _handleGoogleSignUp,
                          icon: Icon(Icons.g_mobiledata, size: 24),
                          label: Text(
                            'Continue with Google',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.buttonPrimary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 16),

                      // Email Sign Up Button
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton.icon(
                          onPressed: isLoading ? null : _handleEmailSignUp,
                          icon: Icon(Icons.email_outlined, size: 24),
                          label: Text(
                            'Sign Up with Email',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.success,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 32),

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
                      SizedBox(height: 48),
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
