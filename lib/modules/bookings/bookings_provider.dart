import 'package:flutter/material.dart';
import '../../core/factories/booking_factory.dart';
import '../../core/models/booking_model.dart';

/// State provider for bookings
class BookingsProvider with ChangeNotifier {
  List<Booking> _bookings = [];
  bool _isLoading = false;

  List<Booking> get bookings => _bookings;
  bool get isLoading => _isLoading;

  /// Load bookings from database
  Future<void> loadBookings() async {
    _isLoading = true;
    notifyListeners();

    try {
      // TODO: Fetch bookings from database/API
      _bookings = [];
    } catch (e) {
      print('Error loading bookings: $e');
      _bookings = [];
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Create new booking
  Future<void> createBooking(Booking booking) async {
    _bookings.add(booking);
    notifyListeners();
    // TODO: Persist to backend
  }

  /// Update booking
  Future<void> updateBooking(String bookingId, Booking updated) async {
    final index = _bookings.indexWhere((b) => b.id == bookingId);
    if (index != -1) {
      _bookings[index] = updated;
      notifyListeners();
    }
    // TODO: Persist to backend
  }

  /// Cancel booking
  Future<void> cancelBooking(String bookingId, String reason) async {
    final index = _bookings.indexWhere((b) => b.id == bookingId);
    if (index != -1) {
      _bookings[index] = _bookings[index].copyWith(
        status: BookingStatus.cancelled,
        cancelledAt: DateTime.now(),
        cancellationReason: reason,
      );
      notifyListeners();
    }
    // TODO: Persist to backend
  }

  /// Get bookings for specific user
  List<Booking> getBookingsForUser(String userId) {
    return _bookings.where((b) => b.userId == userId).toList();
  }

  /// Get bookings for specific room
  List<Booking> getBookingsForRoom(String roomId) {
    return _bookings.where((b) => b.roomId == roomId).toList();
  }

  /// Get active bookings
  List<Booking> getActiveBookings() {
    return _bookings
        .where((b) =>
            b.status != BookingStatus.cancelled &&
            b.status != BookingStatus.completed)
        .toList();
  }

  /// Check for conflicting bookings
  bool hasConflict(String roomId, DateTime startTime, DateTime endTime) {
    return _bookings.any((booking) =>
        booking.roomId == roomId &&
        booking.status != BookingStatus.cancelled &&
        booking.overlapsWithTime(startTime, endTime));
  }

  /// Check if room is available for time slot
  bool isRoomAvailable(String roomId, DateTime startTime, DateTime endTime) {
    return !hasConflict(roomId, startTime, endTime);
  }
}
