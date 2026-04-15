import 'package:dio/dio.dart';
import '../../../core/api_client.dart';
import '../models/file_model.dart';
import '../models/folder_model.dart';
import 'dart:developer';

class FileRepository {
  final ApiClient _api = ApiClient();

  Future<List<FileModel>> getRecentFiles() async {
    try {
      final response = await _api.dio.get('/files/recent');
      if (response.statusCode == 200) {
        final List data = response.data['data'] ?? [];
        return data.map((json) => FileModel.fromJson(json)).toList();
      }
      return [];
    } on DioException catch (e) {
      log('GetRecentFiles failed: ${e.response?.data}');
      throw Exception(e.response?.data['message'] ?? 'Failed to fetch recent files');
    }
  }

  Future<FolderModel> getRootFolders() async {
    try {
      final response = await _api.dio.get('/folders');
      if (response.statusCode == 200) {
        return FolderModel.fromJson(response.data['data']);
      }
      throw Exception('Failed to load folders');
    } on DioException catch (e) {
      log('GetRootFolders failed: ${e.response?.data}');
      throw Exception(e.response?.data['message'] ?? 'Failed to fetch folders');
    }
  }

  Future<FolderModel> getFolderContents(int folderId) async {
    try {
      final response = await _api.dio.get('/folders/$folderId');
      if (response.statusCode == 200) {
        return FolderModel.fromJson(response.data['data']);
      }
      throw Exception('Failed to load folder contents');
    } on DioException catch (e) {
      log('GetFolderContents failed: ${e.response?.data}');
      throw Exception(e.response?.data['message'] ?? 'Failed to fetch folder');
    }
  }
}
