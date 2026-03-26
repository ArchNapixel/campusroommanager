import 'package:uuid/uuid.dart';
import '../models/schedule_model.dart';

/// Factory for creating Schedule objects
class ScheduleFactory {
  static const _uuid = Uuid();

  /// Creates a schedule linked to a room and booking
  static Schedule createSchedule({
    required String roomId,
    required String bookingId,
    required DateTime date,
    String? notes,
    String? id,
  }) {
    return Schedule(
      id: id ?? _uuid.v4(),
      roomId: roomId,
      bookingId: bookingId,
      date: date,
      createdAt: DateTime.now(),
      notes: notes,
    );
  }

  /// Creates a schedule for today
  static Schedule createTodaySchedule({
    required String roomId,
    required String bookingId,
    String? notes,
    String? id,
  }) {
    final today = DateTime.now();
    return Schedule(
      id: id ?? _uuid.v4(),
      roomId: roomId,
      bookingId: bookingId,
      date: today,
      createdAt: DateTime.now(),
      notes: notes,
    );
  }

  /// Creates a schedule for a specific date
  static Schedule createScheduleForDate({
    required String roomId,
    required String bookingId,
    required DateTime date,
    String? notes,
    String? id,
  }) {
    return Schedule(
      id: id ?? _uuid.v4(),
      roomId: roomId,
      bookingId: bookingId,
      date: date,
      createdAt: DateTime.now(),
      notes: notes,
    );
  }
}
