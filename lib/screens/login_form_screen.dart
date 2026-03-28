import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

/// Login form screen with email, password, and Google login
class LoginFormScreen extends StatefulWidget {
  final VoidCallback onBackPressed;
  final Function(String email, String password) onLoginPressed;
  final VoidCallback onGooglePressed;

  const LoginFormScreen({
    Key? key,
    required this.onBackPressed,
    required this.onLoginPressed,
    required this.onGooglePressed,
  }) : super(key: key);

  @override
  State<LoginFormScreen> createState() => _LoginFormScreenState();
}

class _LoginFormScreenState extends State<LoginFormScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill all fields')),
      );
      return;
    }

    setState(() => _isLoading = true);
    widget.onLoginPressed(_emailController.text, _passwordController.text);
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
      body: Container(
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
                    'Welcome Back',
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                          color: AppColors.headerText,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Sign in to your account',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: AppColors.mutedText,
                        ),
                  ),
                  SizedBox(height: 40),

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
                    enabled: !_isLoading,
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
                    enabled: !_isLoading,
                    decoration: InputDecoration(
                      hintText: 'Enter your password',
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
                  SizedBox(height: 12),

                  // Forgot password
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: _isLoading ? null : () {},
                      child: Text(
                        'Forgot Password?',
                        style: TextStyle(color: AppColors.buttonPrimary),
                      ),
                    ),
                  ),
                  SizedBox(height: 24),

                  // Login button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _handleLogin,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.buttonPrimary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _isLoading
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
                              'Login',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ),
                  SizedBox(height: 24),

                  // Divider with text
                  Row(
                    children: [
                      Expanded(
                        child: Divider(color: AppColors.borderColor),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          'OR',
                          style: TextStyle(color: AppColors.mutedText),
                        ),
                      ),
                      Expanded(
                        child: Divider(color: AppColors.borderColor),
                      ),
                    ],
                  ),
                  SizedBox(height: 24),

                  // Google Login button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: OutlinedButton(
                      onPressed: _isLoading ? null : widget.onGooglePressed,
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(
                          color: AppColors.borderColor,
                          width: 1,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.mail_outline,
                            color: AppColors.headerText,
                          ),
                          SizedBox(width: 12),
                          Text(
                            'Continue with Google',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppColors.headerText,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
