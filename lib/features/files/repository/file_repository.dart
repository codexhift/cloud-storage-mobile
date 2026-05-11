import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import '../../../core/api_client.dart';
import '../models/file_model.dart';
import '../models/folder_model.dart';
import 'dart:developer';

class FileRepository {
  final ApiClient _api = ApiClient();

  // ─── Folders ───────────────────────────────────────────────────────────

  /// GET /folders — List root-level folders
  Future<List<FolderModel>> getRootFolders() async {
    try {
      final response = await _api.dio.get('/v1/folders');
      if (response.statusCode == 200) {
        final data = response.data['data'];
        if (data is List) {
          return data.map((e) => FolderModel.fromJson(e)).toList();
        }
        // If the API returns a single folder object (root container)
        return [FolderModel.fromJson(data)];
      }
      return [];
    } on DioException catch (e) {
      log('getRootFolders failed: ${e.response?.data}');
      throw Exception(
          e.response?.data['message'] ?? 'Failed to fetch folders');
    }
  }

  /// GET /folders/{id} — Get folder content (metadata + subfolders + files)
  Future<FolderModel> getFolderContents(int folderId) async {
    try {
      final response = await _api.dio.get('/v1/folders/$folderId');
      if (response.statusCode == 200) {
        return FolderModel.fromJson(response.data['data']);
      }
      throw Exception('Failed to load folder contents');
    } on DioException catch (e) {
      log('getFolderContents failed: ${e.response?.data}');
      throw Exception(
          e.response?.data['message'] ?? 'Failed to fetch folder');
    }
  }

  /// POST /folders — Create a new folder
  Future<FolderModel> createFolder(String name, {int? parentId}) async {
    try {
      final response = await _api.dio.post(
        '/v1/folders',
        data: {'name': name, 'parent_id': parentId},
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return FolderModel.fromJson(response.data['data']);
      }
      throw Exception('Failed to create folder');
    } on DioException catch (e) {
      log('createFolder failed: ${e.response?.data}');
      final msg = e.response?.data['message'] ?? 'Failed to create folder';
      throw Exception(msg);
    }
  }

  /// PATCH /folders/{id} — Rename a folder
  Future<FolderModel> renameFolder(int folderId, String newName) async {
    try {
      final response = await _api.dio.patch(
        '/v1/folders/$folderId',
        data: {'name': newName},
      );
      if (response.statusCode == 200) {
        return FolderModel.fromJson(response.data['data']);
      }
      throw Exception('Failed to rename folder');
    } on DioException catch (e) {
      log('renameFolder failed: ${e.response?.data}');
      throw Exception(
          e.response?.data['message'] ?? 'Failed to rename folder');
    }
  }

  /// DELETE /folders/{id} — Move folder to trash
  Future<void> deleteFolder(int folderId) async {
    try {
      await _api.dio.delete('/v1/folders/$folderId');
    } on DioException catch (e) {
      log('deleteFolder failed: ${e.response?.data}');
      throw Exception(
          e.response?.data['message'] ?? 'Failed to delete folder');
    }
  }

  /// GET /folders/tree — Full nested folder tree
  Future<List<FolderModel>> getFolderTree() async {
    try {
      final response = await _api.dio.get('/v1/folders/tree');
      if (response.statusCode == 200) {
        final data = response.data['data'];
        if (data is List) {
          return data.map((e) => FolderModel.fromJson(e)).toList();
        }
        return [];
      }
      return [];
    } on DioException catch (e) {
      log('getFolderTree failed: ${e.response?.data}');
      throw Exception(
          e.response?.data['message'] ?? 'Failed to fetch folder tree');
    }
  }

  // ─── Files ─────────────────────────────────────────────────────────────

  /// GET /files — List files with optional filters
  Future<List<FileModel>> getFiles({
    int? folderId,
    String? query,
    String? sort,
  }) async {
    try {
      final params = <String, dynamic>{};
      if (folderId != null) params['folder_id'] = folderId;
      if (query != null && query.isNotEmpty) params['q'] = query;
      if (sort != null) params['sort'] = sort;

      final response = await _api.dio.get(
        '/v1/files',
        queryParameters: params,
      );
      if (response.statusCode == 200) {
        final List data = response.data['data'] ?? [];
        return data.map((json) => FileModel.fromJson(json)).toList();
      }
      return [];
    } on DioException catch (e) {
      log('getFiles failed: ${e.response?.data}');
      throw Exception(
          e.response?.data['message'] ?? 'Failed to fetch files');
    }
  }

