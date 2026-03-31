import 'package:supabase_flutter/supabase_flutter.dart';
import 'supabase_service.dart';
import 'booking_exception.dart';

/// Service for all database operations (separate from authentication)
class DatabaseService {
  static SupabaseClient get _client => SupabaseService.client;

  // ==================== USERS ====================
  
  /// Get user by ID
  static Future<Map<String, dynamic>> getUser(String userId) async {
    try {
      print('📊 [DatabaseService] Fetching user: $userId');
      final response = await _client
          .from('users')
          .select()
          .eq('id', userId)
          .single();
      print('✅ [DatabaseService] User fetched');
      return response;
    } catch (e) {
      print('❌ [DatabaseService] Error fetching user: $e');
      rethrow;
    }
  }

  /// Get user by email
  static Future<Map<String, dynamic>> getUserByEmail(String email) async {
    try {
      print('📊 [DatabaseService] Fetching user by email: $email');
      final response = await _client
          .from('users')
          .select()
          .eq('email', email)
          .single();
      print('✅ [DatabaseService] User fetched by email');
      return response;
    } catch (e) {
      print('❌ [DatabaseService] Error fetching user by email: $e');
      rethrow;
    }
  }

  /// Update user
  static Future<void> updateUser(String userId, Map<String, dynamic> data) async {
    try {
      print('📊 [DatabaseService] Updating user: $userId');
      await _client
          .from('users')
          .update(data)
          .eq('id', userId);
      print('✅ [DatabaseService] User updated');
    } catch (e) {
      print('❌ [DatabaseService] Error updating user: $e');
      rethrow;
    }
  }

  // ==================== ROOMS ====================

  /// Get all rooms
  static Future<List<Map<String, dynamic>>> getAllRooms() async {
    try {
      print('📊 [DatabaseService] Fetching all rooms');
      final response = await _client
          .from('rooms')
          .select()
          .order('room_number');
      print('✅ [DatabaseService] Fetched ${response.length} rooms');
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('❌ [DatabaseService] Error fetching rooms: $e');
      rethrow;
    }
  }

  /// Get room by ID
  static Future<Map<String, dynamic>> getRoom(String roomId) async {
    try {
      print('📊 [DatabaseService] Fetching room: $roomId');
      final response = await _client
          .from('rooms')
          .select()
          .eq('id', roomId)
          .single();
      print('✅ [DatabaseService] Room fetched');
      return response;
    } catch (e) {
      print('❌ [DatabaseService] Error fetching room: $e');
      rethrow;
    }
  }

  /// Get rooms by building
  static Future<List<Map<String, dynamic>>> getRoomsByBuilding(String building) async {
    try {
      print('📊 [DatabaseService] Fetching rooms in building: $building');
      final response = await _client
          .from('rooms')
          .select()
          .eq('building', building)
          .order('room_number');
      print('✅ [DatabaseService] Fetched ${response.length} rooms in $building');
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('❌ [DatabaseService] Error fetching rooms by building: $e');
      rethrow;
    }
  }

  /// Create room (admin only)
  static Future<Map<String, dynamic>> createRoom(Map<String, dynamic> roomData) async {
    try {
      print('📊 [DatabaseService] Creating room');
      final response = await _client
          .from('rooms')
          .insert(roomData)
          .select()
          .single();
      print('✅ [DatabaseService] Room created');
      return response;
    } catch (e) {
      print('❌ [DatabaseService] Error creating room: $e');
      rethrow;
    }
  }

  /// Update room (admin only)
  static Future<void> updateRoom(String roomId, Map<String, dynamic> data) async {
    try {
      print('📊 [DatabaseService] Updating room: $roomId');
      await _client
          .from('rooms')
          .update(data)
          .eq('id', roomId);
      print('✅ [DatabaseService] Room updated');
    } catch (e) {
      print('❌ [DatabaseService] Error updating room: $e');
      rethrow;
    }
  }

  // ==================== BOOKINGS ====================

  /// Get all bookings for user
  static Future<List<Map<String, dynamic>>> getUserBookings(String userId) async {
    try {
      print('📊 [DatabaseService] Fetching bookings for user: $userId');
      final response = await _client
          .from('bookings')
          .select('*, rooms(*)')
          .eq('user_id', userId)
          .order('start_time', ascending: false);
      print('✅ [DatabaseService] Fetched ${response.length} bookings');
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('❌ [DatabaseService] Error fetching user bookings: $e');
      rethrow;
    }
  }

