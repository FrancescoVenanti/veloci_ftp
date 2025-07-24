import 'package:flutter/material.dart';
import 'package:ftpconnect/ftpconnect.dart';
import 'package:intl/intl.dart';

class FileItem extends StatelessWidget {
  final FTPEntry entry;
  final VoidCallback onTap;

  const FileItem({super.key, required this.entry, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDirectory = entry.type == FTPEntryType.DIR;
    final theme = Theme.of(context);

    return ListTile(
      leading: _buildFileIcon(entry),
      title: Text(entry.name, style: TextStyle(fontWeight: FontWeight.w500)),
      subtitle: Text(
        isDirectory
            ? 'Directory'
            : '${NumberFormat.compact().format(entry.size)} - ${DateFormat.yMMMd().format(entry.modifyTime!)}',
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
      trailing: isDirectory ? const Icon(Icons.chevron_right) : null,
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
    );
  }

  Widget _buildFileIcon(FTPEntry entry) {
    if (entry.type == FTPEntryType.DIR) {
      return Icon(
        Icons.folder_outlined,
        color: Colors.amber.shade700,
        size: 40,
      );
    }

    final extension = entry.name.split('.').last.toLowerCase();
    IconData iconData;
    Color color;

    switch (extension) {
      case 'txt':
      case 'md':
      case 'log':
        iconData = Icons.article_outlined;
        color = Colors.blue.shade400;
        break;
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'gif':
        iconData = Icons.image_outlined;
        color = Colors.green.shade400;
        break;
      case 'pdf':
        iconData = Icons.picture_as_pdf_outlined;
        color = Colors.red.shade400;
        break;
      case 'zip':
      case 'rar':
      case '7z':
        iconData = Icons.archive_outlined;
        color = Colors.orange.shade400;
        break;
      case 'mp3':
      case 'wav':
      case 'flac':
        iconData = Icons.music_note_outlined;
        color = Colors.purple.shade400;
        break;
      case 'mp4':
      case 'avi':
      case 'mkv':
        iconData = Icons.videocam_outlined;
        color = Colors.indigo.shade400;
        break;
      default:
        iconData = Icons.insert_drive_file_outlined;
        color = Colors.grey.shade500;
    }
    return Icon(iconData, color: color, size: 40);
  }
}
