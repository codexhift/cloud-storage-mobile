class UserModel {
  final int id;
  final String name;
  final String email;
  final int storageQuota;
  final int storageUsed;
  final String? avatar;
  final String? googleId;
  final DateTime createdAt;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.storageQuota,
    required this.storageUsed,
    this.avatar,
    this.googleId,
    required this.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      storageQuota: json['storage_quota'] ?? 5368709120, // 5GB default
      storageUsed: json['storage_used'] ?? 0,
      avatar: json['avatar'] ?? json['profile_photo_url'],
      googleId: json['google_id'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'storage_quota': storageQuota,
      'storage_used': storageUsed,
      'avatar': avatar,
      'google_id': googleId,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
