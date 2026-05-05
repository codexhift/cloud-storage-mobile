import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repository/storage_repository.dart';

final storageRepositoryProvider = Provider<StorageRepository>((ref) {
  return StorageRepository();
});

final storageInfoProvider = FutureProvider<StorageInfo>((ref) async {
  final repo = ref.read(storageRepositoryProvider);
  return repo.getStorageInfo();
});
