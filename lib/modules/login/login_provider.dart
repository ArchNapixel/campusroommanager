import 'package:flutter/material.dart';
import '../../core/models/user_model.dart';

/// State provider for login/authentication
class LoginProvider with ChangeNotifier {
  UserRole? _currentUserRole;
  User? _currentUser;
  bool _isAuthenticated = false;

  // Getters
  UserRole? get currentUserRole => _currentUserRole;
  User? get currentUser => _currentUser;
  bool get isAuthenticated => _isAuthenticated;

  /// Login with role
  Future<void> login(UserRole role, String email, String password) async {
    // TODO: Implement actual authentication
    // For now, this is a placeholder
    _currentUserRole = role;
    _isAuthenticated = true;
    notifyListeners();
  }

  /// Logout
  void logout() {
    _currentUserRole = null;
    _currentUser = null;
    _isAuthenticated = false;
    notifyListeners();
  }

  /// Set current user
  void setCurrentUser(User user) {
    _currentUser = user;
    notifyListeners();
  }

  /// Check if user has specific role
  bool hasRole(UserRole role) {
    return _currentUserRole == role;
  }

  /// Check if user is admin
  bool get isAdmin => _currentUserRole == UserRole.admin;

  /// Check if user is teacher
  bool get isTeacher => _currentUserRole == UserRole.teacher;

  /// Check if user is student
  bool get isStudent => _currentUserRole == UserRole.student;
}
