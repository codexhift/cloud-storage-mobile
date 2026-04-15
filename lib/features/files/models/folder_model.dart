import 'file_model.dart';

class FolderModel {
  final int id;
  final String namaFolder;
  final int? parentId;
  final int idPengguna;
  final bool belongsToSharedFolder;
  final DateTime createdAt;
  final List<FolderModel> children;
  final List<FileModel> files;

  FolderModel({
    required this.id,
    required this.namaFolder,
    this.parentId,
    required this.idPengguna,
    required this.belongsToSharedFolder,
    required this.createdAt,
    this.children = const [],
    this.files = const [],
  });

  factory FolderModel.fromJson(Map<String, dynamic> json) {
    return FolderModel(
      id: json['id'],
      namaFolder: json['nama_folder'] ?? '',
      parentId: json['parent_id'],
      idPengguna: json['id_pengguna'] ?? 0,
      belongsToSharedFolder: json['belongs_to_shared_folder'] ?? false,
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
