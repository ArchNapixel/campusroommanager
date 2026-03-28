import 'package:flutter/material.dart';
import '../core/builders/login_screen_builder.dart';
import '../core/models/user_model.dart';
import '../core/theme/app_theme.dart';
import '../modules/login/role_selector_widget.dart';

/// Main login screen using Builder pattern
class LoginScreen extends StatefulWidget {
  final Function(UserRole) onRoleSelected;

  const LoginScreen({
    Key? key,
    required this.onRoleSelected,
  }) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late final LoginScreenSpecification _spec;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  UserRole? _selectedRole;

  @override
  void initState() {
    super.initState();
    _spec = LoginScreenBuilder()
        .withTitle('Campus Room Manager')
        .withSubtitle('Book labs and AV rooms instantly')
        .showStudentRole(true)
        .showTeacherRole(true)
        .showAdminRole(false)
        .showForgotPassword(true)
        .showRememberMe(true)
        .build();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() {
    if (_selectedRole == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select a role')),
      );
      return;
    }

    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill all fields')),
      );
      return;
    }

    widget.onRoleSelected(_selectedRole!);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      body: SingleChildScrollView(
        child: Container(
          height: MediaQuery.of(context).size.height,
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
            padding: EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo/Header
                SizedBox(height: 40),
                Icon(
                  Icons.meeting_room,
                  size: 64,
                  color: AppColors.available,
                ),
                SizedBox(height: 24),
                Text(
                  _spec.title,
                  style: Theme.of(context).textTheme.displayMedium?.copyWith(
                        color: AppColors.headerText,
                      ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 8),
                Text(
                  _spec.subtitle,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.mutedText,
                      ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 48),

                // Role Selection
                Text(
                  'Select Your Role',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                SizedBox(height: 16),
                RoleSelector(
                  availableRoles: _spec.availableRoles,
                  selectedRole: _selectedRole,
                  onRoleSelected: (role) {
                    setState(() => _selectedRole = role);
                  },
                ),
                SizedBox(height: 32),

                // Email field
                TextField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: 'Email Address',
                    prefixIcon: Icon(Icons.email),
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
                SizedBox(height: 16),

                // Password field
                TextField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                    labelText: 'Password',
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
                  ),
                  obscureText: _obscurePassword,
                ),
                SizedBox(height: 8),

                // Forgot password & Remember me
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (_spec.showRememberMe)
                      Flexible(
                        child: Row(
                          children: [
                            Checkbox(
                              value: false,
                              onChanged: (_) {},
                            ),
                            Text('Remember me'),
                          ],
                        ),
                      ),
                    if (_spec.showForgotPassword)
                      Flexible(
                        child: TextButton(
                          onPressed: () {},
                          child: Text('Forgot Password?'),
                        ),
                      ),
                  ],
                ),
                SizedBox(height: 32),

                // Login button
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _handleLogin,
                    child: Text('Login'),
                  ),
                ),
                SizedBox(height: 16),

                // Demo mode option
                if (_spec.showDemoMode)
                  TextButton(
                    onPressed: () {
                      if (_selectedRole != null) {
                        widget.onRoleSelected(_selectedRole!);
                      }
                    },
                    child: Text('Continue as ${_selectedRole?.name}'),
                  ),

                SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
