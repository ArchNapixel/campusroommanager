import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/supabase_config.dart';

/// Service to manage Supabase initialization and provide easy access
/// to the Supabase client throughout the app
class SupabaseService {
  static SupabaseService? _instance;

  SupabaseService._();

  factory SupabaseService() {
    _instance ??= SupabaseService._();
    return _instance!;
  }

  /// Initialize Supabase
  /// Should be called in main() before runApp()
  static Future<void> initialize() async {
    await Supabase.initialize(
      url: SupabaseConfig.projectUrl,
      anonKey: SupabaseConfig.anonKey,
    );
  }

  /// Get the Supabase client
  static SupabaseClient get client => Supabase.instance.client;

  /// Get the current user
  static User? get currentUser => client.auth.currentUser;

  /// Sign up with email and password
  static Future<AuthResponse> signUp({
    required String email,
    required String password,
  }) async {
    try {
      print('🔐 [Supabase] Starting signup for: $email');
      final response = await client.auth.signUp(
        email: email,
        password: password,
      );
      print('✅ [Supabase] Signup successful for: $email');
      return response;
    } catch (e) {
      print('❌ [Supabase] Signup failed: $e');
      rethrow;
    }
  }

  /// Sign in with email and password
  static Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    try {
      print('🔐 [Supabase] Starting signin for: $email');
      final response = await client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      print('✅ [Supabase] Signin successful for: $email');
      return response;
    } catch (e) {
      print('❌ [Supabase] Signin failed: $e');
      rethrow;
    }
  }

  /// Sign out
  static Future<void> signOut() async {
    try {
      await client.auth.signOut();
    } catch (e) {
      rethrow;
    }
  }

  /// Check if user is authenticated
  static bool get isAuthenticated => currentUser != null;
}
