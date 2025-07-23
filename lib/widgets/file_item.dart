import 'package:flutter/material.dart';

class FileItem extends StatelessWidget {
  final String file;
  final String currentPath;
  final Function(bool isDirectory) onTap;

  const FileItem({
    super.key,
    required this.file,
    required this.currentPath,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDirectory = !file.contains('.');

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: ListTile(
        leading: _buildFileIcon(file),
        title: Text(file),
        subtitle: Text(isDirectory ? 'Directory' : 'File'),
        trailing: isDirectory
            ? const Icon(Icons.chevron_right)
            : IconButton(
                icon: const Icon(Icons.more_vert),
                onPressed: () => onTap(false),
              ),
        onTap: () => onTap(isDirectory),
      ),
    );
  }

  Widget _buildFileIcon(String fileName) {
    final extension = fileName.split('.').last.toLowerCase();
    switch (extension) {
      case 'txt':
      case 'md':
      case 'log':
        return const Icon(Icons.description, color: Colors.blue);
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'gif':
        return const Icon(Icons.image, color: Colors.green);
      case 'pdf':
        return const Icon(Icons.picture_as_pdf, color: Colors.red);
      case 'zip':
      case 'rar':
      case '7z':
        return const Icon(Icons.archive, color: Colors.orange);
      case 'mp3':
      case 'wav':
      case 'flac':
        return const Icon(Icons.audiotrack, color: Colors.purple);
      case 'mp4':
      case 'avi':
      case 'mkv':
        return const Icon(Icons.video_file, color: Colors.indigo);
      default:
        return fileName.contains('.')
            ? const Icon(Icons.insert_drive_file, color: Colors.grey)
            : const Icon(Icons.folder, color: Colors.amber);
    }
  }
}
