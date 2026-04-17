import 'package:flutter/material.dart';
import '../../core/models/user_model.dart';
import '../../core/services/database_service.dart';

/// State provider for users
class UsersProvider with ChangeNotifier {
  List<User> _users = [];
  bool _isLoading = false;

  List<User> get users => _users;
  bool get isLoading => _isLoading;

  /// Load all users from database
  Future<void> loadUsers() async {
    _isLoading = true;
    notifyListeners();

    try {
      print('📱 [UsersProvider] Loading users from database');
      final usersData = await DatabaseService.getAllUsers();
      _users = usersData.map((data) => _mapToUser(data)).toList();
      print('✅ [UsersProvider] Loaded ${_users.length} users');
    } catch (e) {
      print('❌ [UsersProvider] Error loading users: $e');
      _users = [];
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Create new user
  Future<void> createUser(User user) async {
    _isLoading = true;
    notifyListeners();

    try {
      print('📱 [UsersProvider] Creating user: ${user.email}');
      final userData = _mapUserToData(user);
      final response = await DatabaseService.createUser(userData);
      _users.add(user.copyWith(id: response['id']));
      print('✅ [UsersProvider] User created successfully');
    } catch (e) {
      print('❌ [UsersProvider] Error creating user: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Update user
  Future<void> updateUser(String userId, User updated) async {
    _isLoading = true;
    notifyListeners();

    try {
      print('📱 [UsersProvider] Updating user: $userId');
      final updateData = _mapUserToData(updated);
      await DatabaseService.updateUser(userId, updateData);
      final index = _users.indexWhere((u) => u.id == userId);
      if (index != -1) {
        _users[index] = updated;
      }
      print('✅ [UsersProvider] User updated successfully');
    } catch (e) {
      print('❌ [UsersProvider] Error updating user: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Delete user
  Future<void> deleteUser(String userId) async {
    _isLoading = true;
    notifyListeners();

    try {
      print('📱 [UsersProvider] Deleting user: $userId');
      await DatabaseService.deleteUser(userId);
      _users.removeWhere((u) => u.id == userId);
      print('✅ [UsersProvider] User deleted successfully');
    } catch (e) {
      print('❌ [UsersProvider] Error deleting user: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Get user by ID
  User? getUserById(String id) {
    try {
      return _users.firstWhere((u) => u.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Get users by role
  List<User> getUsersByRole(UserRole role) {
    return _users.where((u) => u.role == role).toList();
  }

  /// Search users
  List<User> searchUsers(String query) {
    final lowerQuery = query.toLowerCase();
    return _users.where((user) {
      return user.name.toLowerCase().contains(lowerQuery) ||
          user.email.toLowerCase().contains(lowerQuery) ||
          (user.studentId?.toLowerCase().contains(lowerQuery) ?? false);
    }).toList();
  }

  /// Get active users
  List<User> getActiveUsers() {
    return _users.where((u) => u.isActive).toList();
  }

  /// Helper: Map database data to User model
  User _mapToUser(Map<String, dynamic> data) {
    return User(
      id: data['id'] as String,
      name: data['name'] as String,
      email: data['email'] as String,
      role: _parseRole(data['role'] as String),
      department: data['department'] as String?,
      studentId: data['student_id'] as String?,
      profilePictureUrl: data['profile_picture_url'] as String?,
      createdAt: DateTime.parse(data['created_at'] as String),
      isActive: data['is_active'] as bool? ?? true,
    );
  }

  /// Helper: Map User model to database data
  Map<String, dynamic> _mapUserToData(User user) {
    return {
      'name': user.name,
      'email': user.email,
      'role': user.role.name,
      if (user.department != null) 'department': user.department,
      if (user.studentId != null) 'student_id': user.studentId,
      'is_active': user.isActive,
    };
  }

  /// Helper: Parse role string to enum
  UserRole _parseRole(String role) {
    switch (role.toLowerCase()) {
      case 'teacher':
        return UserRole.teacher;
      case 'admin':
        return UserRole.admin;
      default:
        return UserRole.student;
    }
  }
}

