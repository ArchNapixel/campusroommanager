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
        profilePictureUrl: adminRecord['profile_picture_url'],
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
    print('📱 [LoginProvider] loginWithEmail started for email: $email');
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
        // Fetch user details from database to get role and name
        print('📱 [LoginProvider] Fetching user details from database');
        final userRecord = await SupabaseService.client
            .from('users')
            .select()
            .eq('id', response.user!.id)
            .single();

        print('📱 [LoginProvider] User record fetched: role=${userRecord['role']}, name=${userRecord['full_name']}');
        
        // Get role from database (this is the user's actual role from signup)
        _currentUserRole = UserRole.values.firstWhere(
          (r) => r.toString().split('.').last == userRecord['role'],
          orElse: () => UserRole.student,
        );
        
        _currentUser = User(
          id: response.user!.id,
          email: response.user!.email ?? '',
          name: userRecord['full_name'] ?? 'User',
          role: _currentUserRole!,
          profilePictureUrl: userRecord['profile_picture_url'],
          createdAt: DateTime.now(),
        );
        _isAuthenticated = true;
        _errorMessage = null;
        print('✅ [LoginProvider] loginWithEmail success! Role: $_currentUserRole');
      }
    } catch (e) {
      // Handle specific error types with helpful messages
      String errorMsg = e.toString();
      
      if (errorMsg.contains('email_not_confirmed')) {
        _errorMessage = 'Email not confirmed. Please check your email for a confirmation link. If you haven\'t received it, check your spam folder.';
        print('⚠️  [LoginProvider] Email not confirmed error');
      } else if (errorMsg.contains('Invalid login credentials') || 
                 errorMsg.contains('invalid_grant')) {
        _errorMessage = 'Invalid email or password. Please check and try again.';
        print('⚠️  [LoginProvider] Invalid credentials error');
      } else if (errorMsg.contains('Connection failed') || 
                 errorMsg.contains('SocketException')) {
        _errorMessage = 'Connection failed. Please check your internet connection.';
        print('⚠️  [LoginProvider] Connection error');
      } else {
        _errorMessage = 'Login failed: $errorMsg';
      }
      
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
        // Insert user into users table with retry logic for timing issues
        print('📱 [LoginProvider] Inserting user into database');
        
        int retries = 0;
        const maxRetries = 3;
        bool success = false;
        
        while (!success && retries < maxRetries) {
          try {
            await SupabaseService.client.from('users').insert({
              'id': response.user!.id,
              'email': email,
              'username': username,
              'full_name': username,
              'role': role.toString().split('.').last, // 'student' or 'teacher'
            });
            success = true;
            print('✅ [LoginProvider] User inserted into database on attempt ${retries + 1}');
          } catch (e) {
            retries++;
            if (retries < maxRetries) {
              // Wait before retrying (100ms * retry number)
              await Future.delayed(Duration(milliseconds: 100 * retries));
              print('🔄 [LoginProvider] Retrying user insert (attempt ${retries + 1}/$maxRetries)');
            } else {
              rethrow;
            }
          }
        }

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
          // User doesn't exist, create new user with retry logic
          print('📱 [LoginProvider] Creating new user from Google sign-in');
          final email = currentUser.email ?? '';
          final username = currentUser.userMetadata?['name']?.toString().replaceAll(' ', '_') ?? 'google_user';
          
          int retries = 0;
          const maxRetries = 3;
          bool success = false;
          
          while (!success && retries < maxRetries) {
            try {
              await SupabaseService.client.from('users').insert({
                'id': currentUser.id,
                'email': email,
                'username': username,
                'full_name': currentUser.userMetadata?['name'] ?? 'User',
                'role': role.toString().split('.').last,
              });
              success = true;
              print('✅ [LoginProvider] Google user inserted into database on attempt ${retries + 1}');
            } catch (insertError) {
              retries++;
              if (retries < maxRetries) {
                // Wait before retrying (100ms * retry number)
                await Future.delayed(Duration(milliseconds: 100 * retries));
                print('🔄 [LoginProvider] Retrying Google user insert (attempt ${retries + 1}/$maxRetries)');
              } else {
                rethrow;
              }
            }
          }
          
          _currentUserRole = role;
        }

        _currentUser = User(
          id: currentUser.id,
          email: currentUser.email ?? '',
          name: currentUser.userMetadata?['name'] ?? 'User',
          role: _currentUserRole!,
          profilePictureUrl: currentUser.userMetadata?['avatar_url'],
          createdAt: DateTime.now(),
        );
        _isAuthenticated = true;
        _errorMessage = null;
        print('✅ [LoginProvider] Google login success!');
      } else {
        throw Exception('Failed to get user after Google auth');
      }
    } catch (e) {
      // Handle specific error types with helpful messages
      String errorMsg = e.toString();
      
      if (errorMsg.contains('email_not_confirmed')) {
        _errorMessage = 'Email not confirmed. Please check your email for a confirmation link.';
        print('⚠️  [LoginProvider] Email not confirmed error on Google login');
      } else if (errorMsg.contains('user_already_exists') || 
                 errorMsg.contains('already exists')) {
        _errorMessage = 'This Google account is already linked. Please login with your credentials.';
        print('⚠️  [LoginProvider] User already exists error');
      } else if (errorMsg.contains('Connection failed') || 
                 errorMsg.contains('SocketException')) {
        _errorMessage = 'Connection failed. Please check your internet connection.';
        print('⚠️  [LoginProvider] Connection error on Google login');
      } else if (errorMsg.contains('PlatformException') || 
                 errorMsg.contains('sign_in_cancelled')) {
        _errorMessage = 'Google sign-in was cancelled.';
        print('⚠️  [LoginProvider] Google sign-in cancelled');
      } else {
        _errorMessage = 'Google login failed: $errorMsg';
      }
      
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
