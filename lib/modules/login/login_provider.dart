import 'package:flutter/material.dart';
import '../../core/models/user_model.dart';
import '../../core/services/supabase_service.dart';

/// State provider for login/authentication
class LoginProvider with ChangeNotifier {
  UserRole? _currentUserRole;
  User? _currentUser;
  bool _isAuthenticated = false;
  String? _errorMessage;
  bool _isLoading = false;

  // Getters
  UserRole? get currentUserRole => _currentUserRole;
  User? get currentUser => _currentUser;
  bool get isAuthenticated => _isAuthenticated;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _isLoading;

  /// Login with email and password
  Future<void> loginWithEmail(String email, String password, UserRole role) async {
    print('📱 [LoginProvider] loginWithEmail started - Role: $role');
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await SupabaseService.signIn(
        email: email,
        password: password,
      );

      print('📱 [LoginProvider] Got response, user: ${response.user?.id}');
      if (response.user != null) {
        // Fetch user details from database
        print('📱 [LoginProvider] Fetching user details from database');
        final userRecord = await SupabaseService.client
            .from('users')
            .select()
            .eq('id', response.user!.id)
            .single();

        print('📱 [LoginProvider] User record: $userRecord');
        _currentUserRole = UserRole.values.firstWhere(
          (r) => r.toString().split('.').last == userRecord['role'],
          orElse: () => role,
        );
        _currentUser = User(
          id: response.user!.id,
          email: response.user!.email ?? '',
          name: userRecord['username'] ?? 'User',
          role: _currentUserRole!,
          createdAt: DateTime.now(),
        );
        _isAuthenticated = true;
        _errorMessage = null;
        print('✅ [LoginProvider] loginWithEmail success!');
      }
    } catch (e) {
      _errorMessage = e.toString();
      _isAuthenticated = false;
      print('❌ [LoginProvider] loginWithEmail error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Sign up with username, email, and password
  Future<void> signUp(
    String username,
    String email,
    String password,
    UserRole role,
  ) async {
    print('📱 [LoginProvider] signUp started - Role: $role');
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await SupabaseService.signUp(
        email: email,
        password: password,
      );

      print('📱 [LoginProvider] Got response, user: ${response.user?.id}');
      if (response.user != null) {
        // Insert user into users table
        print('📱 [LoginProvider] Inserting user into database');
        await SupabaseService.client.from('users').insert({
          'id': response.user!.id,
          'email': email,
          'username': username,
          'full_name': username,
          'role': role.toString().split('.').last, // 'student', 'teacher', 'admin'
        });
        print('✅ [LoginProvider] User inserted into database');

        _currentUserRole = role;
        _currentUser = User(
          id: response.user!.id,
          email: response.user!.email ?? '',
          name: username,
          role: role,
          createdAt: DateTime.now(),
        );
        _isAuthenticated = true;
        _errorMessage = null;
        print('✅ [LoginProvider] signUp success!');
      }
    } catch (e) {
      _errorMessage = e.toString();
      _isAuthenticated = false;
      print('❌ [LoginProvider] signUp error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Login with Google (placeholder for future implementation)
  Future<void> loginWithGoogle(UserRole role) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // TODO: Implement Google authentication using google_sign_in package
      // For now, this is a placeholder
      _errorMessage = 'Google login not yet implemented';
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Logout
  Future<void> logout() async {
    try {
      await SupabaseService.signOut();
      _currentUserRole = null;
      _currentUser = null;
      _isAuthenticated = false;
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
    }
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

  /// Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
