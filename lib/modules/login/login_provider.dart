import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide User;
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

  /// Login with admin credentials (username and password)
  Future<void> adminLogin(String username, String password) async {
    print('📱 [LoginProvider] adminLogin started - Username: $username');
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Verify admin credentials from admin_accounts table
      final adminRecord = await SupabaseService.client
          .from('admin_accounts')
          .select()
          .eq('username', username)
          .maybeSingle();

      if (adminRecord == null) {
        throw Exception('Admin account not found');
      }

      // Simple password verification (ideally should use bcrypt comparison on backend)
      // For now, doing basic check - in production, use a backend function
      if (adminRecord['password_hash'] != password) {
        throw Exception('Invalid password');
      }

      if (adminRecord['is_active'] != true) {
        throw Exception('Admin account is inactive');
      }

      // Set admin as authenticated
      _currentUserRole = UserRole.admin;
      _currentUser = User(
        id: adminRecord['id'],
        email: adminRecord['email'] ?? 'admin@campus.local',
        name: adminRecord['full_name'] ?? adminRecord['username'],
        role: UserRole.admin,
        createdAt: DateTime.parse(adminRecord['created_at']),
      );
      _isAuthenticated = true;
      _errorMessage = null;
      print('✅ [LoginProvider] adminLogin success!');
    } catch (e) {
      _errorMessage = e.toString();
      _isAuthenticated = false;
      print('❌ [LoginProvider] adminLogin error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

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

  /// Sign up with username, email, and password (student or teacher only)
  Future<void> signUp(
    String username,
    String email,
    String password,
    UserRole role,
  ) async {
    print('📱 [LoginProvider] signUp started - Role: $role');
    
    // Prevent admin signup through this method
    if (role == UserRole.admin) {
      _errorMessage = 'Admin accounts must be created by administrators';
      print('❌ [LoginProvider] signUp error: Admin signup not allowed');
      notifyListeners();
      return;
    }

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
          'role': role.toString().split('.').last, // 'student' or 'teacher'
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

  /// Login with Google 
  /// Login with Google using Supabase OAuth
  Future<void> loginWithGoogle(UserRole role) async {
    print('📱 [LoginProvider] loginWithGoogle started - Role: $role');
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Use Supabase's native OAuth flow
      // For Flutter web, use Supabase's auth callback URL
      await SupabaseService.client.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: 'https://ejyvbgkqplymqscwifnh.supabase.co/auth/v1/callback',
      );

      // After OAuth callback, check if user exists
      final currentUser = SupabaseService.client.auth.currentUser;
      if (currentUser != null) {
        print('📱 [LoginProvider] Google auth successful, user: ${currentUser.id}');
        
        // Check if user exists in database
        try {
          final userRecord = await SupabaseService.client
              .from('users')
              .select()
              .eq('id', currentUser.id)
              .single();
          
          print('📱 [LoginProvider] User already exists in database');
          _currentUserRole = UserRole.values.firstWhere(
            (r) => r.toString().split('.').last == userRecord['role'],
            orElse: () => role,
          );
        } catch (e) {
          // User doesn't exist, create new user
          print('📱 [LoginProvider] Creating new user from Google sign-in');
          final email = currentUser.email ?? '';
          final username = currentUser.userMetadata?['name']?.toString().replaceAll(' ', '_') ?? 'google_user';
          
          await SupabaseService.client.from('users').insert({
            'id': currentUser.id,
            'email': email,
            'username': username,
            'full_name': currentUser.userMetadata?['name'] ?? 'User',
            'role': role.toString().split('.').last,
          });
          
          _currentUserRole = role;
        }

        _currentUser = User(
          id: currentUser.id,
          email: currentUser.email ?? '',
          name: currentUser.userMetadata?['name'] ?? 'User',
          role: _currentUserRole!,
          createdAt: DateTime.now(),
        );
        _isAuthenticated = true;
        _errorMessage = null;
        print('✅ [LoginProvider] Google login success!');
      } else {
        throw Exception('Failed to get user after Google auth');
      }
    } catch (e) {
      _errorMessage = e.toString();
      _isAuthenticated = false;
      print('❌ [LoginProvider] Google login error: $e');
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
