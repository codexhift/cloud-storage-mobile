import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/app_colors.dart';
import '../../auth/providers/auth_provider.dart';
import 'package:intl/intl.dart';

class ProfileView extends ConsumerWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    final user = ref.watch(authStateProvider).value;

    final user = ref.watch(authStateProvider).user;


    if (user == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final usedMB = user.storageUsed / (1024 * 1024);
    final totalMB = user.storageQuota / (1024 * 1024);
    final freeMB = totalMB - usedMB;

    final pct = user.storageQuota > 0 ? (user.storageUsed / user.storageQuota) * 100 : 0;

    final pct = user.storageQuota > 0
        ? (user.storageUsed / user.storageQuota) * 100
        : 0;


    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(

        title: const Text('Profil Akun', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),

        title: const Text(
          'Profil Akun',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),

      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Informasi akun dan pengaturan keamanan.',
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
                      Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Center(
                          child: Text(
                            user.name[0].toUpperCase(),

                            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),

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

                              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary),

                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),

                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [

                                const Icon(Icons.calendar_month, size: 14, color: AppColors.textSecondary),
                                const SizedBox(width: 4),
                                Text(
                                  'Bergabung sejak ${DateFormat.yMMM().format(user.createdAt)}',
                                  style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                                ),
                              ],
                            )

                                const Icon(
                                  Icons.calendar_month,
                                  size: 14,
                                  color: AppColors.textSecondary,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'Bergabung sejak ${DateFormat.yMMM().format(user.createdAt)}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textSecondary,
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

                  // Storage usage visually identical to web
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

                                const Text('PENGGUNAAN PENYIMPANAN', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.primary, letterSpacing: 0.5)),

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
                              '${freeMB.toStringAsFixed(1)} MB Tersisa',

                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.textSecondary),
                            )

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

                  const Text('Aksi Pengguna', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),

                  const Text(
                    'Aksi Pengguna',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),

                  const SizedBox(height: 12),
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                      child: Container(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.background,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.logout, color: Colors.orange, size: 20),
                            SizedBox(width: 12),

                            Text('Keluar dari Sesi', style: TextStyle(fontSize: 14, color: AppColors.textPrimary)),

                            Text(
                              'Keluar dari Sesi',
                              style: TextStyle(
                                fontSize: 14,
                                color: AppColors.textPrimary,
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
    );
  }
}
