import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../core/app_colors.dart';
import '../../auth/models/user_model.dart';

class StorageDonutChart extends StatelessWidget {
  final UserModel user;
  
  const StorageDonutChart({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    // For MVP, we will only show Used vs Free since API might not split images/videos per user in `/auth/me`
    // However, we represent Used with Primary and Free with BorderLight
    
    final int used = user.storageUsed;
    final int quota = user.storageQuota > 0 ? user.storageQuota : 1;
    final int free = quota - used > 0 ? quota - used : 0;
    
    final double usedPct = (used / quota) * 100;
    
    return SizedBox(
      height: 180,
      width: 180,
      child: Stack(
        alignment: Alignment.center,
        children: [
          PieChart(
            PieChartData(
              sectionsSpace: 0,
              centerSpaceRadius: 65,
              startDegreeOffset: 270,
              sections: [
                PieChartSectionData(
                  color: AppColors.primary,
                  value: used.toDouble(),
                  title: '',
                  radius: 12,
                ),
                PieChartSectionData(
                  color: AppColors.borderLight,
                  value: free.toDouble(),
                  title: '',
                  radius: 12,
                ),
              ],
            ),
            swapAnimationDuration: const Duration(milliseconds: 900),
            swapAnimationCurve: Curves.easeInOutQuart,
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${usedPct.toStringAsFixed(0)}%',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const Text(
                'Used',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
