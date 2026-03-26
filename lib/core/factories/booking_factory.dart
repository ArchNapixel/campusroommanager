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
    required String purpose,
    int expectedOccupants = 1,
    String? notes,
    String? id,
  }) {
    return Booking(
      id: id ?? _uuid.v4(),
      roomId: roomId,
      userId: userId,
      startTime: startTime,
      endTime: endTime,
      purpose: purpose,
      status: BookingStatus.pending,
      expectedOccupants: expectedOccupants,
      notes: notes,
      createdAt: DateTime.now(),
    );
  }

  /// Creates a confirmed booking (for admins)
  static Booking createConfirmedBooking({
    required String roomId,
    required String userId,
    required DateTime startTime,
    required DateTime endTime,
    required String purpose,
    int expectedOccupants = 1,
    String? notes,
    String? id,
  }) {
    return Booking(
      id: id ?? _uuid.v4(),
      roomId: roomId,
      userId: userId,
      startTime: startTime,
      endTime: endTime,
      purpose: purpose,
      status: BookingStatus.confirmed,
      expectedOccupants: expectedOccupants,
      notes: notes,
      createdAt: DateTime.now(),
    );
  }

  /// Creates an in-progress booking
  static Booking createInProgressBooking({
    required String roomId,
    required String userId,
    required DateTime startTime,
    required DateTime endTime,
    required String purpose,
    int expectedOccupants = 1,
    String? notes,
    String? id,
  }) {
    return Booking(
      id: id ?? _uuid.v4(),
      roomId: roomId,
      userId: userId,
      startTime: startTime,
      endTime: endTime,
      purpose: purpose,
      status: BookingStatus.inProgress,
      expectedOccupants: expectedOccupants,
      notes: notes,
      createdAt: DateTime.now(),
    );
  }

  /// Creates a cancelled booking
  static Booking createCancelledBooking({
    required String roomId,
    required String userId,
    required DateTime startTime,
    required DateTime endTime,
    required String purpose,
    required String cancellationReason,
    int expectedOccupants = 1,
    String? notes,
    String? id,
  }) {
    return Booking(
      id: id ?? _uuid.v4(),
      roomId: roomId,
      userId: userId,
      startTime: startTime,
      endTime: endTime,
      purpose: purpose,
      status: BookingStatus.cancelled,
      expectedOccupants: expectedOccupants,
      notes: notes,
      createdAt: DateTime.now(),
      cancelledAt: DateTime.now(),
      cancellationReason: cancellationReason,
    );
  }

  /// Creates a custom booking with all parameters
  static Booking createCustom({
    required String roomId,
    required String userId,
    required DateTime startTime,
    required DateTime endTime,
    required String purpose,
    required BookingStatus status,
    int expectedOccupants = 1,
    String? notes,
    String? id,
    DateTime? createdAt,
    DateTime? cancelledAt,
    String? cancellationReason,
  }) {
    return Booking(
      id: id ?? _uuid.v4(),
      roomId: roomId,
      userId: userId,
      startTime: startTime,
      endTime: endTime,
      purpose: purpose,
      status: status,
      expectedOccupants: expectedOccupants,
      notes: notes,
      createdAt: createdAt ?? DateTime.now(),
      cancelledAt: cancelledAt,
      cancellationReason: cancellationReason,
    );
  }
}
