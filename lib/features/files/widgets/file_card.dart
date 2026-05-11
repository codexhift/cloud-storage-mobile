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
    final ext = file.extension.toLowerCase();
    Color iconColor = AppColors.blue;
    Color iconBg = AppColors.blueLight;
    IconData fileIcon = Icons.insert_drive_file;

    if (['jpg', 'jpeg', 'png', 'gif', 'webp', 'svg'].contains(ext)) {
      iconColor = AppColors.violet;
      iconBg = AppColors.violetLight;
      fileIcon = Icons.image_outlined;
    } else if (['mp4', 'webm', 'mov', 'avi', 'mkv'].contains(ext)) {
      iconColor = AppColors.amber;
      iconBg = AppColors.amberLight;
      fileIcon = Icons.videocam_outlined;
    } else if (ext == 'pdf') {
      iconColor = AppColors.red;
      iconBg = AppColors.redLight;
      fileIcon = Icons.picture_as_pdf_outlined;
    } else if (['doc', 'docx', 'txt', 'rtf'].contains(ext)) {
      iconColor = AppColors.blue;
      iconBg = AppColors.blueLight;
      fileIcon = Icons.description_outlined;
    } else if (['xls', 'xlsx', 'csv'].contains(ext)) {
      iconColor = AppColors.green;
      iconBg = AppColors.greenLight;
      fileIcon = Icons.table_chart_outlined;
    } else if (['zip', 'rar', '7z', 'tar', 'gz'].contains(ext)) {
      iconColor = AppColors.amber;
      iconBg = AppColors.amberLight;
      fileIcon = Icons.folder_zip_outlined;
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
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Icon(fileIcon, color: iconColor, size: 32),
                    if (file.isStarred)
                      const Positioned(
                        top: 8,
                        right: 8,
                        child: Icon(
                          Icons.star_rounded,
                          color: AppColors.amber,
                          size: 18,
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              file.name,
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
                Expanded(
                  child: Text(
                    file.sizeFormatted,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textMuted,
                    ),
                  ),
                ),
                InkWell(
                  onTap: onMoreTap,
                  borderRadius: BorderRadius.circular(12),
                  child: const Padding(
                    padding: EdgeInsets.all(4.0),
                    child: Icon(Icons.more_horiz,
                        size: 20, color: AppColors.textMuted),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
