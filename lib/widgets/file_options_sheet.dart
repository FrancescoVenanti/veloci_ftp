import 'package:flutter/material.dart';
import 'package:ftpconnect/ftpconnect.dart';

class FileOptionsSheet extends StatelessWidget {
  final FTPEntry entry;
  final VoidCallback onDownload;
  final VoidCallback onShowProperties;
  final VoidCallback onDelete;

  const FileOptionsSheet({
    super.key,
    required this.entry,
    required this.onDownload,
    required this.onShowProperties,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 20.0,
              vertical: 8.0,
            ),
            child: Text(
              entry.name,
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w500),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.download_outlined),
            title: const Text('Download'),
            onTap: () {
              Navigator.pop(context);
              onDownload();
            },
          ),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('Properties'),
            onTap: () {
              Navigator.pop(context);
              onShowProperties();
            },
          ),
          ListTile(
            leading: Icon(
              Icons.delete_outline,
              color: Theme.of(context).colorScheme.error,
            ),
            title: Text(
              'Delete',
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
            onTap: () {
              Navigator.pop(context);
              onDelete();
            },
          ),
        ],
      ),
    );
  }
}
