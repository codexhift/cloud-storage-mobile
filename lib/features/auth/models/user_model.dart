class UserModel {
  final int id;
  final String name;
  final String email;
  final int storageQuota;
  final int storageUsed;
  final String? profilePhotoUrl;
  final DateTime createdAt;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.storageQuota,
    required this.storageUsed,
    this.profilePhotoUrl,
    required this.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      storageQuota: json['storage_quota'] ?? 1073741824, // 1GB default
      storageUsed: json['storage_used'] ?? 0,
      profilePhotoUrl: json['profile_photo_url'],
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
      'profile_photo_url': profilePhotoUrl,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
