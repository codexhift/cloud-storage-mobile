class FileModel {
  final int id;
  final String name;
  final String originalName;
  final String storagePath;
  final String extension;
  final int size;
  final String sizeFormatted;
  final int? folderId;
  final int userId;
  final bool isStarred;
  final String? shareUrl;
  final DateTime? deletedAt;
  final DateTime createdAt;

  FileModel({
    required this.id,
    required this.name,
    required this.originalName,
    required this.storagePath,
    required this.extension,
    required this.size,
    required this.sizeFormatted,
    this.folderId,
    required this.userId,
    this.isStarred = false,
    this.shareUrl,
    this.deletedAt,
    required this.createdAt,
  });

  factory FileModel.fromJson(Map<String, dynamic> json) {
    return FileModel(
      id: json['id'],
      // Support both Indonesian field names (legacy) and English field names
      name: json['name'] ?? json['nama_tampilan'] ?? '',
      originalName: json['original_name'] ?? json['nama_asli'] ?? '',
      storagePath: json['storage_path'] ?? json['path_storage'] ?? '',
      extension: json['extension'] ?? json['ekstensi'] ?? '',
      size: json['size'] ?? json['ukuran'] ?? 0,
      sizeFormatted: json['size_formatted'] ?? json['ukuran_format'] ?? '0 B',
      folderId: json['folder_id'] ?? json['id_folder'],
      userId: json['user_id'] ?? json['id_pengguna'] ?? 0,
      isStarred: json['is_starred'] ?? false,
      shareUrl: json['share_url'],
      deletedAt: json['deleted_at'] != null
          ? DateTime.tryParse(json['deleted_at'])
          : null,
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}
