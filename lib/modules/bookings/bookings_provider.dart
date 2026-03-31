import 'package:flutter/material.dart';
import '../../core/services/database_service.dart';
import '../../core/services/booking_exception.dart';
import '../../core/models/booking_model.dart';

/// Provider for managing bookings
class BookingsProvider with ChangeNotifier {
  List<Map<String, dynamic>> _userBookings = [];
  List<Map<String, dynamic>> _allBookings = [];
  String? _errorMessage;
  bool _isLoading = false;

  // Getters
  List<Map<String, dynamic>> get userBookings => _userBookings;
  List<Map<String, dynamic>> get allBookings => _allBookings;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _isLoading;

  /// Convert Maps to Booking models
  List<Booking> get userBookingsAsModels =>
      _userBookings.map((b) => _mapToBooking(b)).toList();
  List<Booking> get allBookingsAsModels =>
      _allBookings.map((b) => _mapToBooking(b)).toList();

  /// Helper to convert Map to Booking model
  Booking _mapToBooking(Map<String, dynamic> data) {
    BookingStatus statusFromString(String status) {
      switch (status.toLowerCase()) {
        case 'pending':
          return BookingStatus.pending;
        case 'confirmed':
          return BookingStatus.confirmed;
        case 'in_progress':
          return BookingStatus.inProgress;
        case 'completed':
          return BookingStatus.completed;
        case 'cancelled':
          return BookingStatus.cancelled;
        default:
          return BookingStatus.confirmed;
      }
    }

    return Booking(
      id: data['id'] ?? '',
      roomId: data['room_id'] ?? '',
      userId: data['user_id'] ?? '',
      startTime: DateTime.parse(data['start_time'] ?? DateTime.now().toIso8601String()),
      endTime: DateTime.parse(data['end_time'] ?? DateTime.now().toIso8601String()),
      title: data['title'] ?? '',
      description: data['description'],
      status: statusFromString(data['status'] ?? 'confirmed'),
      expectedOccupants: 1,
      createdAt: DateTime.parse(data['created_at'] ?? DateTime.now().toIso8601String()),
      updatedAt: data['updated_at'] != null ? DateTime.parse(data['updated_at']) : null,
    );
  }

