import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repository/file_repository.dart';
import '../models/file_model.dart';
import '../models/folder_model.dart';

final fileRepositoryProvider = Provider<FileRepository>((ref) {
  return FileRepository();
});

/// Root folders list
final rootFoldersProvider = FutureProvider<List<FolderModel>>((ref) async {
  final repo = ref.read(fileRepositoryProvider);
  return repo.getRootFolders();
});

/// Folder contents by ID
final folderContentsProvider =
    FutureProvider.family<FolderModel, int>((ref, folderId) async {
  final repo = ref.read(fileRepositoryProvider);
  return repo.getFolderContents(folderId);
});

/// Files list with optional folder filter
final filesProvider =
    FutureProvider.family<List<FileModel>, int?>((ref, folderId) async {
  final repo = ref.read(fileRepositoryProvider);
  return repo.getFiles(folderId: folderId);
});

/// Search files
final fileSearchResultsProvider =
    FutureProvider.family<List<FileModel>, String>((ref, query) async {
  final repo = ref.read(fileRepositoryProvider);
  return repo.getFiles(query: query);
});

/// Trash
final trashProvider = FutureProvider<List<FileModel>>((ref) async {
  final repo = ref.read(fileRepositoryProvider);
  return repo.getTrash();
});

/// Folder tree
final folderTreeProvider = FutureProvider<List<FolderModel>>((ref) async {
  final repo = ref.read(fileRepositoryProvider);
  return repo.getFolderTree();
});
