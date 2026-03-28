import 'package:flutter/material.dart';
import '../../core/services/database_service.dart';
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
          return BookingStatus.pending;
      }
    }

    return Booking(
      id: data['id'] ?? '',
      roomId: data['room_id'] ?? '',
      userId: data['user_id'] ?? '',
      startTime: DateTime.parse(data['start_time'] ?? DateTime.now().toIso8601String()),
      endTime: DateTime.parse(data['end_time'] ?? DateTime.now().toIso8601String()),
      purpose: data['purpose'] ?? '',
      status: statusFromString(data['status'] ?? 'pending'),
      expectedOccupants: data['expected_occupants'] ?? 0,
      notes: data['notes'],
      createdAt: DateTime.parse(data['created_at'] ?? DateTime.now().toIso8601String()),
      cancelledAt: data['cancelled_at'] != null ? DateTime.parse(data['cancelled_at']) : null,
      cancellationReason: data['cancellation_reason'],
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

  /// Create booking
  Future<bool> createBooking({
    required String roomId,
    required String userId,
    required DateTime startTime,
    required DateTime endTime,
    String? purpose,
  }) async {
    _errorMessage = null;
    notifyListeners();

    try {
      print('📱 [BookingsProvider] Creating booking for room: $roomId');
      
      // Check availability first
      final available = await DatabaseService.isRoomAvailable(
        roomId,
        startTime,
        endTime,
      );

      if (!available) {
        _errorMessage = 'Room is not available for the selected time';
        print('❌ [BookingsProvider] Room not available');
        notifyListeners();
        return false;
      }

      // Create booking
      await DatabaseService.createBooking({
        'room_id': roomId,
        'user_id': userId,
        'start_time': startTime.toIso8601String(),
        'end_time': endTime.toIso8601String(),
        'purpose': purpose ?? 'Room reservation',
        'status': 'pending',
      });

      print('✅ [BookingsProvider] Booking created successfully');
      // Reload bookings
      await loadUserBookings(userId);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      print('❌ [BookingsProvider] Error creating booking: $e');
      return false;
    }
  }

  /// Cancel booking
  Future<bool> cancelBooking(String bookingId) async {
    _errorMessage = null;
    notifyListeners();

    try {
      print('📱 [BookingsProvider] Cancelling booking: $bookingId');
      await DatabaseService.cancelBooking(bookingId);
      
      // Remove from list
      _userBookings.removeWhere((b) => b['id'] == bookingId);
      _allBookings.removeWhere((b) => b['id'] == bookingId);
      
      print('✅ [BookingsProvider] Booking cancelled');
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      print('❌ [BookingsProvider] Error cancelling booking: $e');
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

  /// Clear error
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
