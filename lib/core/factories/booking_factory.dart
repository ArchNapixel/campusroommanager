import 'package:uuid/uuid.dart';
import '../models/booking_model.dart';

/// Factory for creating Booking objects with default values
class BookingFactory {
  static const _uuid = Uuid();

  /// Creates a standard booking with defaults
  static Booking createStandardBooking({
    required String roomId,
    required String userId,
    required DateTime startTime,
    required DateTime endTime,
    required String title,
    String? description,
    int expectedOccupants = 1,
    String? id,
  }) {
    return Booking(
      id: id ?? _uuid.v4(),
      roomId: roomId,
      userId: userId,
      startTime: startTime,
      endTime: endTime,
      title: title,
      description: description,
      status: BookingStatus.confirmed,
      expectedOccupants: expectedOccupants,
      createdAt: DateTime.now(),
    );
  }

  /// Creates a confirmed booking (for admins)
  static Booking createConfirmedBooking({
    required String roomId,
    required String userId,
    required DateTime startTime,
    required DateTime endTime,
    required String title,
    String? description,
    int expectedOccupants = 1,
    String? id,
  }) {
    return Booking(
      id: id ?? _uuid.v4(),
      roomId: roomId,
      userId: userId,
      startTime: startTime,
      endTime: endTime,
      title: title,
      description: description,
      status: BookingStatus.confirmed,
      expectedOccupants: expectedOccupants,
      createdAt: DateTime.now(),
    );
  }

  /// Creates an in-progress booking
  static Booking createInProgressBooking({
    required String roomId,
    required String userId,
    required DateTime startTime,
    required DateTime endTime,
    required String title,
    String? description,
    int expectedOccupants = 1,
    String? id,
  }) {
    return Booking(
      id: id ?? _uuid.v4(),
      roomId: roomId,
      userId: userId,
      startTime: startTime,
      endTime: endTime,
      title: title,
      description: description,
      status: BookingStatus.inProgress,
      expectedOccupants: expectedOccupants,
      createdAt: DateTime.now(),
    );
  }

  /// Creates a cancelled booking
  static Booking createCancelledBooking({
    required String roomId,
    required String userId,
    required DateTime startTime,
    required DateTime endTime,
    required String title,
    String? description,
    int expectedOccupants = 1,
    String? id,
  }) {
    return Booking(
      id: id ?? _uuid.v4(),
      roomId: roomId,
      userId: userId,
      startTime: startTime,
      endTime: endTime,
      title: title,
      description: description,
      status: BookingStatus.cancelled,
      expectedOccupants: expectedOccupants,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  /// Creates a custom booking with all parameters
  static Booking createCustom({
    required String roomId,
    required String userId,
    required DateTime startTime,
    required DateTime endTime,
    required String title,
    String? description,
    required BookingStatus status,
    int expectedOccupants = 1,
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Booking(
      id: id ?? _uuid.v4(),
      roomId: roomId,
      userId: userId,
      startTime: startTime,
      endTime: endTime,
      title: title,
      description: description,
      status: status,
      expectedOccupants: expectedOccupants,
      createdAt: createdAt ?? DateTime.now(),
      updatedAt: updatedAt,
    );
  }
}
