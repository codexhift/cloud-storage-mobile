import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/app_colors.dart';
import '../../auth/providers/auth_provider.dart';
import '../../files/providers/file_provider.dart';
import '../../files/providers/search_provider.dart';
import '../widgets/stat_card.dart';
import '../widgets/storage_usage_bar.dart';
import '../widgets/cld_search_bar.dart';

class DashboardView extends ConsumerWidget {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    final user = authState.user;
    final recentFilesAsync = ref.watch(recentFilesProvider);
    final searchText = ref.watch(fileSearchProvider);

    if (user == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final hour = DateTime.now().hour;
    final greeting = hour < 12
        ? 'morning'
        : (hour < 17 ? 'afternoon' : 'evening');
    final firstName = user.name.split(' ').first;

    final usedMB = (user.storageUsed / (1024 * 1024)).toStringAsFixed(1);
    final totalMB = (user.storageQuota / (1024 * 1024)).toStringAsFixed(0);
    final pct =
        (user.storageUsed / (user.storageQuota > 0 ? user.storageQuota : 1)) *
        100;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.notifications_none_outlined,
            color: AppColors.textPrimary,
          ),
          onPressed: () {},
        ),
        title: Image.asset(
          'assets/images/CLD.png',
          height: 32,
          errorBuilder: (context, error, stackTrace) =>
              const Icon(Icons.cloud_queue, color: AppColors.primary),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {},
            icon: CircleAvatar(
              radius: 14,
              backgroundColor: AppColors.primary,
              child: Text(
                firstName[0].toUpperCase(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(recentFilesProvider);
          await ref.read(authStateProvider.notifier).checkAuthStatus();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CldSearchBar(
                onChanged: (v) =>
                    ref.read(fileSearchProvider.notifier).update(v),
              ),
              const SizedBox(height: 24),
              Text(
                'Good $greeting, $firstName 👋',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                  letterSpacing: -0.5,
                ),
              ),
              const Text(
                'Monitor your storage and recent files.',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
              ),
              const SizedBox(height: 24),
              // StatCards - horizontal scroll with responsive layout
              SizedBox(
                height: 130, // Fixed height for horizontal scroll container
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  child: Row(
                    mainAxisSize: MainAxisSize.min, // Prevent unbounded width
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      StatCard(
                        label: 'Total Files',
                        value: '124',
                        sub: 'Across 12 folders',
                        icon: Icons.folder_copy_outlined,
                        bg: Colors.white,
                        iconBg: AppColors.primary,
                        index: '01',
                      ),
                      const SizedBox(width: 12),
                      StatCard(
                        label: 'Storage Used',
                        value: '$usedMB MB',
                        sub: '${pct.toStringAsFixed(1)}% of $totalMB MB',
                        icon: Icons.donut_large_rounded,
                        bg: Colors.white,
                        iconBg: AppColors.violet,
                        index: '02',
                      ),
                      const SizedBox(width: 12),
                      StatCard(
                        label: 'Recent Uploads',
                        value: '12',
                        sub: 'In the last 24h',
                        icon: Icons.upload_file_outlined,
                        bg: Colors.white,
                        iconBg: AppColors.amber,
                        index: '03',
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              StorageUsageBar(user: user),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Recent Activity',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  TextButton(
                    onPressed: () {},
                    child: const Text(
                      'View all',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              recentFilesAsync.when(
                data: (files) {
                  final filteredFiles = files
                      .where(
                        (f) => f.namaTampilan.toLowerCase().contains(
                          searchText.toLowerCase(),
                        ),
                      )
                      .toList();
                  if (filteredFiles.isEmpty) {
                    return _buildEmptyState(searchText.isNotEmpty);
                  }
                  return ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: filteredFiles.take(5).length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 8),
                    itemBuilder: (context, index) =>
                        _buildFileTile(filteredFiles[index]),
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, st) => const Text('Error loading activity'),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFileTile(dynamic file) {
    final ext = file.ekstensi.toLowerCase();
    Color iconColor = AppColors.primary;
    if (['jpg', 'jpeg', 'png'].contains(ext)) iconColor = AppColors.violet;
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
            child: Icon(
              Icons.insert_drive_file_outlined,
              color: iconColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  file.namaTampilan,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                Text(
                  'Uploaded · ${DateFormat.yMMMd().format(file.createdAt)}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.more_vert, color: AppColors.textMuted, size: 20),
        ],
      ),
    );
  }

  Widget _buildEmptyState(bool isSearch) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Column(
          children: [
            Icon(
              Icons.history_rounded,
              size: 48,
              color: AppColors.textMuted.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 12),
            Text(
              isSearch
                  ? 'No files match your search'
                  : 'No recent activity yet',
              style: const TextStyle(color: AppColors.textMuted),
            ),
          ],
        ),
      ),
    );
  }
}
