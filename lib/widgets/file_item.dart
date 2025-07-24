// lib/widgets/file_item.dart

import 'package:flutter/material.dart';
import 'package:ftpconnect/ftpconnect.dart';
import 'package:intl/intl.dart';
import 'package:veloci_client/theme/theme.dart';

class FileItem extends StatelessWidget {
  final FTPEntry entry;
  final VoidCallback onTap;

  const FileItem({super.key, required this.entry, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDirectory = entry.type == FTPEntryType.DIR;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          splashColor: ZenColors.primarySage.withOpacity(0.1),
          highlightColor: ZenColors.primarySage.withOpacity(0.05),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: ZenColors.paperWhite,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: ZenColors.softGray.withOpacity(0.3),
                width: 0.5,
              ),
            ),
            child: Row(
              children: [
                // File icon with zen styling
                _buildZenFileIcon(entry),
                const SizedBox(width: 16),
                // File details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        entry.name,
                        style: ZenTextStyles.bodyLarge.copyWith(
                          fontWeight: FontWeight.w500,
                          color: ZenColors.charcoal,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _buildSubtitle(isDirectory),
                        style: ZenTextStyles.labelMedium.copyWith(
                          color: ZenColors.mediumGray,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                // Trailing icon for directories
                if (isDirectory)
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: ZenColors.primarySage.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Icon(
                      Icons.chevron_right_rounded,
                      color: ZenColors.primarySage,
                      size: 18,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildZenFileIcon(FTPEntry entry) {
    if (entry.type == FTPEntryType.DIR) {
      return Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: ZenColors.accentAmber.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: ZenColors.accentAmber.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: const Icon(
          Icons.folder_rounded,
          color: ZenColors.accentAmber,
          size: 24,
        ),
      );
    }

    final extension = entry.name.split('.').last.toLowerCase();
    final fileType = _getFileType(extension);

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: fileType.color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: fileType.color.withOpacity(0.2), width: 1),
      ),
      child: Icon(fileType.icon, color: fileType.color, size: 24),
    );
  }

  String _buildSubtitle(bool isDirectory) {
    if (isDirectory) {
      return 'Directory';
    }

    final size = entry.size != null
        ? _formatFileSize(entry.size!)
        : 'Unknown size';

    final modified = entry.modifyTime != null
        ? DateFormat.yMMMd().format(entry.modifyTime!)
        : 'Unknown date';

    return '$size • $modified';
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024)
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  FileTypeInfo _getFileType(String extension) {
    switch (extension) {
      // Text files
      case 'txt':
      case 'md':
      case 'log':
      case 'readme':
        return FileTypeInfo(
          icon: Icons.article_rounded,
          color: ZenColors.accentBlue,
        );

      // Images
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'gif':
      case 'webp':
      case 'svg':
        return FileTypeInfo(
          icon: Icons.image_rounded,
          color: ZenColors.successGreen,
        );

      // Documents
      case 'pdf':
        return FileTypeInfo(
          icon: Icons.picture_as_pdf_rounded,
          color: ZenColors.errorRed,
        );

      case 'doc':
      case 'docx':
        return FileTypeInfo(
          icon: Icons.description_rounded,
          color: ZenColors.accentBlue,
        );

      case 'xls':
      case 'xlsx':
        return FileTypeInfo(
          icon: Icons.table_chart_rounded,
          color: ZenColors.successGreen,
        );

      case 'ppt':
      case 'pptx':
        return FileTypeInfo(
          icon: Icons.slideshow_rounded,
          color: ZenColors.warningOrange,
        );

      // Archives
      case 'zip':
      case 'rar':
      case '7z':
      case 'tar':
      case 'gz':
        return FileTypeInfo(
          icon: Icons.archive_rounded,
          color: ZenColors.warningOrange,
        );

      // Audio
      case 'mp3':
      case 'wav':
      case 'flac':
      case 'aac':
      case 'ogg':
        return FileTypeInfo(
          icon: Icons.music_note_rounded,
          color: ZenColors.accentTeal,
        );

      // Video
      case 'mp4':
      case 'avi':
      case 'mkv':
      case 'mov':
      case 'wmv':
      case 'flv':
        return FileTypeInfo(
          icon: Icons.videocam_rounded,
          color: ZenColors.accentBlue,
        );

      // Code files
      case 'dart':
      case 'js':
      case 'ts':
      case 'html':
      case 'css':
      case 'py':
      case 'java':
      case 'cpp':
      case 'cs':
      case 'php':
        return FileTypeInfo(
          icon: Icons.code_rounded,
          color: ZenColors.primarySage,
        );

      // Configuration files
      case 'json':
      case 'xml':
      case 'yml':
      case 'yaml':
      case 'toml':
      case 'ini':
        return FileTypeInfo(
          icon: Icons.settings_rounded,
          color: ZenColors.mediumGray,
        );

      // Executables
      case 'exe':
      case 'msi':
      case 'deb':
      case 'rpm':
      case 'dmg':
      case 'app':
        return FileTypeInfo(
          icon: Icons.launch_rounded,
          color: ZenColors.primarySageDark,
        );

      // Default
      default:
        return FileTypeInfo(
          icon: Icons.insert_drive_file_rounded,
          color: ZenColors.mediumGray,
        );
    }
  }
}

class FileTypeInfo {
  final IconData icon;
  final Color color;

  const FileTypeInfo({required this.icon, required this.color});
}
