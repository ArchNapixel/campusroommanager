import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart';
import 'supabase_service.dart';

/// Service to handle Supabase OAuth (Google Sign-In)
class SupabaseOAuthService {
  static GoogleSignIn? _googleSignIn;
  static bool _initialized = false;
  static GoogleSignInAccount? _currentGoogleUser;

  /// Initialize GoogleSignIn only once
  static GoogleSignIn _getGoogleSignIn() {
    if (!_initialized) {
      _googleSignIn = GoogleSignIn(
        scopes: [
          'email',
          'profile',
        ],
        // serverClientId is not supported on web
      );
      _initialized = true;
    }
    return _googleSignIn!;
  }

  /// Sign in with Google using in-app popup modal
  /// Returns true if successful, false otherwise
  /// For web: Returns user info without authenticating with Supabase
  /// Users should then call signUpWithGoogle to complete the signup
  static Future<bool> signInWithGoogle() async {
    try {
      print('🔐 [SupabaseOAuthService] Starting Google Sign-In via popup');
      
      // Trigger Google Sign-In (shows popup/modal)
      final googleUser = await _getGoogleSignIn().signIn();
      
      if (googleUser == null) {
        print('⚠️  [SupabaseOAuthService] Google Sign-In cancelled by user');
        return false;
      }
      
      print('✅ [SupabaseOAuthService] Google Sign-In successful: ${googleUser.email}');
      _currentGoogleUser = googleUser;
      
      // On web, we can't get an ID token from Google Sign-In
      // So we'll store the user info and complete signup in the next step
      if (kIsWeb) {
        print('📱 [SupabaseOAuthService] On web: returning user info for signup completion');
        return true;
      }
      
      // On mobile, try to authenticate with Supabase using ID token
      final googleAuth = await googleUser.authentication;
      final accessToken = googleAuth.accessToken;
      final idToken = googleAuth.idToken;
      
      if (idToken == null) {
        throw Exception('Failed to get ID token from Google');
      }
      
      print('📱 [SupabaseOAuthService] Exchanging Google token with Supabase');
      
      final response = await SupabaseService.client.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
        accessToken: accessToken,
      );
      
      if (response.user != null) {
        print('✅ [SupabaseOAuthService] Successfully authenticated with Supabase');
        return true;
      } else {
        print('❌ [SupabaseOAuthService] Failed to authenticate with Supabase');
        return false;
      }
    } catch (e) {
      print('❌ [SupabaseOAuthService] Google Sign-In failed: $e');
      rethrow;
    }
  }

  /// Complete Google signup with username and password
  /// This creates the user in Supabase and the database
  static Future<bool> signUpWithGoogle({
    required String email,
    required String password,
    required String username,
    required String role,
    String? displayName,
    String? photoUrl,
  }) async {
    try {
      print('📱 [SupabaseOAuthService] Completing Google signup with username and password');
      
      if (_currentGoogleUser == null) {
        throw Exception('No Google user found. Please sign in again.');
      }
      
      // Sign up with Supabase using email and password
      final response = await SupabaseService.signUp(
        email: email,
        password: password,
      );
      
      if (response.user == null) {
        throw Exception('Failed to sign up user');
      }
      
      print('✅ [SupabaseOAuthService] User created in Supabase');
      
      // Create user in database
      int retries = 0;
      const maxRetries = 3;
      bool success = false;
      
      while (!success && retries < maxRetries) {
        try {
          await SupabaseService.client.from('users').insert({
            'id': response.user!.id,
            'email': email,
            'username': username,
            'full_name': displayName ?? username,
            'role': role,
            'profile_picture_url': photoUrl,
          });
          success = true;
          print('✅ [SupabaseOAuthService] User created in database on attempt ${retries + 1}');
        } catch (e) {
          retries++;
          if (retries < maxRetries) {
            await Future.delayed(Duration(milliseconds: 100 * retries));
            print('🔄 [SupabaseOAuthService] Retrying user insert (attempt ${retries + 1}/$maxRetries)');
          } else {
            rethrow;
          }
        }
      }
      
      // Clear the stored Google user
      _currentGoogleUser = null;
      
      print('✅ [SupabaseOAuthService] Google signup completed successfully');
      return true;
    } catch (e) {
      print('❌ [SupabaseOAuthService] Google signup failed: $e');
      rethrow;
    }
  }

  /// Get stored Google user info (for web popup flow)
  static Map<String, String>? getGoogleUserInfo() {
    if (_currentGoogleUser == null) return null;
    
    return {
      'email': _currentGoogleUser!.email,
      'display_name': _currentGoogleUser!.displayName ?? _currentGoogleUser!.email,
      'photo_url': _currentGoogleUser!.photoUrl ?? '',
    };
  }

  /// Get current authenticated user from Supabase
  static User? getCurrentUser() {
    return SupabaseService.client.auth.currentUser;
  }

  /// Check if user is authenticated
  static bool isAuthenticated() {
    return SupabaseService.client.auth.currentUser != null;
  }

  /// Sign out from Supabase and Google
  static Future<void> signOut() async {
    try {
      // Sign out from Supabase
      await SupabaseService.client.auth.signOut();
      
      // Sign out from Google
      await _getGoogleSignIn().signOut();
      
      // Clear the stored Google user
      _currentGoogleUser = null;
      
      print('✅ [SupabaseOAuthService] Signed out from both Supabase and Google');
    } catch (e) {
      print('❌ [SupabaseOAuthService] Sign out failed: $e');
      rethrow;
    }
  }

  /// Get user from database
  static Future<Map<String, dynamic>?> getUserFromDatabase(String userId) async {
    try {
      final response = await SupabaseService.client
          .from('users')
          .select()
          .eq('id', userId)
          .maybeSingle();
      
      return response;
    } catch (e) {
      print('❌ [SupabaseOAuthService] Failed to get user: $e');
      return null;
    }
  }
}
