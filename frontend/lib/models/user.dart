enum UserRole { 
  FieldEngineer, 
  HSESupervisor, 
  OpsManager, 
  HRAdmin, 
  Admin, 
  Employee 
}

UserRole parseUserRole(String? role) {
  switch (role?.toLowerCase()) {
    case 'fieldengineer':
    case 'field_engineer':
      return UserRole.FieldEngineer;
    case 'hsesupervisor':
    case 'hse_supervisor':
      return UserRole.HSESupervisor;
    case 'opsmanager':
    case 'ops_manager':
      return UserRole.OpsManager;
    case 'hradmin':
    case 'hr_admin':
      return UserRole.HRAdmin;
    case 'admin':
      return UserRole.Admin;
    case 'employee':
      return UserRole.Employee;
    default:
      return UserRole.Employee;
  }
}

class User {
  final int userID;
  final String name;
  final String email;
  final UserRole role;
  final String department;
  final String avatarURL;
  final DateTime createdAt;
  final String status;

  User({
    required this.userID,
    required this.name,
    required this.email,
    required this.role,
    required this.department,
    required this.avatarURL,
    required this.createdAt,
    required this.status,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
        userID: json['userID'] ?? 0,
        name: json['name'] ?? '',
        email: json['email'] ?? '',
        role: parseUserRole(json['role']),
        department: json['department'] ?? '',
        avatarURL: json['avatarURL'] ?? '', 
        createdAt: (json['createdAt'] != null && json['createdAt'].toString().isNotEmpty)
            ? DateTime.parse(json['createdAt'])
            : DateTime.now(),
        status: json['status'] ?? 'active',
      );

  Map<String, dynamic> toJson() => {
        'userID': userID,
        'name': name,
        'email': email,
        'role': role.name,
        'department': department,
        'avatarURL': avatarURL,
        'createdAt': createdAt.toIso8601String(),
        'status': status,
      };
}
