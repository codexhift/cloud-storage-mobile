import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/app_colors.dart';
import '../../auth/providers/auth_provider.dart';
import '../../files/providers/file_provider.dart';
import '../../files/providers/search_provider.dart';
import '../../files/providers/storage_provider.dart';
import '../widgets/stat_card.dart';
import '../widgets/storage_usage_bar.dart';
import '../widgets/cld_search_bar.dart';

class DashboardView extends ConsumerWidget {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    final user = authState.user;
    final searchText = ref.watch(fileSearchProvider);
    final storageAsync = ref.watch(storageInfoProvider);

    if (user == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final firstName = user.name.split(' ').first;

    final hour = DateTime.now().hour;
    final greeting =
        hour < 12 ? 'morning' : (hour < 17 ? 'afternoon' : 'evening');

    final usedMB = (user.storageUsed / (1024 * 1024)).toStringAsFixed(1);
    final totalGB = (user.storageQuota / (1024 * 1024 * 1024)).toStringAsFixed(0);
    final pct =
        (user.storageUsed / (user.storageQuota > 0 ? user.storageQuota : 1)) *
        100;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: true,
        title: Image.asset(
          'assets/images/CLD.png',
          height: 32,
          errorBuilder: (_, __, ___) =>
              const Icon(Icons.cloud, color: AppColors.primary),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: user.avatar != null
                ? CircleAvatar(
                    radius: 14,
                    backgroundImage: NetworkImage(user.avatar!),
                    onBackgroundImageError: (_, __) {},
                  )
                : CircleAvatar(
                    radius: 14,
                    backgroundColor: AppColors.primary,
                    child: Text(
                      firstName[0].toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(storageInfoProvider);
          ref.invalidate(filesProvider(null));
          await ref.read(authStateProvider.notifier).checkAuthStatus();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// SEARCH
              CldSearchBar(
                onChanged: (v) =>
                    ref.read(fileSearchProvider.notifier).update(v),
              ),
              const SizedBox(height: 24),

              /// GREETING
              Text(
                'Good $greeting, $firstName 👋',
                style: const TextStyle(
                  fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.textPrimary,
                ),
              ),
              const Text(
                'Monitor your storage and recent files.',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
              ),
              const SizedBox(height: 24),

              // StatCards
              SizedBox(
                height: 130,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      StatCard(
                        label: 'Storage Used',
                        value: '$usedMB MB',
                        sub: '${pct.toStringAsFixed(1)}% of $totalGB GB',
                        icon: Icons.donut_large_rounded,
                        bg: Colors.white,
                        iconBg: AppColors.primary,
                        index: '01',
                      ),
                      const SizedBox(width: 12),
                      // Show dynamic stats from storage API
                      storageAsync.when(
                        data: (info) {
                          final imgCat = info.categories['images'] ??
                              info.categories['Images'];
                          final docCat = info.categories['documents'] ??
                              info.categories['Documents'];
                          return Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              StatCard(
                                label: 'Images',
                                value: imgCat?.sizeFormatted ?? '0 B',
                                sub: '${imgCat?.count ?? 0} files',
                                icon: Icons.image_outlined,
                                bg: Colors.white,
                                iconBg: AppColors.violet,
                                index: '02',
                              ),
                              const SizedBox(width: 12),
                              StatCard(
                                label: 'Documents',
                                value: docCat?.sizeFormatted ?? '0 B',
                                sub: '${docCat?.count ?? 0} files',
                                icon: Icons.description_outlined,
                                bg: Colors.white,
                                iconBg: AppColors.amber,
                                index: '03',
                              ),
                            ],
                          );
                        },
                        loading: () => Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            StatCard(label: 'Images', value: '...', sub: 'Loading', icon: Icons.image_outlined, bg: Colors.white, iconBg: AppColors.violet, index: '02'),
                            const SizedBox(width: 12),
                            StatCard(label: 'Documents', value: '...', sub: 'Loading', icon: Icons.description_outlined, bg: Colors.white, iconBg: AppColors.amber, index: '03'),
                          ],
                        ),
                        error: (_, __) => Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            StatCard(label: 'Images', value: '-', sub: 'Error', icon: Icons.image_outlined, bg: Colors.white, iconBg: AppColors.violet, index: '02'),
                            const SizedBox(width: 12),
                            StatCard(label: 'Documents', value: '-', sub: 'Error', icon: Icons.description_outlined, bg: Colors.white, iconBg: AppColors.amber, index: '03'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              /// STORAGE BAR
              StorageUsageBar(user: user),
              const SizedBox(height: 24),

              /// RECENT HEADER
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Recent Activity', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  TextButton(
                    onPressed: () {},
                    child: const Text('View all', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
              // Recent files from the files endpoint
              ref.watch(filesProvider(null)).when(
                data: (files) {
                  final filtered = files
                      .where((f) => f.name.toLowerCase().contains(searchText.toLowerCase()))
                      .toList();

                  if (filtered.isEmpty) {
                    return _buildEmptyState(searchText.isNotEmpty);
                  }

                  return ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: filtered.take(5).length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (_, i) => _buildFileTile(filtered[i]),
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (_, __) => const Text('Error loading activity'),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  /// FILE TILE
  Widget _buildFileTile(dynamic file) {
    final ext = file.extension.toLowerCase();
    Color iconColor = AppColors.primary;
    if (['jpg', 'jpeg', 'png', 'gif', 'webp'].contains(ext)) {
      iconColor = AppColors.violet;
    }
    if (['pdf'].contains(ext)) iconColor = AppColors.danger;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.insert_drive_file, color: iconColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(file.name, maxLines: 1, overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                Text('Uploaded · ${DateFormat.yMMMd().format(file.createdAt)}',
                  style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
              ],
            ),
          ),
          if (file.isStarred)
            const Padding(
              padding: EdgeInsets.only(right: 4),
              child: Icon(Icons.star_rounded, color: AppColors.amber, size: 16),
            ),
          const Icon(Icons.more_vert, color: AppColors.textMuted, size: 20),
        ],
      ),
    );
  }

  /// EMPTY STATE
  Widget _buildEmptyState(bool isSearch) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Column(
          children: [
            Icon(Icons.history, size: 48, color: AppColors.textMuted.withValues(alpha: 0.5)),
            const SizedBox(height: 12),
            Text(
              isSearch ? 'No files match your search' : 'No recent activity yet',
              style: const TextStyle(color: AppColors.textMuted),
            ),
          ],
        ),
      ),
    );
  }
}