  /// Get all bookings (admin)
  static Future<List<Map<String, dynamic>>> getAllBookings() async {
    try {
      print('📊 [DatabaseService] Fetching all bookings');
      final response = await _client
          .from('bookings')
          .select('*, rooms(*), users(*)')
          .order('start_time', ascending: false);
      print('✅ [DatabaseService] Fetched ${response.length} bookings');
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('❌ [DatabaseService] Error fetching all bookings: $e');
      rethrow;
    }
  }

  /// Get bookings for a room (availability checking)
  static Future<List<Map<String, dynamic>>> getRoomBookings(String roomId, {DateTime? startDate, DateTime? endDate}) async {
    try {
      print('📊 [DatabaseService] Fetching bookings for room: $roomId');
      var query = _client
          .from('bookings')
          .select()
          .eq('room_id', roomId)
          .neq('status', 'cancelled');

      if (startDate != null) {
        query = query.gte('start_time', startDate.toIso8601String());
      }
      if (endDate != null) {
        query = query.lte('end_time', endDate.toIso8601String());
      }

      final response = await query.order('start_time');
      print('✅ [DatabaseService] Fetched ${response.length} bookings for room');
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('❌ [DatabaseService] Error fetching room bookings: $e');
      rethrow;
    }
  }

  /// Create booking with comprehensive error handling and automatic schema detection
  static Future<Map<String, dynamic>> createBooking(Map<String, dynamic> bookingData) async {
    try {
      print('📊 [DatabaseService] Creating booking with data:');
      print('   - Room ID: ${bookingData['room_id']}');
      print('   - User ID: ${bookingData['user_id']}');
      print('   - Start: ${bookingData['start_time']}');
      print('   - End: ${bookingData['end_time']}');
      print('   - Title: ${bookingData['title']}');
      
      // Validate critical booking data before sending
      _validateBookingData(bookingData);
      
      // Build insert data with correct schema fields
      final insertData = {
        'room_id': bookingData['room_id'],
        'user_id': bookingData['user_id'],
        'start_time': bookingData['start_time'],
        'end_time': bookingData['end_time'],
        'title': bookingData['title'],
        if (bookingData.containsKey('description') && bookingData['description'] != null)
          'description': bookingData['description'],
        if (bookingData.containsKey('status') && bookingData['status'] != null)
          'status': bookingData['status'],
      };

      print('   Sending fields: ${insertData.keys.toList()}');
      
      final response = await _client
          .from('bookings')
          .insert(insertData)
          .select()
          .single();
      print('✅ [DatabaseService] Booking created successfully with ID: ${response['id']}');
      return response;
    } catch (e) {
      print('❌ [DatabaseService] Error creating booking: $e');
      throw BookingException.fromError(e);
    }
  }

  /// Validate booking data to catch issues early
  static void _validateBookingData(Map<String, dynamic> data) {
    if (data['room_id'] == null || (data['room_id'] as String).isEmpty) {
      throw BookingException(
        code: 'INVALID_ROOM',
        userMessage: 'Room ID is missing. Please select a room.',
        technicalDetails: 'room_id is null or empty',
      );
    }
    
    if (data['user_id'] == null || (data['user_id'] as String).isEmpty) {
      throw BookingException(
        code: 'INVALID_USER',
        userMessage: 'User ID is missing. Please log in again.',
        technicalDetails: 'user_id is null or empty',
      );
    }
    
    if (data['start_time'] == null) {
      throw BookingException(
        code: 'INVALID_START_TIME',
        userMessage: 'Start time is missing.',
        technicalDetails: 'start_time is null',
      );
    }
    
    if (data['end_time'] == null) {
      throw BookingException(
        code: 'INVALID_END_TIME',
        userMessage: 'End time is missing.',
        technicalDetails: 'end_time is null',
      );
    }
    
    if (data['title'] == null || (data['title'] as String).isEmpty) {
      throw BookingException(
        code: 'INVALID_TITLE',
        userMessage: 'Booking title is missing.',
        technicalDetails: 'title is null or empty',
      );
    }
  }

