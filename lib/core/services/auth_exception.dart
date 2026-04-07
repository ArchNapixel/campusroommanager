/// Custom exception for authentication and signup-related errors with detailed messages
class AppAuthException implements Exception {
  final String code;
  final String userMessage;
  final String? technicalDetails;
  final dynamic originalError;

  AppAuthException({
    required this.code,
    required this.userMessage,
    this.technicalDetails,
    this.originalError,
  });

  /// Parse common Supabase auth errors and provide user-friendly messages
  factory AppAuthException.fromError(dynamic error) {
    final errorStr = error.toString().toLowerCase();
    
    // Network errors
    if (errorStr.contains('network') || errorStr.contains('timeout') || errorStr.contains('connection')) {
      return AppAuthException(
        code: 'NETWORK_ERROR',
        userMessage: 'Network connection failed. Please check your internet and try again.',
        technicalDetails: error.toString(),
        originalError: error,
      );
    }
    
    // Duplicate username errors
    if (errorStr.contains('duplicate') && errorStr.contains('username')) {
      return AppAuthException(
        code: 'DUPLICATE_USERNAME',
        userMessage: 'This username is already taken. Please choose a different username.',
        technicalDetails: error.toString(),
        originalError: error,
      );
    }
    
    // Duplicate email errors
    if (errorStr.contains('duplicate') || errorStr.contains('already exists') || errorStr.contains('duplicate key')) {
      return AppAuthException(
        code: 'DUPLICATE_EMAIL',
        userMessage: 'An account with this email already exists. Please use a different email or log in.',
        technicalDetails: error.toString(),
        originalError: error,
      );
    }
    
    // Invalid email format
    if (errorStr.contains('invalid email')) {
      return AppAuthException(
        code: 'INVALID_EMAIL',
        userMessage: 'Please enter a valid email address.',
        technicalDetails: error.toString(),
        originalError: error,
      );
    }
    
    // Weak password
    if (errorStr.contains('password') && (errorStr.contains('weak') || errorStr.contains('short') || errorStr.contains('too short'))) {
      return AppAuthException(
        code: 'WEAK_PASSWORD',
        userMessage: 'Password must be at least 6 characters long. Please choose a stronger password.',
        technicalDetails: error.toString(),
        originalError: error,
      );
    }
    
    // Email not confirmed
    if (errorStr.contains('email_not_confirmed') || errorStr.contains('email not confirmed')) {
      return AppAuthException(
        code: 'EMAIL_NOT_CONFIRMED',
        userMessage: 'Email not confirmed. Please check your email for a confirmation link.',
        technicalDetails: error.toString(),
        originalError: error,
      );
    }
    
    // Invalid login credentials
    if (errorStr.contains('invalid login credentials') || errorStr.contains('invalid_grant')) {
      return AppAuthException(
        code: 'INVALID_CREDENTIALS',
        userMessage: 'Invalid email or password. Please check and try again.',
        technicalDetails: error.toString(),
        originalError: error,
      );
    }
    
    // User already exists
    if (errorStr.contains('user already exists')) {
      return AppAuthException(
        code: 'USER_EXISTS',
        userMessage: 'An account with this email already exists. Please log in or use a different email.',
        technicalDetails: error.toString(),
        originalError: error,
      );
    }
    
    // Admin account not found
    if (errorStr.contains('admin') && errorStr.contains('not found')) {
      return AppAuthException(
        code: 'ADMIN_NOT_FOUND',
        userMessage: 'Admin account not found. Please check your username.',
        technicalDetails: error.toString(),
        originalError: error,
      );
    }
    
    // Invalid admin credentials
    if (errorStr.contains('admin') && errorStr.contains('password')) {
      return AppAuthException(
        code: 'INVALID_ADMIN_PASSWORD',
        userMessage: 'Invalid admin password. Please try again.',
        technicalDetails: error.toString(),
        originalError: error,
      );
    }
    
    // Google sign-in errors
    if (errorStr.contains('google') && errorStr.contains('cancelled')) {
      return AppAuthException(
        code: 'GOOGLE_CANCELLED',
        userMessage: 'Google Sign-In was cancelled. Please try again.',
        technicalDetails: error.toString(),
        originalError: error,
      );
    }
    
    if (errorStr.contains('google')) {
      return AppAuthException(
        code: 'GOOGLE_ERROR',
        userMessage: 'Google Sign-In failed. Please try again.',
        technicalDetails: error.toString(),
        originalError: error,
      );
    }
    
    // Generic auth error
    return AppAuthException(
      code: 'AUTH_ERROR',
      userMessage: 'An authentication error occurred. Please try again.',
      technicalDetails: error.toString(),
      originalError: error,
    );
  }

  @override
  String toString() => 'AppAuthException($code): $userMessage';
}
