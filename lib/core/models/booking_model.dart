enum BookingStatus { pending, confirmed, inProgress, completed, cancelled }

class Booking {
  final String id;
  final String roomId;
  final String userId;
  final DateTime startTime;
  final DateTime endTime;
  final String purpose;
  final BookingStatus status;
  final int expectedOccupants;
  final String? notes;
  final DateTime createdAt;
  final DateTime? cancelledAt;
  final String? cancellationReason;

  Booking({
    required this.id,
    required this.roomId,
    required this.userId,
    required this.startTime,
    required this.endTime,
    required this.purpose,
    required this.status,
    required this.expectedOccupants,
    this.notes,
    required this.createdAt,
    this.cancelledAt,
    this.cancellationReason,
  });

  // Calculate duration in minutes
  int get durationMinutes {
    return endTime.difference(startTime).inMinutes;
  }

  // Check if booking is overlapping with another time range
  bool overlapsWithTime(DateTime start, DateTime end) {
    return startTime.isBefore(end) && endTime.isAfter(start);
  }

  Booking copyWith({
    String? id,
    String? roomId,
    String? userId,
    DateTime? startTime,
    DateTime? endTime,
    String? purpose,
    BookingStatus? status,
    int? expectedOccupants,
    String? notes,
    DateTime? createdAt,
    DateTime? cancelledAt,
    String? cancellationReason,
  }) {
    return Booking(
      id: id ?? this.id,
      roomId: roomId ?? this.roomId,
      userId: userId ?? this.userId,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      purpose: purpose ?? this.purpose,
      status: status ?? this.status,
      expectedOccupants: expectedOccupants ?? this.expectedOccupants,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      cancelledAt: cancelledAt ?? this.cancelledAt,
      cancellationReason: cancellationReason ?? this.cancellationReason,
    );
  }

  @override
  String toString() => 'Booking(id: $id, roomId: $roomId, status: ${status.name})';
}
