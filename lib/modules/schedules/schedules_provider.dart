import 'package:flutter/material.dart';
import '../../core/factories/schedule_factory.dart';
import '../../core/models/booking_model.dart';
import '../../core/models/schedule_model.dart';

/// State provider for schedules
class SchedulesProvider with ChangeNotifier {
  List<Schedule> _schedules = [];
  List<Booking> _bookings = [];
  bool _isLoading = false;

  List<Schedule> get schedules => _schedules;
  List<Booking> get bookings => _bookings;
  bool get isLoading => _isLoading;

  /// Load schedules and bookings
  Future<void> loadSchedules(List<Booking> bookings) async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(Duration(milliseconds: 500));

    _bookings = bookings;

    // Create schedules from bookings
    _schedules = bookings
        .map((booking) => ScheduleFactory.createScheduleForDate(
              roomId: booking.roomId,
              bookingId: booking.id,
              date: booking.startTime,
              notes: booking.notes,
            ))
        .toList();

    _isLoading = false;
    notifyListeners();
  }

  /// Add new schedule
  Future<void> addSchedule(Schedule schedule) async {
    _schedules.add(schedule);
    notifyListeners();
    // TODO: Persist to backend
  }

  /// Update schedule
  Future<void> updateSchedule(String scheduleId, Schedule updated) async {
    final index = _schedules.indexWhere((s) => s.id == scheduleId);
    if (index != -1) {
      _schedules[index] = updated;
      notifyListeners();
    }
    // TODO: Persist to backend
  }

  /// Delete schedule
  Future<void> deleteSchedule(String scheduleId) async {
    _schedules.removeWhere((s) => s.id == scheduleId);
    notifyListeners();
    // TODO: Persist to backend
  }

  /// Get schedules for specific date
  List<Booking> getBookingsForDate(DateTime date) {
    return _bookings
        .where((booking) =>
            booking.startTime.year == date.year &&
            booking.startTime.month == date.month &&
            booking.startTime.day == date.day)
        .toList();
  }

  /// Get schedules for specific room
  List<Schedule> getSchedulesForRoom(String roomId) {
    return _schedules.where((s) => s.roomId == roomId).toList();
  }

  /// Get schedules for date range
  List<Booking> getBookingsForDateRange(DateTime start, DateTime end) {
    return _bookings
        .where((booking) =>
            booking.startTime.isAfter(start) && booking.endTime.isBefore(end))
        .toList();
  }

  /// Check room availability for time slot
  bool isRoomAvailable(String roomId, DateTime startTime, DateTime endTime) {
    return !_bookings.any((booking) =>
        booking.roomId == roomId &&
        booking.status != BookingStatus.cancelled &&
        booking.overlapsWithTime(startTime, endTime));
  }
}
