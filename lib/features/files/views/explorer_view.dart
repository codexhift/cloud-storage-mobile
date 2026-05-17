
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
<<<<<<< HEAD

=======
import 'package:file_picker/file_picker.dart';
>>>>>>> 1b39226a3c5d0e96d2481f81fc7edbb1bb75e1ab
import '../../../core/app_colors.dart';
import '../../dashboard/widgets/cld_search_bar.dart';
import '../models/file_model.dart';
import '../models/folder_model.dart';
import '../providers/file_provider.dart';
import '../providers/search_provider.dart';
<<<<<<< HEAD
import '../widgets/file_card.dart';
import 'package:file_picker/file_picker.dart' as fp;
=======
import '../models/folder_model.dart';
import '../models/file_model.dart';
import '../widgets/file_card.dart';
>>>>>>> 1b39226a3c5d0e96d2481f81fc7edbb1bb75e1ab

class ExplorerView extends ConsumerStatefulWidget {
  final int folderId;
  final String? folderName;
  const ExplorerView({super.key, this.folderId = 0, this.folderName});

  @override
  ConsumerState<ExplorerView> createState() => _ExplorerViewState();
}

class _ExplorerViewState extends ConsumerState<ExplorerView> {
  bool _isUploading = false;

  // ─── Actions ─────────────────────────────────────────────────────────

