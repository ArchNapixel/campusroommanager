import '../models/booking_model.dart';

/// Builder for constructing Booking objects step by step
class BookingBuilder {
  late String _id;
  late String _roomId;
  late String _userId;
  late DateTime _startTime;
  late DateTime _endTime;
  late String _purpose;
  BookingStatus _status = BookingStatus.pending;
  int _expectedOccupants = 1;
  String? _notes;
  DateTime? _createdAt;
  DateTime? _cancelledAt;
  String? _cancellationReason;

  BookingBuilder();

  BookingBuilder withId(String id) {
    _id = id;
    return this;
  }

  BookingBuilder withRoomId(String roomId) {
    _roomId = roomId;
    return this;
  }

  BookingBuilder withUserId(String userId) {
    _userId = userId;
    return this;
  }

  BookingBuilder withTimeRange(DateTime startTime, DateTime endTime) {
    _startTime = startTime;
    _endTime = endTime;
    return this;
  }

  BookingBuilder withStartTime(DateTime startTime) {
    _startTime = startTime;
    return this;
  }

  BookingBuilder withEndTime(DateTime endTime) {
    _endTime = endTime;
    return this;
  }

  BookingBuilder withPurpose(String purpose) {
    _purpose = purpose;
    return this;
  }

  BookingBuilder withStatus(BookingStatus status) {
    _status = status;
    return this;
  }

  BookingBuilder withExpectedOccupants(int count) {
    _expectedOccupants = count;
    return this;
  }

  BookingBuilder withNotes(String notes) {
    _notes = notes;
    return this;
  }

  BookingBuilder withCreatedAt(DateTime createdAt) {
    _createdAt = createdAt;
    return this;
  }

  BookingBuilder withCancellation(String reason) {
    _status = BookingStatus.cancelled;
    _cancelledAt = DateTime.now();
    _cancellationReason = reason;
    return this;
  }

  /// Build the Booking object
  Booking build() {
    if (_roomId.isEmpty || _userId.isEmpty || _purpose.isEmpty) {
      throw ArgumentError('Required fields: roomId, userId, purpose');
    }

    return Booking(
      id: _id,
      roomId: _roomId,
      userId: _userId,
      startTime: _startTime,
      endTime: _endTime,
      purpose: _purpose,
      status: _status,
      expectedOccupants: _expectedOccupants,
      notes: _notes,
      createdAt: _createdAt ?? DateTime.now(),
      cancelledAt: _cancelledAt,
      cancellationReason: _cancellationReason,
    );
  }
}
