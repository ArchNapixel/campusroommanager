/// Custom exception for booking-related errors with detailed messages
class BookingException implements Exception {
  final String code;
  final String userMessage;
  final String? technicalDetails;
  final dynamic originalError;

  BookingException({
    required this.code,
    required this.userMessage,
    this.technicalDetails,
    this.originalError,
  });

  /// Parse common Supabase errors and provide user-friendly messages
  factory BookingException.fromError(dynamic error) {
    final errorStr = error.toString().toLowerCase();
    
    // Network errors
    if (errorStr.contains('network') || errorStr.contains('timeout') || errorStr.contains('connection')) {
      return BookingException(
        code: 'NETWORK_ERROR',
        userMessage: 'Network connection failed. Please check your internet and try again.',
        technicalDetails: error.toString(),
        originalError: error,
      );
    }
    
    // Authentication errors
    if (errorStr.contains('unauthorized') || errorStr.contains('unauthenticated')) {
      return BookingException(
        code: 'AUTH_ERROR',
        userMessage: 'Your session has expired. Please log in again.',
        technicalDetails: error.toString(),
        originalError: error,
      );
    }
    
    // Permission errors
    if (errorStr.contains('permission') || errorStr.contains('denied') || errorStr.contains('forbidden')) {
      return BookingException(
        code: 'PERMISSION_ERROR',
        userMessage: 'You do not have permission to book this room. Contact your administrator.',
        technicalDetails: error.toString(),
        originalError: error,
      );
    }
    
    // Room not found
    if (errorStr.contains('room') && errorStr.contains('not found')) {
      return BookingException(
        code: 'ROOM_NOT_FOUND',
        userMessage: 'The selected room no longer exists. Please select another room.',
        technicalDetails: error.toString(),
        originalError: error,
      );
    }
    
    // User not found
    if (errorStr.contains('user') && errorStr.contains('not found')) {
      return BookingException(
        code: 'USER_NOT_FOUND',
        userMessage: 'User profile not found. Please log in again.',
        technicalDetails: error.toString(),
        originalError: error,
      );
    }
    
    // Database constraints
    if (errorStr.contains('unique')) {
      return BookingException(
        code: 'DUPLICATE_BOOKING',
        userMessage: 'A booking for this room at this time already exists.',
        technicalDetails: error.toString(),
        originalError: error,
      );
    }
    
    if (errorStr.contains('foreign key')) {
      return BookingException(
        code: 'INVALID_DATA',
        userMessage: 'Invalid room or user data. Please try again.',
        technicalDetails: error.toString(),
        originalError: error,
      );
    }
    
    if (errorStr.contains('check constraint')) {
      return BookingException(
        code: 'INVALID_BOOKING_TIME',
        userMessage: 'The booking time is invalid. Please check the start and end times.',
        technicalDetails: error.toString(),
        originalError: error,
      );
    }
    
    // Schema mismatch errors
    if (errorStr.contains('could not find') && errorStr.contains('column')) {
      return BookingException(
        code: 'SCHEMA_MISMATCH',
        userMessage: 'Database schema mismatch. Please contact support.',
        technicalDetails: error.toString(),
        originalError: error,
      );
    }
    
    // Database errors
    if (errorStr.contains('database') || errorStr.contains('internal server error')) {
      return BookingException(
        code: 'DATABASE_ERROR',
        userMessage: 'Database error occurred. Please try again later.',
        technicalDetails: error.toString(),
        originalError: error,
      );
    }
    
    // Server errors
    if (errorStr.contains('500') || errorStr.contains('502') || errorStr.contains('503')) {
      return BookingException(
        code: 'SERVER_ERROR',
        userMessage: 'Server error. Please try again later.',
        technicalDetails: error.toString(),
        originalError: error,
      );
    }
    
    // Default
    return BookingException(
      code: 'UNKNOWN_ERROR',
      userMessage: 'An unexpected error occurred. Please try again.',
      technicalDetails: error.toString(),
      originalError: error,
    );
  }

  @override
  String toString() => userMessage;

  String get fullDetails {
    final buffer = StringBuffer();
    buffer.writeln('Error Code: $code');
    buffer.writeln('Message: $userMessage');
    if (technicalDetails != null) {
      buffer.writeln('Details: $technicalDetails');
    }
    return buffer.toString();
  }
}