  Future<void> _showCreateFolderDialog() async {
    final nameController = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Folder Baru'),
        content: TextField(
          controller: nameController,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'Nama folder'),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, nameController.text.trim()),
            child: const Text('Buat'),
          ),
        ],
      ),
    );

    if (result != null && result.isNotEmpty) {
      try {
        final repo = ref.read(fileRepositoryProvider);
        await repo.createFolder(
          result,
          parentId: widget.folderId == 0 ? null : widget.folderId,
        );
        _refresh();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Folder berhasil dibuat'),
              backgroundColor: AppColors.success,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Gagal membuat folder: $e'),
              backgroundColor: AppColors.danger,
            ),
          );
        }
      }
    }
  }

  Future<void> _uploadFile() async {
    // Ganti import di atas file:

// Lalu di _uploadFile:
final result = await fp.FilePicker.platform.pickFiles(
  allowMultiple: false,
  withData: true,
);
    final file = result.files.first;
    if (file.bytes == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Gagal membaca file'),
            backgroundColor: AppColors.danger,
          ),
        );
      }
      return;
    }

    setState(() => _isUploading = true);
    try {
      final repo = ref.read(fileRepositoryProvider);
      await repo.uploadFile(
        file,
        folderId: widget.folderId == 0 ? null : widget.folderId,
      );
      _refresh();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${file.name} berhasil diupload'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Upload gagal: $e'),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  void _refresh() {
    if (widget.folderId == 0) {
      ref.invalidate(rootFoldersProvider);
    } else {
      ref.invalidate(folderContentsProvider(widget.folderId));
    }
  }

  void _showFileOptions(BuildContext context, FileModel f) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                decoration: const BoxDecoration(
                  border: Border(
                      bottom: BorderSide(color: AppColors.borderLight)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.insert_drive_file,
                          color: AppColors.primary, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(f.name, maxLines: 1, overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          Text(f.sizeFormatted,
                            style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              const Divider(height: 24),
              _buildOption(ctx, Icons.download_rounded, 'Download', () {}),
              _buildOption(
                ctx,
                f.isStarred
                    ? Icons.star_rounded
                    : Icons.star_outline_rounded,
                f.isStarred ? 'Hapus Bintang' : 'Beri Bintang',
                () async {
                  try {
                    final repo = ref.read(fileRepositoryProvider);
                    await repo.toggleStar(f.id);
                    _refresh();
                  } catch (_) {}
                },
              ),
              _buildOption(ctx, Icons.share_outlined, 'Bagikan', () async {
                try {
                  final repo = ref.read(fileRepositoryProvider);
                  final url = await repo.shareFile(f.id);
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Link: $url')),
                    );
                  }
                } catch (_) {}
              }),
              _buildOption(
<<<<<<< HEAD
                ctx,
                Icons.delete_outline_rounded,
                'Hapus',
=======
                ctx, Icons.delete_outline_rounded, 'Hapus',
>>>>>>> 1b39226a3c5d0e96d2481f81fc7edbb1bb75e1ab
                () async {},
                color: AppColors.danger,
              ),
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );
  }

  Widget _buildOption(
<<<<<<< HEAD
    BuildContext context,
    IconData icon,
    String label,
    VoidCallback onTap, {
    Color? color,
  }) {
    return ListTile(
      leading: Icon(icon, color: color ?? AppColors.textSecondary),
      title: Text(
        label,
        style: TextStyle(
          color: color ?? AppColors.textPrimary,
          fontWeight: FontWeight.w500,
        ),
      ),
=======
      BuildContext context, IconData icon, String label, VoidCallback onTap,
      {Color? color}) {
    return ListTile(
      leading: Icon(icon, color: color ?? AppColors.textSecondary),
      title: Text(label,
          style: TextStyle(
              color: color ?? AppColors.textPrimary,
              fontWeight: FontWeight.w500)),
>>>>>>> 1b39226a3c5d0e96d2481f81fc7edbb1bb75e1ab
      onTap: () {
        Navigator.pop(context);
        onTap();
      },
    );
  }

  void _showFolderOptions(BuildContext context, FolderModel f) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40, height: 4,
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
                    const Icon(Icons.folder_rounded, color: AppColors.amber, size: 28),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(f.name, maxLines: 1, overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    ),
                  ],
                ),
              ),
              const Divider(height: 24),
              _buildOption(ctx, Icons.edit_outlined, 'Rename', () async {
                final nameCtrl = TextEditingController(text: f.name);
                final newName = await showDialog<String>(
                  context: context,
                  builder: (d) => AlertDialog(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    title: const Text('Rename Folder'),
                    content: TextField(controller: nameCtrl, autofocus: true),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(d), child: const Text('Batal')),
                      ElevatedButton(
                        onPressed: () => Navigator.pop(d, nameCtrl.text.trim()),
                        child: const Text('Simpan'),
                      ),
                    ],
                  ),
                );
                if (newName != null &&
                    newName.isNotEmpty &&
                    newName != f.name) {
                  try {
                    final repo = ref.read(fileRepositoryProvider);
                    await repo.renameFolder(f.id, newName);
                    _refresh();
                  } catch (_) {}
                }
              }),
              _buildOption(
                ctx, Icons.delete_outline_rounded, 'Hapus',
                () async {
                  try {
                    final repo = ref.read(fileRepositoryProvider);
                    await repo.deleteFolder(f.id);
                    _refresh();
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Folder dihapus'), backgroundColor: AppColors.success),
                      );
                    }
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Gagal menghapus: $e'), backgroundColor: AppColors.danger),
                      );
                    }
                  }
                },
                color: AppColors.danger,
              ),
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );
  }

  // ─── Build ───────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final searchText = ref.watch(fileSearchProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(widget.folderId == 0
            ? 'My Files'
            : (widget.folderName ?? 'Folder')),
        centerTitle: true,
      ),
      body: Column(
        children: [
          if (_isUploading)
            const LinearProgressIndicator(
              color: AppColors.primary,
              backgroundColor: AppColors.primaryLight,
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: CldSearchBar(
              onChanged: (v) => ref.read(fileSearchProvider.notifier).update(v),
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async => _refresh(),
              child: widget.folderId == 0
                  ? _buildRootView(searchText)
                  : _buildFolderView(searchText),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            builder: (ctx) => SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 40, height: 4,
                    margin: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(2)),
                  ),
                  ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(color: AppColors.amberLight, borderRadius: BorderRadius.circular(8)),
                      child: const Icon(Icons.create_new_folder_outlined, color: AppColors.amber, size: 20),
                    ),
                    title: const Text('Folder Baru', style: TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: const Text('Buat folder baru', style: TextStyle(fontSize: 12)),
                    onTap: () { Navigator.pop(ctx); _showCreateFolderDialog(); },
                  ),
                  ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(color: AppColors.primaryLight, borderRadius: BorderRadius.circular(8)),
                      child: const Icon(Icons.upload_file_outlined, color: AppColors.primary, size: 20),
                    ),
                    title: const Text('Upload File', style: TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: const Text('Maksimal 100 MB per file', style: TextStyle(fontSize: 12)),
                    onTap: () { Navigator.pop(ctx); _uploadFile(); },
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          );
        },
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildRootView(String searchText) {
    final asyncData = ref.watch(rootFoldersProvider);
    return asyncData.when(
      data: (folders) {
        final filtered = folders
            .where((f) => f.name.toLowerCase().contains(searchText.toLowerCase()))
            .toList();
        if (filtered.isEmpty) return _buildEmptyState(searchText.isNotEmpty);
        return ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          children: [
            const Text('Folders',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textSecondary)),
            const SizedBox(height: 12),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
<<<<<<< HEAD
              gridDelegate:
                  const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 2.5,
=======
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 2.5,
>>>>>>> 1b39226a3c5d0e96d2481f81fc7edbb1bb75e1ab
              ),
              itemCount: filtered.length,
              itemBuilder: (context, index) => _buildFolderCard(context, filtered[index]),
            ),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, st) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: AppColors.textMuted),
            const SizedBox(height: 12),
            Text('Error: $e', style: const TextStyle(color: AppColors.textSecondary)),
            const SizedBox(height: 12),
            ElevatedButton(onPressed: _refresh, child: const Text('Coba Lagi')),
          ],
        ),
      ),
    );
  }

  Widget _buildFolderView(String searchText) {
    final asyncData = ref.watch(folderContentsProvider(widget.folderId));
    return asyncData.when(
      data: (folder) {
        final folders = folder.children
            .where((f) => f.name.toLowerCase().contains(searchText.toLowerCase()))
            .toList();
        final files = folder.files
            .where((f) => f.name.toLowerCase().contains(searchText.toLowerCase()))
            .toList();

        if (folders.isEmpty && files.isEmpty) {
          return _buildEmptyState(searchText.isNotEmpty);
        }

        return ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          children: [
            if (folders.isNotEmpty) ...[
              const Text('Folders',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textSecondary)),
              const SizedBox(height: 12),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 2.5,
                ),
                itemCount: folders.length,
                itemBuilder: (context, index) => _buildFolderCard(context, folders[index]),
              ),
              const SizedBox(height: 24),
            ],
            if (files.isNotEmpty) ...[
              const Text('Files',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textSecondary)),
              const SizedBox(height: 12),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 0.82,
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
    );
  }

  Widget _buildFolderCard(BuildContext context, FolderModel f) {
    return InkWell(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ExplorerView(folderId: f.id, folderName: f.name),
        ),
      ),
      onLongPress: () => _showFolderOptions(context, f),
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
            const Icon(Icons.folder_rounded, color: AppColors.amber),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                f.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
              ),
            ),
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
          Icon(Icons.folder_open_rounded, size: 64,
              color: AppColors.textMuted.withValues(alpha: 0.3)),
          const SizedBox(height: 16),
          Text(
            isSearch ? 'Tidak ada hasil' : 'Folder kosong',
<<<<<<< HEAD
            style:
                const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          const SizedBox(height: 8),
          Text(
            isSearch
                ? 'Coba kata kunci lain.'
                : 'Upload file atau buat folder baru.',
=======
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          const SizedBox(height: 8),
          Text(
            isSearch ? 'Coba kata kunci lain.' : 'Upload file atau buat folder baru.',
>>>>>>> 1b39226a3c5d0e96d2481f81fc7edbb1bb75e1ab
            style: const TextStyle(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
} 