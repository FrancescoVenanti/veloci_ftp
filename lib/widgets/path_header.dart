import 'package:flutter/material.dart';

class PathHeader extends StatelessWidget {
  final String currentPath;

  const PathHeader({super.key, required this.currentPath});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          const Icon(Icons.folder_open, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              currentPath,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