  /// POST /files — Upload a file (multipart, max 100MB)
  Future<FileModel> uploadFile(PlatformFile file, {int? folderId}) async {
    try {
      final formData = FormData.fromMap({
        'file': MultipartFile.fromBytes(
          file.bytes!,
          filename: file.name,
        ),
        if (folderId != null) 'folder_id': folderId,
      });

      final response = await _api.dio.post(
        '/v1/files',
        data: formData,
        options: Options(
          contentType: 'multipart/form-data',
          sendTimeout: const Duration(minutes: 5),
          receiveTimeout: const Duration(minutes: 5),
        ),
        onSendProgress: (sent, total) {
          final pct = (sent / total * 100).toStringAsFixed(0);
          log('Upload progress: $pct%');
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return FileModel.fromJson(response.data['data']);
      }
      throw Exception('Upload failed');
    } on DioException catch (e) {
      log('uploadFile failed: ${e.response?.data}');
      final statusCode = e.response?.statusCode;
      if (statusCode == 422) {
        final msg = e.response?.data['message'] ?? 'Kuota penyimpanan penuh.';
        throw Exception(msg);
      }
      throw Exception(
          e.response?.data['message'] ?? 'Failed to upload file');
    }
  }

  /// GET /files/{id}/download — Download file stream URL
  String getDownloadUrl(int fileId) {
    return '${_api.dio.options.baseUrl}/v1/files/$fileId/download';
  }

  /// POST /files/{id}/star — Toggle starred status
  Future<FileModel> toggleStar(int fileId) async {
    try {
      final response = await _api.dio.post('/v1/files/$fileId/star');
      if (response.statusCode == 200) {
        return FileModel.fromJson(response.data['data']);
      }
      throw Exception('Failed to toggle star');
    } on DioException catch (e) {
      log('toggleStar failed: ${e.response?.data}');
      throw Exception(
          e.response?.data['message'] ?? 'Failed to star/unstar file');
    }
  }

  /// POST /files/{id}/share — Get shareable URL
  Future<String> shareFile(int fileId) async {
    try {
      final response = await _api.dio.post('/v1/files/$fileId/share');
      if (response.statusCode == 200) {
        return response.data['data']['url'] ??
            response.data['data']['share_url'] ??
            '';
      }
      throw Exception('Failed to share file');
    } on DioException catch (e) {
      log('shareFile failed: ${e.response?.data}');
      throw Exception(
          e.response?.data['message'] ?? 'Failed to share file');
    }
  }

  // ─── Trash ─────────────────────────────────────────────────────────────

  /// GET /files/trash — List trashed files/folders
  Future<List<FileModel>> getTrash() async {
    try {
      final response = await _api.dio.get('/v1/files/trash');
      if (response.statusCode == 200) {
        final List data = response.data['data'] ?? [];
        return data.map((json) => FileModel.fromJson(json)).toList();
      }
      return [];
    } on DioException catch (e) {
      log('getTrash failed: ${e.response?.data}');
      throw Exception(
          e.response?.data['message'] ?? 'Failed to fetch trash');
    }
  }

  /// POST /files/{id}/restore — Restore from trash
  Future<void> restoreFile(int fileId) async {
    try {
      await _api.dio.post('/v1/files/$fileId/restore');
    } on DioException catch (e) {
      log('restoreFile failed: ${e.response?.data}');
      throw Exception(
          e.response?.data['message'] ?? 'Failed to restore file');
    }
  }

  /// DELETE /files/{id}/permanent — Permanently delete and free quota
  Future<void> permanentDelete(int fileId) async {
    try {
      await _api.dio.delete('/v1/files/$fileId/permanent');
    } on DioException catch (e) {
      log('permanentDelete failed: ${e.response?.data}');
      throw Exception(
          e.response?.data['message'] ?? 'Failed to permanently delete file');
    }
  }
}
