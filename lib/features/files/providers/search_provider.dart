import 'package:flutter_riverpod/flutter_riverpod.dart';

class FileSearchNotifier extends Notifier<String> {
  @override
  String build() => '';

  void update(String query) => state = query;
}

final fileSearchProvider = NotifierProvider<FileSearchNotifier, String>(() {
  return FileSearchNotifier();
});
