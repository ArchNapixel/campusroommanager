import '../models/user_model.dart';

/// Builder for constructing Login Screen UI specifications
class LoginScreenBuilder {
  bool _showStudentRole = true;
  bool _showTeacherRole = true;
  bool _showAdminRole = true;
  String _title = 'Campus Room Manager';
  String _subtitle = 'Book labs and AV rooms instantly';
  bool _showForgotPassword = true;
  bool _showRememberMe = true;
  bool _showDemoMode = false;
  Map<String, dynamic> _customTheme = {};
  List<UserRole> _availableRoles = [
    UserRole.student,
    UserRole.teacher,
    UserRole.admin
  ];

  LoginScreenBuilder();

  LoginScreenBuilder showStudentRole(bool show) {
    _showStudentRole = show;
    return this;
  }

  LoginScreenBuilder showTeacherRole(bool show) {
    _showTeacherRole = show;
    return this;
  }

  LoginScreenBuilder showAdminRole(bool show) {
    _showAdminRole = show;
    return this;
  }

  LoginScreenBuilder withTitle(String title) {
    _title = title;
    return this;
  }

  LoginScreenBuilder withSubtitle(String subtitle) {
    _subtitle = subtitle;
    return this;
  }

  LoginScreenBuilder showForgotPassword(bool show) {
    _showForgotPassword = show;
    return this;
  }

  LoginScreenBuilder showRememberMe(bool show) {
    _showRememberMe = show;
    return this;
  }

  LoginScreenBuilder showDemoMode(bool show) {
    _showDemoMode = show;
    return this;
  }

  LoginScreenBuilder withCustomTheme(Map<String, dynamic> theme) {
    _customTheme = theme;
    return this;
  }

  /// Build the login screen specification
  LoginScreenSpecification build() {
    return LoginScreenSpecification(
      showStudentRole: _showStudentRole,
      showTeacherRole: _showTeacherRole,
      showAdminRole: _showAdminRole,
      title: _title,
      subtitle: _subtitle,
      showForgotPassword: _showForgotPassword,
      showRememberMe: _showRememberMe,
      showDemoMode: _showDemoMode,
      customTheme: _customTheme,
      availableRoles: _availableRoles,
    );
  }
}

/// Specification object for login screen
class LoginScreenSpecification {
  final bool showStudentRole;
  final bool showTeacherRole;
  final bool showAdminRole;
  final String title;
  final String subtitle;
  final bool showForgotPassword;
  final bool showRememberMe;
  final bool showDemoMode;
  final Map<String, dynamic> customTheme;
  final List<UserRole> availableRoles;

  LoginScreenSpecification({
    required this.showStudentRole,
    required this.showTeacherRole,
    required this.showAdminRole,
    required this.title,
    required this.subtitle,
    required this.showForgotPassword,
    required this.showRememberMe,
    required this.showDemoMode,
    required this.customTheme,
    required this.availableRoles,
  });
}
