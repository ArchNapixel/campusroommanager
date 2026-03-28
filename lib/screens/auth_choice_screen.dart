import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

/// Authentication choice screen - Login or Sign Up
class AuthChoiceScreen extends StatelessWidget {
  final VoidCallback onLoginPressed;
  final VoidCallback onSignUpPressed;
  final VoidCallback onAdminLoginPressed;

  const AuthChoiceScreen({
    Key? key,
    required this.onLoginPressed,
    required this.onSignUpPressed,
    required this.onAdminLoginPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
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
        child: SingleChildScrollView(
          child: Container(
            height: MediaQuery.of(context).size.height,
            child: Center(
              child: Container(
                constraints: BoxConstraints(maxWidth: 400),
                padding: EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Logo
                    Icon(
                      Icons.meeting_room,
                      size: 80,
                      color: AppColors.available,
                    ),
                    SizedBox(height: 24),
                    Text(
                      'Campus Room Manager',
                      style: Theme.of(context).textTheme.displayMedium?.copyWith(
                            color: AppColors.headerText,
                          ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 12),
                    Text(
                      'Book labs and AV rooms instantly',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: AppColors.mutedText,
                          ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 60),

                    // Welcome text
                    Text(
                      'Welcome',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            color: AppColors.headerText,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    SizedBox(height: 12),
                    Text(
                      'Get started by logging in or creating a new account',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.mutedText,
                          ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 48),

                    // Login Button
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: onLoginPressed,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.buttonPrimary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.login, size: 20),
                            SizedBox(width: 12),
                            Text(
                              'Login',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 16),

                    // Sign Up Button
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: OutlinedButton(
                        onPressed: onSignUpPressed,
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
                            Icon(
                              Icons.person_add,
                              size: 20,
                              color: AppColors.buttonPrimary,
                            ),
                            SizedBox(width: 12),
                            Text(
                              'Sign Up',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: AppColors.buttonPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 16),

                    // Admin Login Button
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: OutlinedButton(
                        onPressed: onAdminLoginPressed,
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(
                            color: AppColors.warning,
                            width: 2,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.admin_panel_settings,
                              size: 20,
                              color: AppColors.warning,
                            ),
                            SizedBox(width: 12),
                            Text(
                              'Admin Login',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: AppColors.warning,
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
      )
    );
  }
}
