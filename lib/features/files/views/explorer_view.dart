import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/app_colors.dart';
import '../../dashboard/widgets/cld_search_bar.dart';
import '../widgets/file_card.dart';
import '../providers/file_provider.dart';
import '../providers/search_provider.dart';

class ExplorerView extends ConsumerWidget {
  final int folderId;
  const ExplorerView({super.key, this.folderId = 0});

  void _showFileOptions(BuildContext context, dynamic f) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.insert_drive_file, color: AppColors.primary, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        f.namaTampilan,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 24),
              _buildOption(context, Icons.download_rounded, 'Download', () {}),
              _buildOption(context, Icons.edit_outlined, 'Rename', () {}),
              _buildOption(context, Icons.share_outlined, 'Share', () {}),
              _buildOption(context, Icons.delete_outline_rounded, 'Delete', () {}, color: AppColors.danger),
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );
  }

  Widget _buildOption(BuildContext context, IconData icon, String label, VoidCallback onTap, {Color? color}) {
    return ListTile(
      leading: Icon(icon, color: color ?? AppColors.textSecondary),
      title: Text(label, style: TextStyle(color: color ?? AppColors.textPrimary, fontWeight: FontWeight.w500)),
      onTap: () {
        Navigator.pop(context);
        onTap();
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncData = folderId == 0 
        ? ref.watch(rootFolderProvider) 
        : ref.watch(folderContentsProvider(folderId));
    final searchText = ref.watch(fileSearchProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(folderId == 0 ? 'My Files' : 'Folder Contents'),
        centerTitle: true,
        actions: [
          IconButton(icon: const Icon(Icons.sort_rounded), onPressed: () {}),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: CldSearchBar(
              onChanged: (v) => ref.read(fileSearchProvider.notifier).update(v),
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                if (folderId == 0) {
                  ref.invalidate(rootFolderProvider);
                } else {
                  ref.invalidate(folderContentsProvider(folderId));
                }
              },
              child: asyncData.when(
                data: (folder) {
                  final folders = folder.children.where((f) => f.namaFolder.toLowerCase().contains(searchText.toLowerCase())).toList();
                  final files = folder.files.where((f) => f.namaTampilan.toLowerCase().contains(searchText.toLowerCase())).toList();
                  
                  if (folders.isEmpty && files.isEmpty) {
                    return _buildEmptyState(searchText.isNotEmpty);
                  }

                  return ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
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
                            return _buildFolderCard(context, f);
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
                            childAspectRatio: 0.82,
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
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, st) => Center(child: Text('Error: $e')),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildFolderCard(BuildContext context, dynamic f) {
    return InkWell(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ExplorerView(folderId: f.id))),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.border)),
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Row(
          children: [
            const Icon(Icons.folder_rounded, color: AppColors.amber),
            const SizedBox(width: 8),
            Expanded(child: Text(f.namaFolder, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13))),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool isSearch) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.folder_open_rounded, size: 64, color: AppColors.textMuted.withValues(alpha: 0.3)),
          const SizedBox(height: 16),
          Text(isSearch ? 'No items match your search' : 'Folder is empty', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          const SizedBox(height: 8),
          Text(isSearch ? 'Try a different keyword.' : 'Upload files or create folders here.', style: const TextStyle(color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}