  /// Cancel booking
  static Future<void> cancelBooking(String bookingId) async {
    try {
      print('📊 [DatabaseService] Cancelling booking: $bookingId');
      await _client
          .from('bookings')
          .update({'status': 'cancelled'})
          .eq('id', bookingId);
      print('✅ [DatabaseService] Booking cancelled');
    } catch (e) {
      print('❌ [DatabaseService] Error cancelling booking: $e');
      rethrow;
    }
  }

  /// Update booking status (admin)
  static Future<void> updateBookingStatus(String bookingId, String status) async {
    try {
      print('📊 [DatabaseService] Updating booking status: $bookingId → $status');
      await _client
          .from('bookings')
          .update({'status': status})
          .eq('id', bookingId);
      print('✅ [DatabaseService] Booking status updated');
    } catch (e) {
      print('❌ [DatabaseService] Error updating booking status: $e');
      rethrow;
    }
  }

  /// Generic booking update (time, purpose, etc.)
  static Future<void> updateBooking(
    String bookingId,
    Map<String, dynamic> updates,
  ) async {
    try {
      print('📊 [DatabaseService] Updating booking: $bookingId with $updates');
      await _client
          .from('bookings')
          .update(updates)
          .eq('id', bookingId);
      print('✅ [DatabaseService] Booking updated');
    } catch (e) {
      print('❌ [DatabaseService] Error updating booking: $e');
      rethrow;
    }
  }

  // ==================== SCHEDULES ====================

  /// Get schedules for a room
  static Future<List<Map<String, dynamic>>> getRoomSchedules(String roomId) async {
    try {
      print('📊 [DatabaseService] Fetching schedules for room: $roomId');
      final response = await _client
          .from('schedules')
          .select()
          .eq('room_id', roomId)
          .order('day_of_week');
      print('✅ [DatabaseService] Fetched ${response.length} schedules');
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('❌ [DatabaseService] Error fetching schedules: $e');
      rethrow;
    }
  }

  /// Get schedule for specific day
  static Future<List<Map<String, dynamic>>> getScheduleByDay(String roomId, String dayOfWeek) async {
    try {
      print('📊 [DatabaseService] Fetching schedule for $dayOfWeek');
      final response = await _client
          .from('schedules')
          .select()
          .eq('room_id', roomId)
          .eq('day_of_week', dayOfWeek);
      print('✅ [DatabaseService] Fetched schedule');
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('❌ [DatabaseService] Error fetching schedule by day: $e');
      rethrow;
    }
  }

  /// Create schedule (admin only)
  static Future<Map<String, dynamic>> createSchedule(Map<String, dynamic> scheduleData) async {
    try {
      print('📊 [DatabaseService] Creating schedule');
      final response = await _client
          .from('schedules')
          .insert(scheduleData)
          .select()
          .single();
      print('✅ [DatabaseService] Schedule created');
      return response;
    } catch (e) {
      print('❌ [DatabaseService] Error creating schedule: $e');
      rethrow;
    }
  }

  /// Update schedule (admin only)
  static Future<void> updateSchedule(String scheduleId, Map<String, dynamic> data) async {
    try {
      print('📊 [DatabaseService] Updating schedule: $scheduleId');
      await _client
          .from('schedules')
          .update(data)
          .eq('id', scheduleId);
      print('✅ [DatabaseService] Schedule updated');
    } catch (e) {
      print('❌ [DatabaseService] Error updating schedule: $e');
      rethrow;
    }
  }

  /// Check room availability
  static Future<bool> isRoomAvailable(
    String roomId,
    DateTime startTime,
    DateTime endTime,
  ) async {
    try {
      print('📊 [DatabaseService] Checking availability for room: $roomId');
      final bookings = await getRoomBookings(
        roomId,
        startDate: startTime,
        endDate: endTime,
      );

      // Filter active bookings that overlap with requested time
      final conflicts = bookings.where((booking) {
        final bookStart = DateTime.parse(booking['start_time']);
        final bookEnd = DateTime.parse(booking['end_time']);
        return !(endTime.isBefore(bookStart) || startTime.isAfter(bookEnd));
      }).toList();

      final available = conflicts.isEmpty;
      print('✅ [DatabaseService] Room availability: $available');
      return available;
    } catch (e) {
      print('❌ [DatabaseService] Error checking availability: $e');
      rethrow;
    }
  }
}
