import 'package:flutter/material.dart';
import '../../core/services/database_service.dart';
import '../../core/models/room_model.dart';

/// Provider for managing rooms and availability
class RoomsProvider with ChangeNotifier {
  List<Map<String, dynamic>> _rooms = [];
  Map<String, dynamic>? _selectedRoom;
  String? _errorMessage;
  bool _isLoading = false;
  List<Map<String, dynamic>> _roomBookings = [];

  // Getters
  List<Map<String, dynamic>> get rooms => _rooms;
  Map<String, dynamic>? get selectedRoom => _selectedRoom;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _isLoading;
  List<Map<String, dynamic>> get roomBookings => _roomBookings;

  /// Convert Maps to Room models
  List<Room> get roomsAsModels =>
      _rooms.map((r) => _mapToRoom(r)).toList();
  Map<String, Room> get roomsMapAsModels {
    final map = <String, Room>{};
    for (var room in _rooms) {
      final id = room['id'] as String;
      map[id] = _mapToRoom(room);
    }
    return map;
  }

  /// Helper to convert Map to Room model
  Room _mapToRoom(Map<String, dynamic> data) {
    RoomType typeFromString(String type) {
      switch (type.toLowerCase()) {
        case 'lab':
          return RoomType.lab;
        case 'av_room':
        case 'audiovisual':
        case 'audio_visual':
          return RoomType.audioVisual;
        case 'classroom':
          return RoomType.classroom;
        default:
          return RoomType.other;
      }
    }

    return Room(
      id: data['id'] ?? '',
      name: data['description'] ?? data['name'] ?? '',
      capacity: data['capacity'] ?? 0,
      type: typeFromString(data['room_type'] ?? data['type'] ?? 'other'),
      building: data['building'] ?? '',
      floor: '1', // Floor not in database, default to 1
      roomNumber: data['room_number'] ?? '',
      occupancyStatus: OccupancyStatus.available, // Default to available
      lastUpdated: data['updated_at'] != null 
          ? DateTime.parse(data['updated_at'])
          : DateTime.now(),
      amenities: data['amenities'] ?? {},
      latitude: data['latitude'] as double?,
      longitude: data['longitude'] as double?,
    );
  }

