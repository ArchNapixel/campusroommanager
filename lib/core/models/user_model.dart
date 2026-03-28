enum UserRole { student, teacher, admin }

class User {
  final String id;
  final String name;
  final String email;
  final UserRole role;
  final String? department;
  final String? studentId; // for students
  final String? profilePictureUrl; // URL to profile picture in Supabase Storage
  final DateTime createdAt;
  final bool isActive;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.department,
    this.studentId,
    this.profilePictureUrl,
    required this.createdAt,
    this.isActive = true,
  });

  User copyWith({
    String? id,
    String? name,
    String? email,
    UserRole? role,
    String? department,
    String? studentId,
    String? profilePictureUrl,
    DateTime? createdAt,
    bool? isActive,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      department: department ?? this.department,
      studentId: studentId ?? this.studentId,
      profilePictureUrl: profilePictureUrl ?? this.profilePictureUrl,
      createdAt: createdAt ?? this.createdAt,
      isActive: isActive ?? this.isActive,
    );
  }

  String get roleDisplayName {
    switch (role) {
      case UserRole.student:
        return 'Student';
      case UserRole.teacher:
        return 'Teacher';
      case UserRole.admin:
        return 'Administrator';
    }
  }

  @override
  String toString() => 'User(id: $id, name: $name, role: ${role.name})';
}