  /// Load user's bookings
  Future<void> loadUserBookings(String userId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _userBookings = await DatabaseService.getUserBookings(userId);
      print('✅ [BookingsProvider] Loaded ${_userBookings.length} user bookings');
    } catch (e) {
      _errorMessage = e.toString();
      print('❌ [BookingsProvider] Error loading user bookings: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Load all bookings (admin)
  Future<void> loadAllBookings() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _allBookings = await DatabaseService.getAllBookings();
      print('✅ [BookingsProvider] Loaded ${_allBookings.length} bookings');
    } catch (e) {
      _errorMessage = e.toString();
      print('❌ [BookingsProvider] Error loading all bookings: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Create booking with comprehensive error handling and validation
  Future<bool> createBooking({
    required String roomId,
    required String userId,
    required DateTime startTime,
    required DateTime endTime,
    String? purpose,
  }) async {
    _errorMessage = null;
    _isLoading = true;
    notifyListeners();

    try {
      print('📱 [BookingsProvider] Creating booking');
      print('   Room: $roomId | User: $userId');
      print('   Start: ${startTime.toString()} | End: ${endTime.toString()}');

      // ============ CRITICAL VALIDATION ============
      
      // 1. Validate IDs
      if (roomId.isEmpty) {
        throw BookingException(
          code: 'INVALID_ROOM',
          userMessage: 'Please select a room before booking.',
          technicalDetails: 'Room ID is empty',
        );
      }
      
      if (userId.isEmpty || userId == 'current_user') {
        throw BookingException(
          code: 'INVALID_USER',
          userMessage: 'User information is missing. Please log in again.',
          technicalDetails: 'User ID is empty or placeholder: $userId',
        );
      }

      // 2. Validate time range
      if (startTime.isAfter(endTime)) {
        throw BookingException(
          code: 'INVALID_TIME_RANGE',
          userMessage: 'Start time must be before end time.',
          technicalDetails: 'Start: $startTime, End: $endTime',
        );
      }

      // 3. Check minimum booking duration
      final duration = endTime.difference(startTime);
      if (duration.inMinutes < 30) {
        throw BookingException(
          code: 'DURATION_TOO_SHORT',
          userMessage: 'Booking must be at least 30 minutes long.',
          technicalDetails: 'Duration: ${duration.inMinutes} minutes',
        );
      }

      // 4. Check maximum booking duration
      if (duration.inHours > 8) {
        throw BookingException(
          code: 'DURATION_TOO_LONG',
          userMessage: 'Booking cannot exceed 8 hours.',
          technicalDetails: 'Duration: ${duration.inHours} hours',
        );
      }

      // 5. Don't allow bookings in the past
      if (startTime.isBefore(DateTime.now())) {
        throw BookingException(
          code: 'BOOKING_IN_PAST',
          userMessage: 'Cannot create bookings in the past.',
          technicalDetails: 'Start time: ${startTime.toString()}',
        );
      }

      // 6. Validate and normalize purpose
      final finalPurpose = (purpose?.trim() ?? '').isNotEmpty 
        ? purpose!.trim() 
        : 'Room reservation';
        
      if (finalPurpose.isEmpty) {
        throw BookingException(
          code: 'INVALID_PURPOSE',
          userMessage: 'Please provide a purpose for the booking.',
          technicalDetails: 'Purpose is empty',
        );
      }

      if (finalPurpose.length > 500) {
        throw BookingException(
          code: 'PURPOSE_TOO_LONG',
          userMessage: 'Booking purpose must be less than 500 characters.',
          technicalDetails: 'Purpose length: ${finalPurpose.length}',
        );
      }



      // ============ CONFLICT DETECTION ============
      
      print('📱 [BookingsProvider] Checking room availability...');
      final available = await DatabaseService.isRoomAvailable(
        roomId,
        startTime,
        endTime,
      );

      if (!available) {
        // Find conflicting booking for detailed message
        final conflicting = _allBookings.firstWhere(
          (b) =>
              b['room_id'] == roomId &&
              b['status'] != 'cancelled' &&
              _timeConflict(
                DateTime.parse(b['start_time']),
                DateTime.parse(b['end_time']),
                startTime,
                endTime,
              ),
          orElse: () => {},
        );

        if (conflicting.isNotEmpty) {
          final s = DateTime.parse(conflicting['start_time']);
          final e = DateTime.parse(conflicting['end_time']);
          final formattedStart = '${s.hour.toString().padLeft(2, '0')}:${s.minute.toString().padLeft(2, '0')}';
          final formattedEnd = '${e.hour.toString().padLeft(2, '0')}:${e.minute.toString().padLeft(2, '0')}';
          throw BookingException(
            code: 'ROOM_NOT_AVAILABLE',
            userMessage: 'Room is already booked from $formattedStart to $formattedEnd.',
            technicalDetails: 'Conflict with booking: ${conflicting['id']}',
          );
        } else {
          throw BookingException(
            code: 'ROOM_NOT_AVAILABLE',
            userMessage: 'Room is not available for the selected time.',
            technicalDetails: 'Time slot unavailable: ${startTime.toString()} - ${endTime.toString()}',
          );
        }
      }

      // ============ USER BOOKING LIMITS ============
      
      print('📱 [BookingsProvider] Checking daily booking limit...');
      final bookingsToday = _userBookings.where((b) {
        final bStart = DateTime.parse(b['start_time']);
        return bStart.year == startTime.year &&
            bStart.month == startTime.month &&
            bStart.day == startTime.day &&
            b['status'] != 'cancelled';
      }).length;

      if (bookingsToday >= 5) {
        throw BookingException(
          code: 'DAILY_LIMIT_EXCEEDED',
          userMessage: 'You have reached the maximum of 5 bookings per day.',
          technicalDetails: 'Bookings today: $bookingsToday',
        );
      }

      // ============ DATABASE CREATION ============
      
      print('📱 [BookingsProvider] Creating booking in database...');
      await DatabaseService.createBooking({
        'room_id': roomId,
        'user_id': userId,
        'start_time': startTime.toIso8601String(),
        'end_time': endTime.toIso8601String(),
        'title': finalPurpose,
        'status': 'confirmed',
      });

      print('✅ [BookingsProvider] Booking created successfully');
      await loadUserBookings(userId);
      
      _isLoading = false;
      notifyListeners();
      return true;
    } on BookingException catch (e) {
      _errorMessage = e.userMessage;
      print('❌ [BookingsProvider] Booking error: ${e.code}');
      print('   Message: ${e.userMessage}');
      if (e.technicalDetails != null) {
        print('   Details: ${e.technicalDetails}');
      }
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      // Catch any other errors and convert to BookingException
      final bookingError = BookingException.fromError(e);
      _errorMessage = bookingError.userMessage;
      print('❌ [BookingsProvider] Unexpected error: ${bookingError.code}');
      print('   Message: ${bookingError.userMessage}');
      print('   Original: $e');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Helper to detect time conflicts
  bool _timeConflict(DateTime s1, DateTime e1, DateTime s2, DateTime e2) {
    return s1.isBefore(e2) && s2.isBefore(e1);
  }

  /// Cancel booking
  /// Enhance cancelBooking with validation and reason tracking
  Future<bool> cancelBooking(
    String bookingId, {
    String reason = 'User cancelled',
  }) async {
    _errorMessage = null;
    _isLoading = true;
    notifyListeners();

    try {
      print('📱 [BookingsProvider] Cancelling booking: $bookingId (Reason: $reason)');

      // ============ VALIDATION ============
      
      // Find booking
      final booking = _userBookings.firstWhere(
        (b) => b['id'] == bookingId,
        orElse: () => {},
      );
      
      if (booking.isEmpty) {
        _errorMessage = 'Booking not found';
        print('❌ [BookingsProvider] Cancellation error: ${_errorMessage}');
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // Check status - can't cancel if already completed or cancelled
      final currentStatus = booking['status'] as String;
      if (currentStatus == 'completed') {
        _errorMessage = 'Cannot cancel completed bookings';
        print('❌ [BookingsProvider] Cancellation error: ${_errorMessage}');
        _isLoading = false;
        notifyListeners();
        return false;
      }
      
      if (currentStatus == 'cancelled') {
        _errorMessage = 'This booking is already cancelled';
        print('❌ [BookingsProvider] Cancellation error: ${_errorMessage}');
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // Check if booking is in past (can't cancel if already started)
      final startTime = DateTime.parse(booking['start_time']);
      if (startTime.isBefore(DateTime.now())) {
        _errorMessage = 'Cannot cancel bookings that have already started';
        print('❌ [BookingsProvider] Cancellation error: ${_errorMessage}');
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // ============ DATABASE UPDATE ============
      
      await DatabaseService.updateBookingStatus(bookingId, 'cancelled');
      
      // Update local lists
      final userIndex = _userBookings.indexWhere((b) => b['id'] == bookingId);
      if (userIndex != -1) {
        _userBookings[userIndex]['status'] = 'cancelled';
        _userBookings[userIndex]['cancellation_reason'] = reason;
        _userBookings[userIndex]['cancelled_at'] = DateTime.now().toIso8601String();
      }
      
      final adminIndex = _allBookings.indexWhere((b) => b['id'] == bookingId);
      if (adminIndex != -1) {
        _allBookings[adminIndex]['status'] = 'cancelled';
        _allBookings[adminIndex]['cancellation_reason'] = reason;
        _allBookings[adminIndex]['cancelled_at'] = DateTime.now().toIso8601String();
      }
      
      print('✅ [BookingsProvider] Booking cancelled successfully');
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to cancel booking: ${e.toString()}';
      print('❌ [BookingsProvider] Error cancelling booking: $e');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Modify existing booking (time and/or purpose)
  Future<bool> modifyBooking({
    required String bookingId,
    DateTime? newStartTime,
    DateTime? newEndTime,
    String? newPurpose,
  }) async {
    _errorMessage = null;
    _isLoading = true;
    notifyListeners();

    try {
      print('📱 [BookingsProvider] Modifying booking: $bookingId');

      // ============ FIND BOOKING ============
      
      final booking = _userBookings.firstWhere(
        (b) => b['id'] == bookingId,
        orElse: () => {},
      );
      
      if (booking.isEmpty) {
        _errorMessage = 'Booking not found';
        print('❌ [BookingsProvider] Modification error: ${_errorMessage}');
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // ============ VALIDATION ============
      
      // Check status - can't modify if completed or cancelled
      final currentStatus = booking['status'] as String;
      if (currentStatus == 'completed' || currentStatus == 'cancelled') {
        _errorMessage = 'Cannot modify ${currentStatus} bookings';
        print('❌ [BookingsProvider] Modification error: ${_errorMessage}');
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // Check if booking is in past
      final originalStartTime = DateTime.parse(booking['start_time']);
      if (originalStartTime.isBefore(DateTime.now())) {
        _errorMessage = 'Cannot modify bookings that have already started';
        print('❌ [BookingsProvider] Modification error: ${_errorMessage}');
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // Use new times or keep original
      final finalStartTime = newStartTime ?? originalStartTime;
      final finalEndTime = newEndTime ?? DateTime.parse(booking['end_time']);

      // Validate new times
      if (finalStartTime.isAfter(finalEndTime)) {
        _errorMessage = 'Start time must be before end time';
        print('❌ [BookingsProvider] Validation error: ${_errorMessage}');
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // Check duration (30min-8hr)
      final duration = finalEndTime.difference(finalStartTime);
      if (duration.inMinutes < 30) {
        _errorMessage = 'Booking must be at least 30 minutes long';
        print('❌ [BookingsProvider] Duration error: ${_errorMessage}');
        _isLoading = false;
        notifyListeners();
        return false;
      }
      
      if (duration.inHours > 8) {
        _errorMessage = 'Booking cannot exceed 8 hours';
        print('❌ [BookingsProvider] Duration error: ${_errorMessage}');
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // If time changed, check for conflicts (excluding this booking)
      if (newStartTime != null || newEndTime != null) {
        final roomId = booking['room_id'];
        final conflicting = _allBookings.firstWhere(
          (b) =>
              b['room_id'] == roomId &&
              b['id'] != bookingId &&
              b['status'] != 'cancelled' &&
              _timeConflict(
                DateTime.parse(b['start_time']),
                DateTime.parse(b['end_time']),
                finalStartTime,
                finalEndTime,
              ),
          orElse: () => {},
        );

        if (conflicting.isNotEmpty) {
          final s = DateTime.parse(conflicting['start_time']);
          final e = DateTime.parse(conflicting['end_time']);
          _errorMessage = 'Room is booked ${s.hour}:${s.minute.toString().padLeft(2, '0')}-${e.hour}:${e.minute.toString().padLeft(2, '0')}';
          print('❌ [BookingsProvider] Conflict: ${_errorMessage}');
          _isLoading = false;
          notifyListeners();
          return false;
        }
      }

      // ============ DATABASE UPDATE ============
      
      final updates = {
        if (newStartTime != null) 'start_time': newStartTime.toIso8601String(),
        if (newEndTime != null) 'end_time': newEndTime.toIso8601String(),
        if (newPurpose != null) 'purpose': newPurpose,
        'modified_at': DateTime.now().toIso8601String(),
      };

      await DatabaseService.updateBooking(bookingId, updates);

      // Update local lists
      final userIndex = _userBookings.indexWhere((b) => b['id'] == bookingId);
      if (userIndex != -1) {
        _userBookings[userIndex].addAll(updates);
      }
      
      final adminIndex = _allBookings.indexWhere((b) => b['id'] == bookingId);
      if (adminIndex != -1) {
        _allBookings[adminIndex].addAll(updates);
      }

      print('✅ [BookingsProvider] Booking modified successfully');
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to modify booking: ${e.toString()}';
      print('❌ [BookingsProvider] Error modifying booking: $e');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Update booking status (admin)
  Future<bool> updateBookingStatus(String bookingId, String status) async {
    _errorMessage = null;
    notifyListeners();

    try {
      print('📱 [BookingsProvider] Updating booking status: $bookingId → $status');
      await DatabaseService.updateBookingStatus(bookingId, status);
      
      // Update in lists
      final index = _userBookings.indexWhere((b) => b['id'] == bookingId);
      if (index != -1) {
        _userBookings[index]['status'] = status;
      }
      final adminIndex = _allBookings.indexWhere((b) => b['id'] == bookingId);
      if (adminIndex != -1) {
        _allBookings[adminIndex]['status'] = status;
      }
      
      print('✅ [BookingsProvider] Booking status updated');
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      print('❌ [BookingsProvider] Error updating booking status: $e');
      return false;
    }
  }

  /// Get booking details
  Map<String, dynamic>? getBooking(String bookingId) {
    try {
      return _userBookings.firstWhere((b) => b['id'] == bookingId);
    } catch (e) {
      try {
        return _allBookings.firstWhere((b) => b['id'] == bookingId);
      } catch (e) {
        return null;
      }
    }
  }

  /// Filter bookings by status
  List<Map<String, dynamic>> filterByStatus(String status) {
    return _userBookings.where((b) => b['status'] == status).toList();
  }

  /// Get upcoming bookings
  List<Map<String, dynamic>> getUpcomingBookings() {
    final now = DateTime.now();
    return _userBookings
        .where((b) {
          final startTime = DateTime.parse(b['start_time']);
          return startTime.isAfter(now) && b['status'] != 'cancelled';
        })
        .toList()
        ..sort((a, b) => DateTime.parse(a['start_time']).compareTo(DateTime.parse(b['start_time'])));
  }

  /// Get past bookings
  List<Map<String, dynamic>> getPastBookings() {
    final now = DateTime.now();
    return _userBookings
        .where((b) {
          final startTime = DateTime.parse(b['start_time']);
          return startTime.isBefore(now);
        })
        .toList()
        ..sort((a, b) => DateTime.parse(b['start_time']).compareTo(DateTime.parse(a['start_time'])));
  }

  /// ============ ADVANCED FILTERING ============

  /// Filter bookings by date range
  List<Map<String, dynamic>> filterByDateRange(
    DateTime startDate,
    DateTime endDate, {
    bool includeUserBookingsOnly = true,
  }) {
    final bookings = includeUserBookingsOnly ? _userBookings : _allBookings;
    
    return bookings
        .where((b) {
          final bookingStart = DateTime.parse(b['start_time']);
          return bookingStart.isAfter(startDate) &&
              bookingStart.isBefore(endDate) &&
              b['status'] != 'cancelled';
        })
        .toList()
        ..sort((a, b) =>
            DateTime.parse(a['start_time']).compareTo(DateTime.parse(b['start_time'])));
  }

  /// Filter bookings by room
  List<Map<String, dynamic>> filterByRoom(
    String roomId, {
    bool includeAllStatuses = false,
  }) {
    return _allBookings
        .where((b) =>
            b['room_id'] == roomId &&
            (includeAllStatuses || b['status'] != 'cancelled'))
        .toList()
        ..sort((a, b) =>
            DateTime.parse(a['start_time']).compareTo(DateTime.parse(b['start_time'])));
  }

  /// Filter bookings by multiple criteria
  List<Map<String, dynamic>> advancedFilter({
    String? roomId,
    String? status = 'pending',
    DateTime? startDate,
    DateTime? endDate,
    String? searchPurpose,
  }) {
    var results = List<Map<String, dynamic>>.from(_allBookings);

    // Filter by room
    if (roomId != null && roomId.isNotEmpty) {
      results = results.where((b) => b['room_id'] == roomId).toList();
    }

    // Filter by status
    if (status != null && status.isNotEmpty) {
      results = results.where((b) => b['status'] == status).toList();
    } else {
      results = results.where((b) => b['status'] != 'cancelled').toList();
    }

    // Filter by date range
    if (startDate != null && endDate != null) {
      results = results.where((b) {
        final bookingStart = DateTime.parse(b['start_time']);
        return bookingStart.isAfter(startDate) && bookingStart.isBefore(endDate);
      }).toList();
    }

    // Search in purpose field
    if (searchPurpose != null && searchPurpose.isNotEmpty) {
      final query = searchPurpose.toLowerCase();
      results = results
          .where((b) =>
              (b['title'] ?? '').toString().toLowerCase().contains(query))
          .toList();
    }

    // Sort by start time
    results.sort(
        (a, b) => DateTime.parse(a['start_time']).compareTo(DateTime.parse(b['start_time'])));

    return results;
  }

  /// Get bookings by status with counts
  Map<String, int> getBookingStatistics() {
    return {
      'pending': _userBookings.where((b) => b['status'] == 'pending').length,
      'confirmed': _userBookings.where((b) => b['status'] == 'confirmed').length,
      'completed': _userBookings.where((b) => b['status'] == 'completed').length,
      'cancelled': _userBookings.where((b) => b['status'] == 'cancelled').length,
    };
  }

  /// Get all bookings for a specific date
  List<Map<String, dynamic>> getBookingsForDate(DateTime date) {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(Duration(days: 1));

    return _userBookings
        .where((b) {
          final bookingStart = DateTime.parse(b['start_time']);
          return bookingStart.isAfter(startOfDay) &&
              bookingStart.isBefore(endOfDay) &&
              b['status'] != 'cancelled';
        })
        .toList()
        ..sort((a, b) =>
            DateTime.parse(a['start_time']).compareTo(DateTime.parse(b['start_time'])));
  }

  /// Get bookings for a room on a specific date
  List<Map<String, dynamic>> getRoomBookingsForDate(
    String roomId,
    DateTime date,
  ) {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(Duration(days: 1));

    return _allBookings
        .where((b) {
          final bookingStart = DateTime.parse(b['start_time']);
          return b['room_id'] == roomId &&
              bookingStart.isAfter(startOfDay) &&
              bookingStart.isBefore(endOfDay) &&
              b['status'] != 'cancelled';
        })
        .toList()
        ..sort((a, b) =>
            DateTime.parse(a['start_time']).compareTo(DateTime.parse(b['start_time'])));
  }

  /// Search bookings by purpose or user info
  List<Map<String, dynamic>> searchBookings(String query) {
    if (query.isEmpty) return _userBookings;

    final searchTerm = query.toLowerCase();
    return _userBookings
        .where((b) {
          final purpose = (b['title'] ?? '').toString().toLowerCase();
          return purpose.contains(searchTerm);
        })
        .toList()
        ..sort((a, b) =>
            DateTime.parse(a['start_time']).compareTo(DateTime.parse(b['start_time'])));
  }

  /// Get room availability for a date (returns available time slots)
  List<Map<String, dynamic>> getAvailableTimeSlots(
    String roomId,
    DateTime date, {
    int slotDurationMinutes = 60, // Default 1-hour slots
    int workStartHour = 8,
    int workEndHour = 18,
  }) {
    final slots = <Map<String, dynamic>>[];
    final bookings = getRoomBookingsForDate(roomId, date);

    // Generate potential slots
    for (int hour = workStartHour; hour < workEndHour; hour++) {
      for (int minute = 0; minute < 60; minute += slotDurationMinutes) {
        final slotStart = DateTime(date.year, date.month, date.day, hour, minute);
        final slotEnd = slotStart.add(Duration(minutes: slotDurationMinutes));

        // Check if slot conflicts with existing bookings
        bool available = !bookings.any((b) =>
            _timeConflict(
              DateTime.parse(b['start_time']),
              DateTime.parse(b['end_time']),
              slotStart,
              slotEnd,
            ));

        if (available) {
          slots.add({
            'start': slotStart,
            'end': slotEnd,
            'available': true,
          });
        }
      }
    }

    return slots;
  }

  /// Clear error
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
