import 'package:flutter/material.dart';
import '../../core/factories/room_factory.dart';
import '../../core/models/room_model.dart';

/// State provider for rooms
class RoomsProvider with ChangeNotifier {
  List<Room> _rooms = [];
  bool _isLoading = false;

  List<Room> get rooms => _rooms;
  bool get isLoading => _isLoading;

  /// Load all rooms (mock data)
  Future<void> loadRooms() async {
    _isLoading = true;
    notifyListeners();

    // Simulate API call
    await Future.delayed(Duration(milliseconds: 500));

    _rooms = [
      RoomFactory.createLab(
        id: 'room1',
        name: 'Physics Lab A',
        capacity: 30,
        building: 'Science Building',
        floor: '2',
        roomNumber: '201',
        latitude: 40.1234,
        longitude: -74.5678,
      ),
      RoomFactory.createLab(
        id: 'room2',
        name: 'Chemistry Lab B',
        capacity: 25,
        building: 'Science Building',
        floor: '2',
        roomNumber: '202',
      ),
      RoomFactory.createAudioVisualRoom(
        id: 'room3',
        name: 'AV Studio 1',
        capacity: 50,
        building: 'Engineering Building',
        floor: '3',
        roomNumber: '301',
      ),
      RoomFactory.createClassroom(
        id: 'room4',
        name: 'Classroom 101',
        capacity: 60,
        building: 'Main Campus',
        floor: '1',
        roomNumber: '101',
      ),
      RoomFactory.createLab(
        id: 'room5',
        name: 'Computer Lab',
        capacity: 40,
        building: 'Tech Center',
        floor: '1',
        roomNumber: '105',
      ),
    ];

    // Add mock usage frequency to amenities
    _rooms = _rooms
        .map((room) => room.copyWith(
              amenities: {
                ...room.amenities,
                'usageFrequency': 0.3 + (DateTime.now().millisecond % 7) / 10,
              },
            ))
        .toList();

    _isLoading = false;
    notifyListeners();
  }

  /// Find room by ID
  Room? getRoomById(String id) {
    try {
      return _rooms.firstWhere((room) => room.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Filter rooms by type
  List<Room> getRoomsByType(RoomType type) {
    return _rooms.where((room) => room.type == type).toList();
  }

  /// Filter available rooms
  List<Room> getAvailableRooms() {
    return _rooms
        .where((room) => room.occupancyStatus == OccupancyStatus.available)
        .toList();
  }

  /// Search rooms
  List<Room> searchRooms(String query) {
    final lowerQuery = query.toLowerCase();
    return _rooms.where((room) {
      return room.name.toLowerCase().contains(lowerQuery) ||
          room.building.toLowerCase().contains(lowerQuery) ||
          room.roomNumber.toLowerCase().contains(lowerQuery);
    }).toList();
  }

  /// Update room occupancy status
  void updateRoomStatus(String roomId, OccupancyStatus status) {
    final index = _rooms.indexWhere((room) => room.id == roomId);
    if (index != -1) {
      _rooms[index] =
          _rooms[index].copyWith(occupancyStatus: status, lastUpdated: DateTime.now());
      notifyListeners();
    }
  }
}
