import 'file_model.dart';

class FolderModel {
  final int id;
  final String name;
  final int? parentId;
  final int userId;
  final DateTime createdAt;
  final List<FolderModel> children;
  final List<FileModel> files;

  FolderModel({
    required this.id,
    required this.name,
    this.parentId,
    required this.userId,
    required this.createdAt,
    this.children = const [],
    this.files = const [],
  });

  factory FolderModel.fromJson(Map<String, dynamic> json) {
    return FolderModel(
      id: json['id'],
      // Support both Indonesian (legacy) and English field names
      name: json['name'] ?? json['nama_folder'] ?? '',
      parentId: json['parent_id'],
      userId: json['user_id'] ?? json['id_pengguna'] ?? 0,
      createdAt: DateTime.parse(json['created_at']),
      children: (json['children'] as List<dynamic>?)
              ?.map((e) => FolderModel.fromJson(e))
              .toList() ??
          [],
      files: (json['files'] as List<dynamic>?)
              ?.map((e) => FileModel.fromJson(e))
              .toList() ??
          [],
    );
  }
}
