import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/app_colors.dart';
import '../providers/file_provider.dart';
import '../widgets/file_card.dart';

class ExplorerView extends ConsumerWidget {
  final int folderId;
  const ExplorerView({super.key, this.folderId = 0});

  void _showFileOptions(BuildContext context, dynamic file) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                decoration: const BoxDecoration(
                  border: Border(bottom: BorderSide(color: AppColors.borderLight)),
                ),
                child: Row(
                  children: [
                    const Expanded(
                      child: Text('File Options', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    )
                  ],
                ),
              ),
              ListTile(
                leading: const Icon(Icons.open_in_new),
                title: const Text('Open'),
                onTap: () => Navigator.pop(context),
              ),
              ListTile(
                leading: const Icon(Icons.download),
                title: const Text('Download'),
                onTap: () => Navigator.pop(context),
              ),
              ListTile(
                leading: const Icon(Icons.drive_file_rename_outline),
                title: const Text('Rename'),
                onTap: () => Navigator.pop(context),
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.delete, color: AppColors.danger),
                title: const Text('Delete', style: TextStyle(color: AppColors.danger)),
                onTap: () => Navigator.pop(context),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // If folderId is 0, fetch root folders. Otherwise fetch folder contents
    final asyncData = folderId == 0 
        ? ref.watch(rootFolderProvider) 
        : ref.watch(folderContentsProvider(folderId));

    return Scaffold(
      backgroundColor: AppColors.backgroundAlt,
      appBar: AppBar(
        title: Text(
          folderId == 0 ? 'My Files' : 'Folder Contents', 
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          if (folderId == 0) {
            ref.invalidate(rootFolderProvider);
          } else {
            ref.invalidate(folderContentsProvider(folderId));
          }
        },
        child: asyncData.when(
          data: (folder) {
            final folders = folder.children;
            final files = folder.files;
            
            if (folders.isEmpty && files.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: AppColors.borderLight,
                        borderRadius: BorderRadius.circular(16)
                      ),
                      child: const Icon(Icons.folder_open, size: 32, color: AppColors.textMuted),
                    ),
                    const SizedBox(height: 16),
                    const Text('Folder is empty', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                    const SizedBox(height: 8),
                    const Text('Upload files or create folders here.', style: TextStyle(color: AppColors.textSecondary)),
                  ],
                ),
              );
            }

            return ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                if (folders.isNotEmpty) ...[
                  const Text('Folders', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textSecondary)),
                  const SizedBox(height: 12),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 2.5,
                    ),
                    itemCount: folders.length,
                    itemBuilder: (context, index) {
                      final f = folders[index];
                      return InkWell(
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(
                            builder: (_) => ExplorerView(folderId: f.id),
                          ));
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.border),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Row(
                            children: [
                              const Icon(Icons.folder, color: AppColors.amber),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  f.namaFolder,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                ],

                if (files.isNotEmpty) ...[
                  const Text('Files', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textSecondary)),
                  const SizedBox(height: 12),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 0.85,
                    ),
                    itemCount: files.length,
                    itemBuilder: (context, index) {
                      final f = files[index];
                      return FileCard(
                        file: f,
                        onTap: () {},
                        onMoreTap: () => _showFileOptions(context, f),
                      );
                    },
                  ),
                ],
              ],
            );
          },
          error: (err, st) => Center(child: Text('Error: $err')),
          loading: () => const Center(child: CircularProgressIndicator()),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Bottom sheet to show Upload/Create Folder choices
        },
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
