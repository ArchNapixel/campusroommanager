import 'package:flutter/material.dart';
import '../../core/factories/user_factory.dart';
import '../../core/models/user_model.dart';

/// State provider for users
class UsersProvider with ChangeNotifier {
  List<User> _users = [];
  bool _isLoading = false;

  List<User> get users => _users;
  bool get isLoading => _isLoading;

  /// Load all users (mock data)
  Future<void> loadUsers() async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(Duration(milliseconds: 500));

    _users = [
      UserFactory.createStudent(
        name: 'Alice Johnson',
        email: 'alice.johnson@university.edu',
        studentId: 'STU001',
        department: 'Computer Science',
      ),
      UserFactory.createStudent(
        name: 'Bob Smith',
        email: 'bob.smith@university.edu',
        studentId: 'STU002',
        department: 'Physics',
      ),
      UserFactory.createTeacher(
        name: 'Prof. Diana Chen',
        email: 'diana.chen@university.edu',
        department: 'Computer Science',
      ),
      UserFactory.createTeacher(
        name: 'Prof. Edward Martinez',
        email: 'edward.martinez@university.edu',
        department: 'Engineering',
      ),
      UserFactory.createAdmin(
        name: 'Admin User',
        email: 'admin@university.edu',
        department: 'Administration',
      ),
    ];

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