  /// Load all rooms
  Future<void> loadRooms() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _rooms = await DatabaseService.getAllRooms();
      print('✅ [RoomsProvider] Loaded ${_rooms.length} rooms');
    } catch (e) {
      _errorMessage = e.toString();
      print('❌ [RoomsProvider] Error loading rooms: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Load rooms by building
  Future<void> loadRoomsByBuilding(String building) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _rooms = await DatabaseService.getRoomsByBuilding(building);
      print('✅ [RoomsProvider] Loaded ${_rooms.length} rooms from $building');
    } catch (e) {
      _errorMessage = e.toString();
      print('❌ [RoomsProvider] Error loading rooms: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Get room details
  Future<void> selectRoom(String roomId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _selectedRoom = await DatabaseService.getRoom(roomId);
      // Also load bookings for this room
      _roomBookings = await DatabaseService.getRoomBookings(roomId);
      print('✅ [RoomsProvider] Selected room: $roomId');
    } catch (e) {
      _errorMessage = e.toString();
      print('❌ [RoomsProvider] Error selecting room: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Check room availability
  Future<bool> checkAvailability(
    String roomId,
    DateTime startTime,
    DateTime endTime,
  ) async {
    try {
      return await DatabaseService.isRoomAvailable(roomId, startTime, endTime);
    } catch (e) {
      _errorMessage = e.toString();
      print('❌ [RoomsProvider] Error checking availability: $e');
      return false;
    }
  }

  /// Get available buildings (distinct)
  List<String> getBuildings() {
    final buildings = <String>{};
    for (var room in _rooms) {
      buildings.add(room['building'] as String);
    }
    return buildings.toList()..sort();
  }

  /// Filter rooms by capacity
  List<Map<String, dynamic>> filterByCapacity(int minCapacity) {
    return _rooms.where((room) => (room['capacity'] as int) >= minCapacity).toList();
  }

  /// Get room status
  String getRoomStatus(String roomId) {
    try {
      final room = _rooms.firstWhere((r) => r['id'] == roomId);
      return room['status'] as String? ?? 'available';
    } catch (e) {
      return 'unknown';
    }
  }

  /// Clear selection
  void clearSelection() {
    _selectedRoom = null;
    _roomBookings = [];
    _errorMessage = null;
    notifyListeners();
  }

  /// Create new room with comprehensive error handling
  Future<bool> createRoom(Map<String, dynamic> roomData) async {
    _errorMessage = null;
    notifyListeners();

    try {
      print('📱 [RoomsProvider] Creating new room');
      
      // Validate required fields
      if (!roomData.containsKey('description') || (roomData['description'] as String).isEmpty) {
        _errorMessage = 'Room name is required';
        print('❌ [RoomsProvider] Validation error: ${_errorMessage}');
        notifyListeners();
        return false;
      }

      if (!roomData.containsKey('building') || (roomData['building'] as String).isEmpty) {
        _errorMessage = 'Building name is required';
        print('❌ [RoomsProvider] Validation error: ${_errorMessage}');
        notifyListeners();
        return false;
      }

      if (!roomData.containsKey('room_number') || (roomData['room_number'] as String).isEmpty) {
        _errorMessage = 'Room number is required';
        print('❌ [RoomsProvider] Validation error: ${_errorMessage}');
        notifyListeners();
        return false;
      }

      if (!roomData.containsKey('capacity') || roomData['capacity'] == null) {
        _errorMessage = 'Capacity is required';
        print('❌ [RoomsProvider] Validation error: ${_errorMessage}');
        notifyListeners();
        return false;
      }

      // Validate capacity is positive number
      final capacity = roomData['capacity'] as int;
      if (capacity <= 0) {
        _errorMessage = 'Capacity must be greater than 0';
        print('❌ [RoomsProvider] Validation error: ${_errorMessage}');
        notifyListeners();
        return false;
      }

      // Validate room name length
      final roomName = roomData['description'] as String;
      if (roomName.length > 255) {
        _errorMessage = 'Room name must be less than 255 characters';
        print('❌ [RoomsProvider] Validation error: ${_errorMessage}');
        notifyListeners();
        return false;
      }

      // Validate room number format (alphanumeric)
      final roomNumber = roomData['room_number'] as String;
      if (!RegExp(r'^[a-zA-Z0-9\-\s]+$').hasMatch(roomNumber)) {
        _errorMessage = 'Room number can only contain letters, numbers, hyphens and spaces';
        print('❌ [RoomsProvider] Validation error: ${_errorMessage}');
        notifyListeners();
        return false;
      }

      // Validate room type
      final roomType = roomData['room_type'] as String?;
      if (roomType == null || roomType.isEmpty) {
        _errorMessage = 'Room type is required';
        print('❌ [RoomsProvider] Validation error: ${_errorMessage}');
        notifyListeners();
        return false;
      }

      final validTypes = ['classroom', 'lab', 'audiovisual', 'other'];
      if (!validTypes.contains(roomType.toLowerCase())) {
        _errorMessage = 'Invalid room type: $roomType';
        print('❌ [RoomsProvider] Validation error: ${_errorMessage}');
        notifyListeners();
        return false;
      }

      // Check for duplicate room in building
      final building = roomData['building'] as String;
      final existingRoom = _rooms.firstWhere(
        (room) => 
          room['building'] == building && 
          room['room_number'] == roomNumber,
        orElse: () => {},
      );

      if (existingRoom.isNotEmpty) {
        _errorMessage = 'A room with this number already exists in $building';
        print('❌ [RoomsProvider] Duplicate room error: ${_errorMessage}');
        notifyListeners();
        return false;
      }

      // Attempt database creation
      await DatabaseService.createRoom(roomData);
      
      // Reload rooms to refresh list
      await loadRooms();
      
      print('✅ [RoomsProvider] Room created successfully: ${roomData['description']}');
      return true;
      
    } on FormatException catch (e) {
      _errorMessage = 'Invalid input format: ${e.message}';
      print('❌ [RoomsProvider] Format error: $e');
      notifyListeners();
      return false;
    } on Exception catch (e) {
      // Parse database-specific errors
      final errorStr = e.toString();
      
      if (errorStr.contains('unique constraint')) {
        _errorMessage = 'Room already exists (duplicate entry)';
      } else if (errorStr.contains('foreign key')) {
        _errorMessage = 'Invalid building or relationship error';
      } else if (errorStr.contains('permission')) {
        _errorMessage = 'You do not have permission to create rooms';
      } else if (errorStr.contains('connection') || errorStr.contains('network')) {
        _errorMessage = 'Network error: Please check your connection';
      } else if (errorStr.contains('timeout')) {
        _errorMessage = 'Request timed out: Please try again';
      } else {
        _errorMessage = 'Error creating room: $errorStr';
      }
      
      print('❌ [RoomsProvider] Error creating room: $e');
      notifyListeners();
      return false;
    }
  }

  /// Update existing room
  Future<bool> updateRoom(String roomId, Map<String, dynamic> updates) async {
    _errorMessage = null;
    notifyListeners();

    try {
      print('📱 [RoomsProvider] Updating room: $roomId');
      await DatabaseService.updateRoom(roomId, updates);
      // Reload rooms to refresh
      await loadRooms();
      print('✅ [RoomsProvider] Room updated successfully');
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      print('❌ [RoomsProvider] Error updating room: $e');
      return false;
    }
  }

  /// Delete room
  Future<bool> deleteRoom(String roomId) async {
    _errorMessage = null;
    notifyListeners();

    try {
      print('📱 [RoomsProvider] Deleting room: $roomId');
      // Remove from local list
      _rooms.removeWhere((r) => r['id'] == roomId);
      // TODO: Add database delete operation when available
      // await DatabaseService.deleteRoom(roomId);
      print('✅ [RoomsProvider] Room deleted successfully');
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      print('❌ [RoomsProvider] Error deleting room: $e');
      return false;
    }
  }
}
