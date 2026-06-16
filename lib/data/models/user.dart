// models/user.dart
class UserModel {
  final String id;
  final String email;
  final String name;
  final String role; // 'parent' | 'doctor' | 'therapist'
  final String? phone;
  final String? nationalId;
  final String? profileImage;
  final String createdAt;

  const UserModel({
    required this.id,
    required this.email,
    required this.name,
    required this.role,
    this.phone,
    this.nationalId,
    this.profileImage,
    required this.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    final rawRole = ((json['role'] ?? '') as String).toLowerCase();
    final role = rawRole == 'specialist' ? 'doctor' : rawRole;
    return UserModel(
      id: (json['id'] ?? json['userId'] ?? '').toString(),
      email: (json['email'] ?? '').toString(),
      name: (json['name'] ?? json['fullName'] ?? '').toString(),
      role: role.isEmpty ? 'parent' : role,
      phone: json['phone']?.toString() ?? json['phoneNumber']?.toString(),
      nationalId: json['nationalId']?.toString() ?? json['national_id']?.toString(),
      profileImage: json['profileImage']?.toString() ??
          json['profile_image']?.toString() ??
          json['profilePictureUrl']?.toString(),
      createdAt: (json['createdAt'] ?? DateTime.now().toIso8601String()).toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'email': email,
        'name': name,
        'role': role,
        'phone': phone,
        'nationalId': nationalId,
        'profileImage': profileImage,
        'createdAt': createdAt,
      };

  UserModel copyWith({
    String? id,
    String? email,
    String? name,
    String? role,
    String? phone,
    String? nationalId,
    String? profileImage,
    String? createdAt,
  }) =>
      UserModel(
        id: id ?? this.id,
        email: email ?? this.email,
        name: name ?? this.name,
        role: role ?? this.role,
        phone: phone ?? this.phone,
        nationalId: nationalId ?? this.nationalId,
        profileImage: profileImage ?? this.profileImage,
        createdAt: createdAt ?? this.createdAt,
      );
}

class AuthResponse {
  final String token;
  final UserModel user;

  const AuthResponse({required this.token, required this.user});

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    final rawUser = (json['user'] ?? json) as Map<String, dynamic>;
    return AuthResponse(
      token: (json['token'] ?? '').toString(),
      user: UserModel.fromJson(rawUser),
    );
  }
}
