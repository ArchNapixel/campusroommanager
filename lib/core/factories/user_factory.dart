import 'package:uuid/uuid.dart';
import '../models/user_model.dart';

/// Factory for creating User objects with role presets
class UserFactory {
  static const _uuid = Uuid();

  /// Creates a student user with default settings
  static User createStudent({
    required String name,
    required String email,
    required String studentId,
    String? id,
    String? department,
  }) {
    return User(
      id: id ?? _uuid.v4(),
      name: name,
      email: email,
      role: UserRole.student,
      studentId: studentId,
      department: department,
      createdAt: DateTime.now(),
      isActive: true,
    );
  }

  /// Creates a teacher user with default settings
  static User createTeacher({
    required String name,
    required String email,
    String? id,
    String? department,
  }) {
    return User(
      id: id ?? _uuid.v4(),
      name: name,
      email: email,
      role: UserRole.teacher,
      department: department,
      createdAt: DateTime.now(),
      isActive: true,
    );
  }

  /// Creates an admin user
  static User createAdmin({
    required String name,
    required String email,
    String? id,
    String? department,
  }) {
    return User(
      id: id ?? _uuid.v4(),
      name: name,
      email: email,
      role: UserRole.admin,
      department: department,
      createdAt: DateTime.now(),
      isActive: true,
    );
  }

  /// Creates a custom user with all parameters
  static User createCustom({
    required String name,
    required String email,
    required UserRole role,
    String? id,
    String? department,
    String? studentId,
    bool isActive = true,
  }) {
    return User(
      id: id ?? _uuid.v4(),
      name: name,
      email: email,
      role: role,
      department: department,
      studentId: studentId,
      createdAt: DateTime.now(),
      isActive: isActive,
    );
  }
}
