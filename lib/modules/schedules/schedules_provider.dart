import 'package:flutter/material.dart';
import '../../core/factories/schedule_factory.dart';
import '../../core/models/booking_model.dart';
import '../../core/models/schedule_model.dart';
import '../../core/services/database_service.dart';

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
              notes: booking.description,
            ))
        .toList();

    _isLoading = false;
    notifyListeners();
  }

  /// Add new schedule
  Future<void> addSchedule(Schedule schedule) async {
    _isLoading = true;
    notifyListeners();

    try {
      print('📱 [SchedulesProvider] Adding schedule: ${schedule.id}');
      final scheduleData = _mapScheduleToData(schedule);
      await DatabaseService.createSchedule(scheduleData);
      _schedules.add(schedule);
      print('✅ [SchedulesProvider] Schedule added successfully');
    } catch (e) {
      print('❌ [SchedulesProvider] Error adding schedule: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Update schedule
  Future<void> updateSchedule(String scheduleId, Schedule updated) async {
    _isLoading = true;
    notifyListeners();

    try {
      print('📱 [SchedulesProvider] Updating schedule: $scheduleId');
      final updateData = _mapScheduleToData(updated);
      await DatabaseService.updateSchedule(scheduleId, updateData);
      final index = _schedules.indexWhere((s) => s.id == scheduleId);
      if (index != -1) {
        _schedules[index] = updated;
      }
      print('✅ [SchedulesProvider] Schedule updated successfully');
    } catch (e) {
      print('❌ [SchedulesProvider] Error updating schedule: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Delete schedule
  Future<void> deleteSchedule(String scheduleId) async {
    _isLoading = true;
    notifyListeners();

    try {
      print('📱 [SchedulesProvider] Deleting schedule: $scheduleId');
      await DatabaseService.deleteSchedule(scheduleId);
      _schedules.removeWhere((s) => s.id == scheduleId);
      print('✅ [SchedulesProvider] Schedule deleted successfully');
    } catch (e) {
      print('❌ [SchedulesProvider] Error deleting schedule: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
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

  /// Helper: Map Schedule model to database data
  Map<String, dynamic> _mapScheduleToData(Schedule schedule) {
    return {
      'room_id': schedule.roomId,
      'booking_id': schedule.bookingId,
      'date': schedule.date.toIso8601String(),
      'notes': schedule.notes,
    };
  }
}

