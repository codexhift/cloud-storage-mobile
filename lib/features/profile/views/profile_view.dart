import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/app_colors.dart';
import '../../auth/providers/auth_provider.dart';
import '../../files/providers/storage_provider.dart';
import '../../files/repository/storage_repository.dart';

class ProfileView extends ConsumerWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authStateProvider).user;
    final storageAsync = ref.watch(storageInfoProvider);

    if (user == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final usedMB = user.storageUsed / (1024 * 1024);
    final totalGB = user.storageQuota / (1024 * 1024 * 1024);
    final freeGB = totalGB - (usedMB / 1024);
    final pct = user.storageQuota > 0
        ? (user.storageUsed / user.storageQuota) * 100
        : 0;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Profil Akun',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(storageInfoProvider);
          await ref.read(authStateProvider.notifier).checkAuthStatus();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Informasi akun dan penyimpanan Anda.',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
              ),
              const SizedBox(height: 24),

              // User Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        // Avatar
                        Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: user.avatar != null
                              ? Image.network(
                                  user.avatar!,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => Center(
                                    child: Text(
                                      user.name[0].toUpperCase(),
                                      style: const TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                )
                              : Center(
                                  child: Text(
                                    user.name[0].toUpperCase(),
                                    style: const TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                user.name,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                user.email,
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.calendar_month,
                                    size: 14,
                                    color: AppColors.textMuted,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Bergabung ${DateFormat.yMMM().format(user.createdAt)}',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: AppColors.textMuted,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Storage usage bar
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.primaryRing),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'PENGGUNAAN PENYIMPANAN',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.primary,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  RichText(
                                    text: TextSpan(
                                      text: usedMB.toStringAsFixed(2),
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.textPrimary,
                                      ),
                                      children: const [
                                        TextSpan(
                                          text: ' MB digunakan',
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.normal,
                                            color: AppColors.textSecondary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              Text(
                                '${freeGB.toStringAsFixed(2)} GB Tersisa',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: LinearProgressIndicator(
                              value: pct / 100,
                              minHeight: 8,
                              backgroundColor: AppColors.primaryRing,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Storage Breakdown
              storageAsync.when(
                data: (info) => _buildStorageBreakdown(info),
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
              ),

              const SizedBox(height: 24),

              // Actions
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Aksi Pengguna',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    const SizedBox(height: 12),
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16)),
                              title: const Text('Keluar?'),
                              content: const Text(
                                  'Anda akan keluar dari akun Google Anda.'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(ctx),
                                  child: const Text('Batal'),
                                ),
                                ElevatedButton(
                                  onPressed: () {
                                    Navigator.pop(ctx);
                                    ref.read(authStateProvider.notifier).logout();
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.danger,
                                  ),
                                  child: const Text('Keluar'),
                                ),
                              ],
                            ),
                          );
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.dangerLight,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.dangerBorder),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.logout, color: AppColors.danger, size: 20),
                              SizedBox(width: 12),
                              Text(
                                'Keluar dari Akun',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.danger,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStorageBreakdown(StorageInfo info) {
    if (info.categories.isEmpty) return const SizedBox.shrink();

    final categoryIcons = <String, IconData>{
      'images': Icons.image_outlined,
      'Images': Icons.image_outlined,
      'videos': Icons.videocam_outlined,
      'Videos': Icons.videocam_outlined,
      'documents': Icons.description_outlined,
      'Documents': Icons.description_outlined,
      'pdfs': Icons.picture_as_pdf_outlined,
      'PDFs': Icons.picture_as_pdf_outlined,
      'others': Icons.folder_outlined,
      'Others': Icons.folder_outlined,
    };

    final categoryColors = <String, Color>{
      'images': AppColors.violet,
      'Images': AppColors.violet,
      'videos': AppColors.amber,
      'Videos': AppColors.amber,
      'documents': AppColors.blue,
      'Documents': AppColors.blue,
      'pdfs': AppColors.red,
      'PDFs': AppColors.red,
      'others': AppColors.textMuted,
      'Others': AppColors.textMuted,
    };

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Rincian Penyimpanan',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          const SizedBox(height: 16),
          ...info.categories.entries.map((entry) {
            final color = categoryColors[entry.key] ?? AppColors.textSecondary;
            final icon = categoryIcons[entry.key] ?? Icons.folder_outlined;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(icon, color: color, size: 18),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          entry.key,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                        Text(
                          '${entry.value.count} files · ${entry.value.sizeFormatted}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '${entry.value.percent.toStringAsFixed(1)}%',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: color,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}