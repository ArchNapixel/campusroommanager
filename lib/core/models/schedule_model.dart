class Schedule {
  final String id;
  final String roomId;
  final String bookingId;
  final DateTime date;
  final DateTime createdAt;
  final String? notes;

  Schedule({
    required this.id,
    required this.roomId,
    required this.bookingId,
    required this.date,
    required this.createdAt,
    this.notes,
  });

  Schedule copyWith({
    String? id,
    String? roomId,
    String? bookingId,
    DateTime? date,
    DateTime? createdAt,
    String? notes,
  }) {
    return Schedule(
      id: id ?? this.id,
      roomId: roomId ?? this.roomId,
      bookingId: bookingId ?? this.bookingId,
      date: date ?? this.date,
      createdAt: createdAt ?? this.createdAt,
      notes: notes ?? this.notes,
    );
  }

  @override
  String toString() => 'Schedule(id: $id, roomId: $roomId, bookingId: $bookingId)';
}
