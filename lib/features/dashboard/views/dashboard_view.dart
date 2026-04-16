import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/app_colors.dart';
import '../../auth/providers/auth_provider.dart';
import '../../files/providers/file_provider.dart';
import '../widgets/stat_card.dart';
import '../widgets/storage_chart.dart';

class DashboardView extends ConsumerWidget {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    final user = authState.value;
    
    final recentFilesAsync = ref.watch(recentFilesProvider);

    if (user == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final hour = DateTime.now().hour;
    final greeting = hour < 12 ? 'morning' : (hour < 17 ? 'afternoon' : 'evening');
    final firstName = user.name.split(' ').first;

    final usedMB = (user.storageUsed / (1024 * 1024)).toStringAsFixed(1);
    final totalMB = (user.storageQuota / (1024 * 1024)).toStringAsFixed(0);
    final pct = (user.storageUsed / (user.storageQuota > 0 ? user.storageQuota : 1)) * 100;

    return Scaffold(
      backgroundColor: AppColors.backgroundAlt,
      appBar: AppBar(
        title: Image.asset(
          'assets/images/CLD.png', 
          height: 36,
          errorBuilder: (context, error, stackTrace) => 
            const Icon(Icons.cloud, color: AppColors.primary),
        ),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {},
          ),
          IconButton(
            icon: CircleAvatar(
              backgroundColor: AppColors.primary,
              radius: 14,
              child: Text(
                firstName[0].toUpperCase(),
                style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ),
            onPressed: () {},
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
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Text(
                'Good $greeting, $firstName 👋',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 22, letterSpacing: -0.5),
              ),
              const SizedBox(height: 4),
              const Text(
                'Here\'s what\'s happening with your storage today.',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
              ),
              
              const SizedBox(height: 24),
              
              // Stat Cards
              SizedBox(
                height: 140, // fixed height for row
                child: Row(
                  children: [
                    Expanded(
                      child: StatCard(
                        label: 'Storage Used',
                        value: '$usedMB MB',
                        sub: '${pct.toStringAsFixed(1)}% of $totalMB MB',
                        icon: Icons.pie_chart_rounded,
                        bg: AppColors.statViolet,
                        iconBg: AppColors.iconViolet,
                        index: '01',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: StatCard(
                        label: 'Remaining',
                        value: '${(user.storageQuota - user.storageUsed) ~/ (1024 * 1024)} MB',
                        sub: 'Free space available',
                        icon: Icons.cloud_done_rounded,
                        bg: AppColors.statEmerald,
                        iconBg: AppColors.iconEmerald,
                        index: '02',
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Storage Overview (Donut logic)
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Storage Overview',
                              style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary, fontSize: 16),
                            ),
                            Text(
                              'Breakdown',
                              style: TextStyle(fontSize: 12, color: AppColors.textMuted),
                            )
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.backgroundAlt,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppColors.borderLight),
                          ),
                          child: Text(
                            '${pct.toStringAsFixed(1)}% used',
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.textSecondary),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Center(child: StorageDonutChart(user: user)),
                  ],
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Recent Activity Block
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Recent Activity',
                              style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary, fontSize: 16),
                            ),
                            Text(
                              'Your latest file actions',
                              style: TextStyle(fontSize: 12, color: AppColors.textMuted),
                            )
                          ],
                        ),
                        TextButton(
                          onPressed: () {},
                          child: const Text('View all →', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                        )
                      ],
                    ),
                    const SizedBox(height: 16),
                    recentFilesAsync.when(
                      data: (files) {
                        if (files.isEmpty) {
                          return Center(
                            child: Padding(
                              padding: const EdgeInsets.all(24.0),
                              child: Column(
                                children: [
                                  const Icon(Icons.folder_open, size: 48, color: AppColors.textLight),
                                  const SizedBox(height: 8),
                                  const Text('No recent files', style: TextStyle(color: AppColors.textSecondary)),
                                ],
                              ),
                            ),
                          );
                        }
                        
                        return ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: files.take(5).length,
                          separatorBuilder: (context, index) => const SizedBox(height: 4),
                          itemBuilder: (context, index) {
                            final file = files[index];
                            // Logic determining icon color based on extension
                            final ext = file.ekstensi.toLowerCase();
                            Color iconColor = AppColors.blue;
                            Color iconBg = AppColors.blueLight;
                            
                            if (['jpg','jpeg','png','gif'].contains(ext)) {
                              iconColor = AppColors.violet;
                              iconBg = AppColors.violetLight;
                            } else if (['mp4','webm','mov'].contains(ext)) {
                              iconColor = AppColors.amber;
                              iconBg = AppColors.amberLight;
                            } else if (ext == 'pdf') {
                              iconColor = AppColors.red;
                              iconBg = AppColors.redLight;
                            }
                            
                            return ListTile(
                              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              hoverColor: AppColors.backgroundAlt,
                              onTap: () {},
                              leading: Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  color: iconBg,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Icon(Icons.insert_drive_file, color: iconColor, size: 18),
                              ),
                              title: Text(
                                file.namaTampilan,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.textPrimary),
                              ),
                              subtitle: Text(
                                'Uploaded · ${DateFormat.yMMMd().format(file.createdAt)}',
                                style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                              ),
                              trailing: const Icon(Icons.chevron_right, color: AppColors.textLight, size: 20),
                            );
                          },
                        );
                      },
                      error: (e, st) => Text('Error loading files', style: TextStyle(color: AppColors.danger)),
                      loading: () => const Center(child: CircularProgressIndicator()),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
