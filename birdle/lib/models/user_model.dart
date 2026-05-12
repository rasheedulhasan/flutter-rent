/// User model representing the authenticated user.
class UserModel {
  final String id;
  final String name;
  final String fullName;
  final String email;
  final String phone;
  final String avatarUrl;
  final String role;
  final DateTime joinedAt;

  UserModel({
    required this.id,
    required this.name,
    required this.fullName,
    required this.email,
    required this.phone,
    required this.avatarUrl,
    required this.role,
    required this.joinedAt,
  });

  /// Creates a [UserModel] from the API response JSON.
  /// The API returns the user object inside the `data.user` path,
  /// but this factory handles a direct user map as well.
  factory UserModel.fromJson(Map<String, dynamic> json) {
    // Support both `full_name` and `fullName` field names from the API
    final fullName = (json['full_name'] ?? json['fullName'] ?? json['name'] ?? '').toString();
    return UserModel(
      id: (json['id'] ?? json['_id'] ?? '').toString(),
      name: json['name'] as String? ?? fullName,
      fullName: fullName,
      email: json['email'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      avatarUrl: json['avatarUrl'] as String? ?? json['avatar'] as String? ?? '',
      role: json['role'] as String? ?? 'user',
      joinedAt: DateTime.tryParse(json['joinedAt'] as String? ?? json['createdAt'] as String? ?? '') ?? DateTime.now(),
    );
  }

  /// Serializes the model to a JSON map.
  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'full_name': fullName,
        'email': email,
        'phone': phone,
        'avatarUrl': avatarUrl,
        'role': role,
        'joinedAt': joinedAt.toIso8601String(),
      };

  /// Returns the initials derived from [fullName].
  String get initials {
    final parts = fullName.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
    }
    if (parts.length == 1 && parts.first.isNotEmpty) {
      return parts.first[0].toUpperCase();
    }
    return '?';
  }
}
