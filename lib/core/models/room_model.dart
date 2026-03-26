enum RoomType { lab, audioVisual, classroom, other }

enum OccupancyStatus { available, occupied, pending, maintenance }

class Room {
  final String id;
  final String name;
  final int capacity;
  final RoomType type;
  final String building;
  final String floor;
  final String roomNumber;
  final OccupancyStatus occupancyStatus;
  final DateTime lastUpdated;
  final Map<String, dynamic> amenities; // projector, whiteboard, etc.
  final double? latitude; // for map positioning
  final double? longitude; // for map positioning

  Room({
    required this.id,
    required this.name,
    required this.capacity,
    required this.type,
    required this.building,
    required this.floor,
    required this.roomNumber,
    required this.occupancyStatus,
    required this.lastUpdated,
    this.amenities = const {},
    this.latitude,
    this.longitude,
  });

  // Copy with method for immutability-friendly updates
  Room copyWith({
    String? id,
    String? name,
    int? capacity,
    RoomType? type,
    String? building,
    String? floor,
    String? roomNumber,
    OccupancyStatus? occupancyStatus,
    DateTime? lastUpdated,
    Map<String, dynamic>? amenities,
    double? latitude,
    double? longitude,
  }) {
    return Room(
      id: id ?? this.id,
      name: name ?? this.name,
      capacity: capacity ?? this.capacity,
      type: type ?? this.type,
      building: building ?? this.building,
      floor: floor ?? this.floor,
      roomNumber: roomNumber ?? this.roomNumber,
      occupancyStatus: occupancyStatus ?? this.occupancyStatus,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      amenities: amenities ?? this.amenities,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
    );
  }

  @override
  String toString() => 'Room(id: $id, name: $name, capacity: $capacity, type: $type)';
}
