

/// Helper class for diagnosing and logging booking errors
class BookingDiagnostics {
  const BookingDiagnostics._();

  /// Get a detailed error report for debugging
  static String generateErrorReport({
    required String userRole,
    required String? userId,
    required String? errorMessage,
    required String roomId,
    required DateTime startTime,
    required DateTime endTime,
    required String purpose,
  }) {
    final buffer = StringBuffer();
    buffer.writeln('═══════════════════════════════════════════════');
    buffer.writeln('BOOKING ERROR DIAGNOSTIC REPORT');
    buffer.writeln('═══════════════════════════════════════════════');
    buffer.writeln('');
    
    buffer.writeln('USER INFORMATION:');
    buffer.writeln('  Role: $userRole');
    buffer.writeln('  User ID: ${userId ?? 'NOT SET (CRITICAL)'}');
    if (userId == null || userId.isEmpty || userId == 'current_user') {
      buffer.writeln('  ⚠️  ERROR: Invalid User ID! This is likely the cause of the booking failure.');
    }
    buffer.writeln('');

    buffer.writeln('BOOKING DETAILS:');
    buffer.writeln('  Room ID: $roomId');
    buffer.writeln('  Start Time: ${startTime.toString()}');
    buffer.writeln('  End Time: ${endTime.toString()}');
    buffer.writeln('  Duration: ${endTime.difference(startTime).inMinutes} minutes');
    buffer.writeln('  Purpose: "$purpose"');
    buffer.writeln('');

    buffer.writeln('VALIDATION CHECKS:');
    
    // Check time validity
    if (startTime.isAfter(endTime)) {
      buffer.writeln('  ❌ Start time is AFTER end time');
    } else {
      buffer.writeln('  ✅ Start time is before end time');
    }
    
    // Check if in past
    if (startTime.isBefore(DateTime.now())) {
      buffer.writeln('  ❌ Start time is in the PAST');
    } else {
      buffer.writeln('  ✅ Start time is in the future');
    }
    
    // Check duration
    final duration = endTime.difference(startTime);
    if (duration.inMinutes < 30) {
      buffer.writeln('  ❌ Duration too short (${duration.inMinutes} min, need 30+ min)');
    } else if (duration.inHours > 8) {
      buffer.writeln('  ❌ Duration too long (${duration.inHours} hours, max 8 hours)');
    } else {
      buffer.writeln('  ✅ Duration is valid (${duration.inMinutes} minutes)');
    }
    
    // Check purpose
    if (purpose.isEmpty) {
      buffer.writeln('  ❌ Purpose is EMPTY');
    } else if (purpose.length > 500) {
      buffer.writeln('  ❌ Purpose too long (${purpose.length} chars, max 500)');
    } else {
      buffer.writeln('  ✅ Purpose is valid (${purpose.length} chars)');
    }
    buffer.writeln('');

    if (errorMessage != null && errorMessage.isNotEmpty) {
      buffer.writeln('ERROR MESSAGE:');
      buffer.writeln('  $errorMessage');
      buffer.writeln('');
    }

    buffer.writeln('TROUBLESHOOTING STEPS:');
    if (userId == null || userId.isEmpty || userId == 'current_user') {
      buffer.writeln('  1. LOG OUT and LOG IN again');
      buffer.writeln('  2. Verify your credentials are correct');
      buffer.writeln('  3. Check your internet connection');
    } else if (errorMessage?.contains('permission') ?? false) {
      buffer.writeln('  1. Contact your administrator to verify booking permissions');
      buffer.writeln('  2. Try with a different room');
      buffer.writeln('  3. Check if your account is active');
    } else if (errorMessage?.contains('network') ?? false) {
      buffer.writeln('  1. Check your internet connection');
      buffer.writeln('  2. Try again in a few moments');
      buffer.writeln('  3. If problem persists, contact support');
    } else if (errorMessage?.contains('not available') ?? false) {
      buffer.writeln('  1. Select a different time slot');
      buffer.writeln('  2. Try booking on a different date');
      buffer.writeln('  3. Contact the room administrator');
    } else {
      buffer.writeln('  1. Review the error message above');
      buffer.writeln('  2. Verify all booking details');
      buffer.writeln('  3. Contact support if problem persists');
    }
    buffer.writeln('');

    buffer.writeln('═══════════════════════════════════════════════');
    return buffer.toString();
  }

  /// Print error report to console for development
  static void printReport({
    required String userRole,
    required String? userId,
    required String? errorMessage,
    required String roomId,
    required DateTime startTime,
    required DateTime endTime,
    required String purpose,
  }) {
    final report = generateErrorReport(
      userRole: userRole,
      userId: userId,
      errorMessage: errorMessage,
      roomId: roomId,
      startTime: startTime,
      endTime: endTime,
      purpose: purpose,
    );
    print(report);
  }

  /// Get a user-friendly summary of the error
  static String getErrorSummary(String? errorMessage) {
    if (errorMessage == null || errorMessage.isEmpty) {
      return 'An unknown error occurred. Please try again.';
    }

    final msg = errorMessage.toLowerCase();

    if (msg.contains('user') && msg.contains('invalid')) {
      return 'Your session is invalid. Please log in again.';
    }
    if (msg.contains('permission')) {
      return 'You don\'t have permission to book this room. Contact your administrator.';
    }
    if (msg.contains('network') || msg.contains('connection')) {
      return 'Network error. Please check your internet connection.';
    }
    if (msg.contains('not available')) {
      return 'The selected time slot is not available.';
    }
    if (msg.contains('duration') || msg.contains('30 minutes') || msg.contains('8 hours')) {
      return 'Invalid booking duration. Must be between 30 minutes and 8 hours.';
    }
    if (msg.contains('past')) {
      return 'Cannot book a time that has already passed.';
    }
    if (msg.contains('daily limit') || msg.contains('maximum 5')) {
      return 'You have reached your maximum bookings for today.';
    }
    if (msg.contains('server') || msg.contains('database')) {
      return 'Server error. Please try again later.';
    }

    return errorMessage;
  }
}
