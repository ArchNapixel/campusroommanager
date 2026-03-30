import 'package:supabase_flutter/supabase_flutter.dart';
import 'supabase_service.dart';

/// Service to handle Supabase OAuth (Google Sign-In)
class SupabaseOAuthService {
  /// Sign in with Google using Supabase OAuth
  static Future<bool> signInWithGoogle() async {
    try {
      print('🔐 [SupabaseOAuthService] Starting Google Sign-In via OAuth');
      
      // Redirect to Supabase callback URL (this is the official way for web apps)
      await SupabaseService.client.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: 'https://ejyvbgkqplymqscwifnh.supabase.co/auth/v1/callback',
      );
      
      print('✅ [SupabaseOAuthService] OAuth redirect initiated');
      return true;
    } catch (e) {
      print('❌ [SupabaseOAuthService] Google Sign-In failed: $e');
      return false;
    }
  }

  /// Get current authenticated user from Supabase
  static User? getCurrentUser() {
    return SupabaseService.client.auth.currentUser;
  }

  /// Check if user is authenticated
  static bool isAuthenticated() {
    return SupabaseService.client.auth.currentUser != null;
  }

  /// Sign out from Supabase
  static Future<void> signOut() async {
    try {
      await SupabaseService.client.auth.signOut();
      print('✅ [SupabaseOAuthService] Signed out');
    } catch (e) {
      print('❌ [SupabaseOAuthService] Sign out failed: $e');
      rethrow;
    }
  }

  /// Create or update user in database after OAuth signup
  static Future<void> createUserInDatabase({
    required String userId,
    required String email,
    required String username,
    required String role,
    String? displayName,
    String? photoUrl,
  }) async {
    try {
      print('📱 [SupabaseOAuthService] Creating user in database');
      
      await SupabaseService.client.from('users').insert({
        'id': userId,
        'email': email,
        'username': username,
        'full_name': displayName ?? username,
        'role': role,
        'profile_picture_url': photoUrl,
      });
      
      print('✅ [SupabaseOAuthService] User created in database');
    } catch (e) {
      print('❌ [SupabaseOAuthService] Failed to create user: $e');
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
