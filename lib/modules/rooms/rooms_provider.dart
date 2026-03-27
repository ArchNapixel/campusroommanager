import 'package:flutter/material.dart';
import 'dart:math';
import '../../core/factories/room_factory.dart';
import '../../core/models/room_model.dart';

/// State provider for rooms
class RoomsProvider with ChangeNotifier {
  List<Room> _rooms = [];
  bool _isLoading = false;

  List<Room> get rooms => _rooms;
  bool get isLoading => _isLoading;

  /// Load all rooms from database
  Future<void> loadRooms() async {
    _isLoading = true;
    notifyListeners();

    try {
      // TODO: Fetch rooms from database/API
      _rooms = [];
    } catch (e) {
      print('Error loading rooms: $e');
      _rooms = [];
    }

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

  /// Create a new room
  void createRoom({
    required String name,
    required String building,
    required String roomNumber,
    required int capacity,
    String? floor,
    RoomType roomType = RoomType.classroom,
  }) {
    // Generate amenities based on room type
    final random = Random();
    Map<String, dynamic> amenities = {};

    switch (roomType) {
      case RoomType.lab:
        amenities = {
          'hasEquipment': random.nextBool(),
          'hasProjector': random.nextBool(),
          'hasWhiteboard': true,
          'hasComputers': random.nextBool(),
        };
        break;
      case RoomType.audioVisual:
        amenities = {
          'hasProjector': true,
          'hasAudioSystem': random.nextBool(),
          'hasSoundboard': random.nextBool(),
          'hasScreenShare': true,
          'hasRecording': random.nextBool(),
        };
        break;
      case RoomType.classroom:
        amenities = {
          'hasProjector': true,
          'hasWhiteboard': random.nextBool(),
          'hasSeating': true,
          'hasClimateControl': random.nextBool(),
        };
        break;
      case RoomType.other:
        amenities = {};
        break;
    }

    final newRoom = Room(
      id: 'room_${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      capacity: capacity,
      type: roomType,
      building: building,
      floor: floor ?? '1',
      roomNumber: roomNumber,
      occupancyStatus: OccupancyStatus.available,
      lastUpdated: DateTime.now(),
      amenities: amenities,
    );
    _rooms.add(newRoom);
    notifyListeners();
  }

  /// Delete a room by ID
  void deleteRoom(String roomId) {
    _rooms.removeWhere((room) => room.id == roomId);
    notifyListeners();
  }

  /// Update a room
  void updateRoom({
    required String roomId,
    String? name,
    String? building,
    String? roomNumber,
    int? capacity,
    String? floor,
    RoomType? type,
  }) {
    final index = _rooms.indexWhere((room) => room.id == roomId);
    if (index != -1) {
      _rooms[index] = _rooms[index].copyWith(
        name: name,
        building: building,
        roomNumber: roomNumber,
        capacity: capacity,
        floor: floor,
        type: type,
        lastUpdated: DateTime.now(),
      );
      notifyListeners();
    }
  }
}
