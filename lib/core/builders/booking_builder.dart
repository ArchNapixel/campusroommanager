import '../models/booking_model.dart';

/// Builder for constructing Booking objects step by step
class BookingBuilder {
  late String _id;
  late String _roomId;
  late String _userId;
  late DateTime _startTime;
  late DateTime _endTime;
  late String _title;
  BookingStatus _status = BookingStatus.confirmed;
  int _expectedOccupants = 1;
  String? _description;
  DateTime? _createdAt;
  DateTime? _updatedAt;

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

  BookingBuilder withTitle(String title) {
    _title = title;
    return this;
  }

  // Keep withPurpose for backwards compatibility
  BookingBuilder withPurpose(String purpose) {
    _title = purpose;
    return this;
  }

  BookingBuilder withDescription(String description) {
    _description = description;
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
    _description = notes;
    return this;
  }

  BookingBuilder withCreatedAt(DateTime createdAt) {
    _createdAt = createdAt;
    return this;
  }

  BookingBuilder withUpdatedAt(DateTime updatedAt) {
    _updatedAt = updatedAt;
    return this;
  }

  BookingBuilder withCancellation() {
    _status = BookingStatus.cancelled;
    _updatedAt = DateTime.now();
    return this;
  }

  /// Build the Booking object
  Booking build() {
    if (_roomId.isEmpty || _userId.isEmpty || _title.isEmpty) {
      throw ArgumentError('Required fields: roomId, userId, title');
    }

    return Booking(
      id: _id,
      roomId: _roomId,
      userId: _userId,
      startTime: _startTime,
      endTime: _endTime,
      title: _title,
      description: _description,
      status: _status,
      expectedOccupants: _expectedOccupants,
      createdAt: _createdAt ?? DateTime.now(),
      updatedAt: _updatedAt,
    );
  }
}
