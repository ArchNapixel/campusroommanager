import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide User;
import '../../core/models/user_model.dart';
import '../../core/services/supabase_service.dart';
import '../../core/services/supabase_oauth_service.dart';

/// State provider for login/authentication
class LoginProvider with ChangeNotifier {
  UserRole? _currentUserRole;
  User? _currentUser;
  bool _isAuthenticated = false;
  String? _errorMessage;
  bool _isLoading = false;
  Map<String, String>? _googleSignUpData; // Holds OAuth data before account creation

  // Getters
  UserRole? get currentUserRole => _currentUserRole;
  User? get currentUser => _currentUser;
  String? get currentUserId => _currentUser?.id;
  bool get isAuthenticated => _isAuthenticated;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _isLoading;
  Map<String, String>? get googleSignUpData => _googleSignUpData;

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

  /// Start Google sign-up flow using Supabase OAuth
  Future<void> startGoogleSignUpFlow() async {
    print('📱 [LoginProvider] startGoogleSignUpFlow started');
    _isLoading = true;
    _errorMessage = null;
    _googleSignUpData = null;
    notifyListeners();

    try {
      // Initiate OAuth sign-in (this will redirect to Google then back to your app)
      final success = await SupabaseOAuthService.signInWithGoogle();
      
      if (!success) {
        _errorMessage = 'Failed to initiate Google Sign-In';
        _isLoading = false;
        notifyListeners();
        return;
      }

      print('✅ [LoginProvider] OAuth initiated, waiting for session...');
      
      // Wait longer for the OAuth session to be established after redirect
      for (int i = 0; i < 15; i++) {
        await Future.delayed(Duration(milliseconds: 500));
        
        final authUser = SupabaseService.client.auth.currentUser;
        if (authUser != null) {
          print('✅ [LoginProvider] User authenticated after ${i * 500}ms: ${authUser.email}');
          
          // Check if user exists in database
          final existingUser = await SupabaseOAuthService.getUserFromDatabase(authUser.id);
          
          if (existingUser != null) {
            // User already exists, proceed to authenticated state
            print('📱 [LoginProvider] User already exists in database');
            _currentUserRole = UserRole.values.firstWhere(
              (r) => r.toString().split('.').last == existingUser['role'],
              orElse: () => UserRole.student,
            );
            _currentUser = User(
              id: authUser.id,
              email: authUser.email ?? '',
              name: existingUser['full_name'] ?? 'User',
              role: _currentUserRole!,
              profilePictureUrl: existingUser['profile_picture_url'],
              createdAt: DateTime.now(),
            );
            _isAuthenticated = true;
          } else {
            // User doesn't exist yet - need to collect username and role
            print('📱 [LoginProvider] New user, storing data for credentials entry');
            _googleSignUpData = {
              'id': authUser.id,
              'email': authUser.email ?? '',
              'display_name': authUser.userMetadata?['full_name'] ?? 'User',
              'photo_url': authUser.userMetadata?['avatar_url'] ?? '',
            };
          }

          _errorMessage = null;
          _isLoading = false;
          notifyListeners();
          return;
        }
      }
      
      // If we get here, no session was found after retries
      _errorMessage = 'Failed to establish session. Please try again.';
      print('❌ [LoginProvider] No session found after retries');
      
    } catch (e) {
      _errorMessage = 'Google Sign-In failed: $e';
      print('❌ [LoginProvider] startGoogleSignUpFlow error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Complete Google sign-up by creating account with username and password
  Future<void> signUpWithGoogle({
    required String userId,
    required String googleEmail,
    required String username,
    required String password,
    required UserRole role,
  }) async {
    print('📱 [LoginProvider] signUpWithGoogle started - Username: $username, Role: $role');
    
    if (role == UserRole.admin) {
      _errorMessage = 'Admin accounts must be created by administrators';
      print('❌ [LoginProvider] signUpWithGoogle error: Admin signup not allowed');
      notifyListeners();
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final authUser = SupabaseService.client.auth.currentUser;
      if (authUser == null || authUser.id != userId) {
        throw Exception('User authentication mismatch. Please try signing up again.');
      }

      print('📱 [LoginProvider] Found authenticated user: ${authUser.id}');

      // Get Firebase user info from metadata
      final displayName = authUser.userMetadata?['full_name'] ?? username;
      final photoUrl = authUser.userMetadata?['avatar_url'];

      // Set password for the user
      try {
        await SupabaseService.client.auth.updateUser(
          UserAttributes(password: password),
        );
        print('✅ [LoginProvider] Password set for user');
      } catch (e) {
        print('⚠️  [LoginProvider] Password update warning: $e');
      }

      // Create user record in database
      try {
        await SupabaseOAuthService.createUserInDatabase(
          userId: userId,
          email: googleEmail,
          username: username,
          role: role.toString().split('.').last,
          displayName: displayName,
          photoUrl: photoUrl,
        );
      } catch (e) {
        print('⚠️  [LoginProvider] User already exists or creation failed: $e');
      }

      // Set user data
      _currentUserRole = role;
      _currentUser = User(
        id: userId,
        email: googleEmail,
        name: username,
        role: role,
        profilePictureUrl: photoUrl,
        createdAt: DateTime.now(),
      );
      _isAuthenticated = true;
      _errorMessage = null;
      _googleSignUpData = null;
      print('✅ [LoginProvider] signUpWithGoogle success!');
    } catch (e) {
      _errorMessage = e.toString();
      _isAuthenticated = false;
      _googleSignUpData = null;
      print('❌ [LoginProvider] signUpWithGoogle error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Sign up with email directly (from email signup screen)
  Future<void> signUpWithEmailDirect({
    required String email,
    required String username,
    required String password,
    required UserRole role,
  }) async {
    print('📱 [LoginProvider] signUpWithEmailDirect started - Email: $email, Username: $username, Role: $role');
    
    // Prevent admin signup through this method
    if (role == UserRole.admin) {
      _errorMessage = 'Admin accounts must be created by administrators';
      print('❌ [LoginProvider] signUpWithEmailDirect error: Admin signup not allowed');
      notifyListeners();
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Sign up user with Supabase Auth
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
        print('✅ [LoginProvider] signUpWithEmailDirect success!');
      }
    } catch (e) {
      _errorMessage = e.toString();
      _isAuthenticated = false;
      print('❌ [LoginProvider] signUpWithEmailDirect error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Login with Google using Supabase OAuth
  Future<void> loginWithGoogle(UserRole role) async {
    print('📱 [LoginProvider] loginWithGoogle started - Role: $role');
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Initiate Supabase OAuth sign-in
      final success = await SupabaseOAuthService.signInWithGoogle();
      
      if (!success) {
        _errorMessage = 'Failed to initiate Google Sign-In';
        _isLoading = false;
        notifyListeners();
        return;
      }

      print('✅ [LoginProvider] OAuth initiated, waiting for session...');
      
      // Wait for OAuth session to be established after redirect
      for (int i = 0; i < 15; i++) {
        await Future.delayed(Duration(milliseconds: 500));

        final authUser = SupabaseService.client.auth.currentUser;
        if (authUser != null) {
          print('✅ [LoginProvider] User authenticated after ${i * 500}ms: ${authUser.email}');

          // Check if user exists in database
          try {
            final userRecord = await SupabaseOAuthService.getUserFromDatabase(authUser.id);
            
            if (userRecord != null) {
              print('📱 [LoginProvider] User found in database');
              _currentUserRole = UserRole.values.firstWhere(
                (r) => r.toString().split('.').last == userRecord['role'],
                orElse: () => role,
              );
              
              _currentUser = User(
                id: authUser.id,
                email: authUser.email ?? '',
                name: userRecord['full_name'] ?? 'User',
                role: _currentUserRole!,
                profilePictureUrl: userRecord['profile_picture_url'],
                createdAt: DateTime.now(),
              );
            } else {
              print('⚠️  [LoginProvider] User not in database');
              _currentUserRole = role;
              _currentUser = User(
                id: authUser.id,
                email: authUser.email ?? '',
                name: authUser.userMetadata?['full_name'] ?? 'User',
                role: role,
                profilePictureUrl: authUser.userMetadata?['avatar_url'],
                createdAt: DateTime.now(),
              );
            }
          } catch (e) {
            print('⚠️  [LoginProvider] Error fetching user: $e');
            _currentUserRole = role;
            _currentUser = User(
              id: authUser.id,
              email: authUser.email ?? '',
              name: authUser.userMetadata?['full_name'] ?? 'User',
              role: role,
              profilePictureUrl: authUser.userMetadata?['avatar_url'],
              createdAt: DateTime.now(),
            );
          }

          _isAuthenticated = true;
          _errorMessage = null;
          _isLoading = false;
          notifyListeners();
          print('✅ [LoginProvider] Google login success!');
          return;
        }
      }
      
      // If we get here, no session was found after retries
      _errorMessage = 'Failed to establish session. Please try again.';
      print('❌ [LoginProvider] No session found after retries');
      _isLoading = false;
      notifyListeners();
      
    } catch (e) {
      String errorMsg = e.toString();
      _errorMessage = 'Google login failed: $errorMsg';
      _isAuthenticated = false;
      print('❌ [LoginProvider] Google login error: $e');
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> initializeFromExistingSession() async {
    print('📱 [LoginProvider] Initializing from existing session');
    
    final authUser = SupabaseService.client.auth.currentUser;
    if (authUser == null) {
      print('⚠️  [LoginProvider] No existing session found');
      return;
    }

    try {
      final userRecord = await SupabaseService.client
          .from('users')
          .select()
          .eq('id', authUser.id)
          .maybeSingle();
      
      if (userRecord != null) {
        print('✅ [LoginProvider] User found in database');
        
        final role = UserRole.values.firstWhere(
          (r) => r.toString().split('.').last == userRecord['role'],
          orElse: () => UserRole.student,
        );
        
        _currentUserRole = role;
        _currentUser = User(
          id: authUser.id,
          email: authUser.email ?? '',
          name: userRecord['full_name'] ?? 'User',
          role: role,
          profilePictureUrl: userRecord['profile_picture_url'],
          createdAt: DateTime.now(),
        );
        _isAuthenticated = true;
        _errorMessage = null;
        notifyListeners();
      } else {
        print('⚠️  [LoginProvider] User authenticated but not in database');
        // User is authenticated but no record yet - store for credentials entry
        _googleSignUpData = {
          'id': authUser.id,
          'email': authUser.email ?? '',
          'display_name': authUser.userMetadata?['full_name'] ?? 'User',
          'photo_url': authUser.userMetadata?['avatar_url'] ?? '',
        };
        notifyListeners();
      }
    } catch (e) {
      print('❌ [LoginProvider] Error initializing from session: $e');
      _errorMessage = e.toString();
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
