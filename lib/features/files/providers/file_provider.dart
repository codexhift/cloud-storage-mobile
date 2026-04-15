import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repository/file_repository.dart';
import '../models/file_model.dart';
import '../models/folder_model.dart';

final fileRepositoryProvider = Provider<FileRepository>((ref) {
  return FileRepository();
});

final recentFilesProvider = FutureProvider<List<FileModel>>((ref) async {
  final repo = ref.read(fileRepositoryProvider);
  return repo.getRecentFiles();
});

final rootFolderProvider = FutureProvider<FolderModel>((ref) async {
  final repo = ref.read(fileRepositoryProvider);
  return repo.getRootFolders();
});

final folderContentsProvider = FutureProvider.family<FolderModel, int>((ref, folderId) async {
  final repo = ref.read(fileRepositoryProvider);
  return repo.getFolderContents(folderId);
});
