import '../models/room_model.dart';

/// Factory for creating Room objects by type
class RoomFactory {
  /// Creates a lab room with typical lab amenities
  static Room createLab({
    required String id,
    required String name,
    required int capacity,
    required String building,
    required String floor,
    required String roomNumber,
    double? latitude,
    double? longitude,
  }) {
    return Room(
      id: id,
      name: name,
      capacity: capacity,
      type: RoomType.lab,
      building: building,
      floor: floor,
      roomNumber: roomNumber,
      occupancyStatus: OccupancyStatus.available,
      lastUpdated: DateTime.now(),
      amenities: {
        'hasEquipment': true,
        'hasProjector': true,
        'hasWhiteboard': true,
        'hasComputers': true,
      },
      latitude: latitude,
      longitude: longitude,
    );
  }

  /// Creates an audio-visual room with AV amenities
  static Room createAudioVisualRoom({
    required String id,
    required String name,
    required int capacity,
    required String building,
    required String floor,
    required String roomNumber,
    double? latitude,
    double? longitude,
  }) {
    return Room(
      id: id,
      name: name,
      capacity: capacity,
      type: RoomType.audioVisual,
      building: building,
      floor: floor,
      roomNumber: roomNumber,
      occupancyStatus: OccupancyStatus.available,
      lastUpdated: DateTime.now(),
      amenities: {
        'hasProjector': true,
        'hasAudioSystem': true,
        'hasSoundboard': true,
        'hasScreenShare': true,
        'hasRecording': true,
      },
      latitude: latitude,
      longitude: longitude,
    );
  }

  /// Creates a classroom room
  static Room createClassroom({
    required String id,
    required String name,
    required int capacity,
    required String building,
    required String floor,
    required String roomNumber,
    double? latitude,
    double? longitude,
  }) {
    return Room(
      id: id,
      name: name,
      capacity: capacity,
      type: RoomType.classroom,
      building: building,
      floor: floor,
      roomNumber: roomNumber,
      occupancyStatus: OccupancyStatus.available,
      lastUpdated: DateTime.now(),
      amenities: {
        'hasProjector': true,
        'hasWhiteboard': true,
        'hasSeating': true,
        'hasClimateControl': true,
      },
      latitude: latitude,
      longitude: longitude,
    );
  }

  /// Creates a generic room with minimal amenities
  static Room createGenericRoom({
    required String id,
    required String name,
    required int capacity,
    required String building,
    required String floor,
    required String roomNumber,
    double? latitude,
    double? longitude,
  }) {
    return Room(
      id: id,
      name: name,
      capacity: capacity,
      type: RoomType.other,
      building: building,
      floor: floor,
      roomNumber: roomNumber,
      occupancyStatus: OccupancyStatus.available,
      lastUpdated: DateTime.now(),
      amenities: {},
      latitude: latitude,
      longitude: longitude,
    );
  }

  /// Creates room with custom amenities
  static Room createCustom({
    required String id,
    required String name,
    required int capacity,
    required RoomType type,
    required String building,
    required String floor,
    required String roomNumber,
    Map<String, dynamic> amenities = const {},
    double? latitude,
    double? longitude,
  }) {
    return Room(
      id: id,
      name: name,
      capacity: capacity,
      type: type,
      building: building,
      floor: floor,
      roomNumber: roomNumber,
      occupancyStatus: OccupancyStatus.available,
      lastUpdated: DateTime.now(),
      amenities: amenities,
      latitude: latitude,
      longitude: longitude,
    );
  }
}
