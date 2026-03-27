import 'package:flutter/material.dart';
import '../../core/factories/user_factory.dart';
import '../../core/models/user_model.dart';

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
      // TODO: Fetch users from database/API
      _users = [];
    } catch (e) {
      print('Error loading users: $e');
      _users = [];
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Create new user
  Future<void> createUser(User user) async {
    _users.add(user);
    notifyListeners();
    // TODO: Persist to backend
  }

  /// Update user
  Future<void> updateUser(String userId, User updated) async {
    final index = _users.indexWhere((u) => u.id == userId);
    if (index != -1) {
      _users[index] = updated;
      notifyListeners();
    }
    // TODO: Persist to backend
  }

  /// Delete user
  Future<void> deleteUser(String userId) async {
    _users.removeWhere((u) => u.id == userId);
    notifyListeners();
    // TODO: Persist to backend
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
}
