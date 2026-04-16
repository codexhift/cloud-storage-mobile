import 'package:flutter/material.dart';
import '../../../../core/app_colors.dart';
import '../models/file_model.dart';

class FileCard extends StatelessWidget {
  final FileModel file;
  final VoidCallback onTap;
  final VoidCallback onMoreTap;

  const FileCard({
    super.key,
    required this.file,
    required this.onTap,
    required this.onMoreTap,
  });

  @override
  Widget build(BuildContext context) {
    final ext = file.ekstensi.toLowerCase();
    Color iconColor = AppColors.blue;
    Color iconBg = AppColors.blueLight;
    
    if (['jpg','jpeg','png','gif','webp'].contains(ext)) {
      iconColor = AppColors.violet;
      iconBg = AppColors.violetLight;
    } else if (['mp4','webm','mov'].contains(ext)) {
      iconColor = AppColors.amber;
      iconBg = AppColors.amberLight;
    } else if (ext == 'pdf') {
      iconColor = AppColors.red;
      iconBg = AppColors.redLight;
    }

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.insert_drive_file, color: iconColor, size: 32),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              file.namaTampilan,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  file.ukuranFormat,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textMuted,
                  ),
                ),
                IconButton(
                  onPressed: onMoreTap,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  icon: const Icon(Icons.more_horiz, size: 20, color: AppColors.textMuted),
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}
