// lib/widgets/path_header.dart

import 'package:flutter/material.dart';
import 'package:veloci_client/theme/theme.dart';

class PathHeader extends StatelessWidget {
  final String currentPath;

  const PathHeader({super.key, required this.currentPath});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: const BoxDecoration(
        color: ZenColors.paperCream,
        border: Border(top: BorderSide(color: ZenColors.softGray, width: 0.5)),
      ),
      child: Row(
        children: [
          // Path icon
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: ZenColors.primarySage.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: ZenColors.primarySage.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: const Icon(
              Icons.folder_open_rounded,
              color: ZenColors.primarySage,
              size: 16,
            ),
          ),
          const SizedBox(width: 12),
          // Path breadcrumb
          Expanded(child: _buildPathBreadcrumb()),
        ],
      ),
    );
  }

  Widget _buildPathBreadcrumb() {
    if (currentPath == '/') {
      return Text(
        'Root Directory',
        style: ZenTextStyles.bodyMedium.copyWith(
          color: ZenColors.darkGray,
          fontWeight: FontWeight.w500,
        ),
      );
    }

    // Split path into segments
    final segments = currentPath.split('/').where((s) => s.isNotEmpty).toList();

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          // Root indicator
          _buildPathSegment('~', true),

          // Path segments
          ...segments.asMap().entries.map((entry) {
            final index = entry.key;
            final segment = entry.value;
            final isLast = index == segments.length - 1;

            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Separator
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: Icon(
                    Icons.chevron_right_rounded,
                    color: ZenColors.mediumGray,
                    size: 16,
                  ),
                ),
                // Segment
                _buildPathSegment(segment, isLast),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildPathSegment(String segment, bool isLast) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isLast
            ? ZenColors.primarySage.withOpacity(0.1)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(6),
        border: isLast
            ? Border.all(
                color: ZenColors.primarySage.withOpacity(0.2),
                width: 1,
              )
            : null,
      ),
      child: Text(
        segment,
        style: ZenTextStyles.labelMedium.copyWith(
          color: isLast ? ZenColors.primarySage : ZenColors.mediumGray,
          fontWeight: isLast ? FontWeight.w600 : FontWeight.w400,
          fontSize: 12,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}
