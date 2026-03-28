import 'dart:io';
import 'supabase_service.dart';

/// Service for handling Supabase Storage operations (profile pictures, room images, etc.)
class StorageService {
  static const String _profilesBucket = 'profiles';
  static const String _roomsBucket = 'rooms';

  /// Upload a profile picture for a user
  /// Returns the public URL of the uploaded image
  static Future<String> uploadProfilePicture(
    String userId,
    File imageFile,
  ) async {
    try {
      print('📸 [StorageService] Uploading profile picture for user: $userId');

      // Generate unique filename with timestamp
      final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
      final filePath = '$userId/$fileName';

      // Upload to Supabase Storage
      await SupabaseService.client.storage
          .from(_profilesBucket)
          .upload(filePath, imageFile);

      print('✅ [StorageService] Profile picture uploaded: $filePath');

      // Get public URL
      final publicUrl = SupabaseService.client.storage
          .from(_profilesBucket)
          .getPublicUrl(filePath);

      print('📱 [StorageService] Public URL: $publicUrl');

      // Update user profile in database
      await _updateUserProfilePicture(userId, publicUrl);

      return publicUrl;
    } catch (e) {
      print('❌ [StorageService] Upload failed: $e');
      rethrow;
    }
  }

  /// Delete previous profile picture before uploading a new one
  static Future<void> deleteProfilePicture(String userId) async {
    try {
      print('🗑️  [StorageService] Deleting previous profile pictures for user: $userId');

      // List all files in user's folder
      final files = await SupabaseService.client.storage
          .from(_profilesBucket)
          .list(path: userId);

      // Delete each file
      for (final file in files) {
        await SupabaseService.client.storage
            .from(_profilesBucket)
            .remove(['$userId/${file.name}']);
      }

      print('✅ [StorageService] Previous profile pictures deleted');
    } catch (e) {
      print('⚠️  [StorageService] Error deleting previous pictures: $e');
      // Don't rethrow - this is not critical
    }
  }

  /// Upload a room image
  static Future<String> uploadRoomImage(
    String roomId,
    File imageFile,
  ) async {
    try {
      print('📸 [StorageService] Uploading room image for room: $roomId');

      final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
      final filePath = '$roomId/$fileName';

      await SupabaseService.client.storage
          .from(_roomsBucket)
          .upload(filePath, imageFile);

      print('✅ [StorageService] Room image uploaded: $filePath');

      final publicUrl = SupabaseService.client.storage
          .from(_roomsBucket)
          .getPublicUrl(filePath);

      // Update room in database
      await _updateRoomImage(roomId, publicUrl);

      return publicUrl;
    } catch (e) {
      print('❌ [StorageService] Room image upload failed: $e');
      rethrow;
    }
  }

  /// Get public URL for a file
  static String getPublicUrl(String bucket, String filePath) {
    return SupabaseService.client.storage
        .from(bucket)
        .getPublicUrl(filePath);
  }

  // Private helper methods

  /// Update user profile picture URL in database
  static Future<void> _updateUserProfilePicture(
    String userId,
    String imageUrl,
  ) async {
    try {
      await SupabaseService.client
          .from('users')
          .update({'profile_picture_url': imageUrl}).eq('id', userId);

      print('✅ [StorageService] User profile picture URL updated in database');
    } catch (e) {
      print('❌ [StorageService] Failed to update user profile picture URL: $e');
      rethrow;
    }
  }

  /// Update room image URL in database
  static Future<void> _updateRoomImage(
    String roomId,
    String imageUrl,
  ) async {
    try {
      await SupabaseService.client
          .from('rooms')
          .update({'image_url': imageUrl}).eq('id', roomId);

      print('✅ [StorageService] Room image URL updated in database');
    } catch (e) {
      print('❌ [StorageService] Failed to update room image URL: $e');
      rethrow;
    }
  }
}
