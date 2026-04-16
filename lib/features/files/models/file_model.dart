class FileModel {
  final int id;
  final String namaTampilan;
  final String namaAsli;
  final String pathStorage;
  final String ekstensi;
  final int ukuran;
  final String ukuranFormat;
  final int idFolder;
  final int idPengguna;
  final bool belongsToSharedFolder;
  final DateTime createdAt;

  FileModel({
    required this.id,
    required this.namaTampilan,
    required this.namaAsli,
    required this.pathStorage,
    required this.ekstensi,
    required this.ukuran,
    required this.ukuranFormat,
    required this.idFolder,
    required this.idPengguna,
    required this.belongsToSharedFolder,
    required this.createdAt,
  });

  factory FileModel.fromJson(Map<String, dynamic> json) {
    return FileModel(
      id: json['id'],
      namaTampilan: json['nama_tampilan'],
      namaAsli: json['nama_asli'] ?? '',
      pathStorage: json['path_storage'] ?? '',
      ekstensi: json['ekstensi'] ?? '',
      ukuran: json['ukuran'] ?? 0,
      ukuranFormat: json['ukuran_format'] ?? '0 B',
      idFolder: json['id_folder'] ?? 0,
      idPengguna: json['id_pengguna'] ?? 0,
      belongsToSharedFolder: json['belongs_to_shared_folder'] ?? false,
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}
