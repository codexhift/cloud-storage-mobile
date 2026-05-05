import 'package:dio/dio.dart';
import '../../../core/api_client.dart';
import 'dart:developer';

/// Storage breakdown model from GET /api/v1/user/storage
class StorageInfo {
  final int totalUsed;
  final int totalQuota;
  final String totalUsedFormatted;
  final String totalQuotaFormatted;
  final double percentUsed;
  final Map<String, CategoryInfo> categories;

  StorageInfo({
    required this.totalUsed,
    required this.totalQuota,
    required this.totalUsedFormatted,
    required this.totalQuotaFormatted,
    required this.percentUsed,
    required this.categories,
  });

  factory StorageInfo.fromJson(Map<String, dynamic> json) {
    final cats = <String, CategoryInfo>{};
    final breakdown = json['breakdown'] ?? json['categories'] ?? {};
    if (breakdown is Map) {
      breakdown.forEach((key, val) {
        if (val is Map<String, dynamic>) {
          cats[key.toString()] = CategoryInfo.fromJson(val);
        }
      });
    }

    return StorageInfo(
      totalUsed: json['total_used'] ?? json['storage_used'] ?? 0,
      totalQuota: json['total_quota'] ?? json['storage_quota'] ?? 0,
      totalUsedFormatted: json['total_used_formatted'] ?? '',
      totalQuotaFormatted: json['total_quota_formatted'] ?? '',
      percentUsed: (json['percent_used'] ?? 0).toDouble(),
      categories: cats,
    );
  }
}

class CategoryInfo {
  final int size;
  final String sizeFormatted;
  final int count;
  final double percent;

  CategoryInfo({
    required this.size,
    required this.sizeFormatted,
    required this.count,
    required this.percent,
  });

  factory CategoryInfo.fromJson(Map<String, dynamic> json) {
    return CategoryInfo(
      size: json['size'] ?? 0,
      sizeFormatted: json['size_formatted'] ?? '0 B',
      count: json['count'] ?? 0,
      percent: (json['percent'] ?? 0).toDouble(),
    );
  }
}

class StorageRepository {
  final ApiClient _api = ApiClient();

  /// GET /user/storage — Detailed storage usage breakdown
  Future<StorageInfo> getStorageInfo() async {
    try {
      final response = await _api.dio.get('/v1/user/storage');
      if (response.statusCode == 200) {
        final data = response.data['data'] ?? response.data;
        return StorageInfo.fromJson(data);
      }
      throw Exception('Failed to load storage info');
    } on DioException catch (e) {
      log('getStorageInfo failed: ${e.response?.data}');
      throw Exception(
          e.response?.data['message'] ?? 'Failed to fetch storage info');
    }
  }
}
