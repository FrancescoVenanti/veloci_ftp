// lib/screens/session_window_content.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:async_wrapper/async_wrapper.dart';
import 'package:ftpconnect/ftpconnect.dart';
import 'package:intl/intl.dart';
import 'package:veloci_client/theme/theme.dart';
import '../models/session_window.dart';
import '../services/session_manager.dart';
import '../widgets/file_item.dart';
import '../widgets/path_header.dart';
import '../utils/file_utils.dart';

class SessionWindowContent extends StatefulWidget {
  final SessionWindow window;

  const SessionWindowContent({super.key, required this.window});

  @override
  State<SessionWindowContent> createState() => _SessionWindowContentState();
}

class _SessionWindowContentState extends State<SessionWindowContent>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true; // Keep state alive when switching tabs

  SessionWindow? _currentWindow;

  @override
  void initState() {
    super.initState();
    _currentWindow = widget.window;

    // Listen to session manager changes for this specific window
    SessionManager.instance.addListener(_onSessionManagerChanged);
  }

  @override
  void dispose() {
    SessionManager.instance.removeListener(_onSessionManagerChanged);
    super.dispose();
  }

  void _onSessionManagerChanged() {
    final updatedWindow = SessionManager.instance.getWindow(widget.window.id);
    if (updatedWindow != null && mounted) {
      setState(() {
        _currentWindow = updatedWindow;
      });
    }
  }

  SessionWindow get currentWindow => _currentWindow ?? widget.window;

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin

    return Column(
      children: [
        _buildWindowHeader(),
        Expanded(child: _buildWindowContent()),
      ],
    );
  }

  Widget _buildWindowHeader() {
    final window = currentWindow;

    return Container(
      decoration: const BoxDecoration(
        color: ZenColors.paperWhite,
        border: Border(bottom: BorderSide(color: ZenColors.softGray, width: 1)),
      ),
      child: Column(
        children: [
          // Title bar
          Container(
            height: 60,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                // Session info
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _getStatusColor(window.status).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: _getStatusColor(window.status).withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: Icon(
                    Icons.cloud_rounded,
                    color: _getStatusColor(window.status),
                    size: 18,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        window.session.name,
                        style: ZenTextStyles.titleLarge.copyWith(
                          fontWeight: FontWeight.w600,
                          color: ZenColors.charcoal,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        '${window.session.username}@${window.session.host}:${window.session.port}',
                        style: ZenTextStyles.labelMedium.copyWith(
                          color: ZenColors.mediumGray,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                // Action buttons
                _buildHeaderActions(),
              ],
            ),
          ),
          // Path header
          if (window.isConnected) PathHeader(currentPath: window.currentPath),
        ],
      ),
    );
  }

  Widget _buildHeaderActions() {
    final window = widget.window;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Back button
        if (window.canGoBack)
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: ZenColors.primarySage.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: ZenColors.primarySage.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: const Icon(
                Icons.arrow_back_rounded,
                color: ZenColors.primarySage,
                size: 18,
              ),
            ),
            onPressed: () {
              HapticFeedback.lightImpact();
              SessionManager.instance.navigateBack(widget.window.id);
            },
            tooltip: 'Go Back',
          ),

        // Refresh button
        if (window.isConnected)
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: ZenColors.accentTeal.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: ZenColors.accentTeal.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: const Icon(
                Icons.refresh_rounded,
                color: ZenColors.accentTeal,
                size: 18,
              ),
            ),
            onPressed: () {
              HapticFeedback.lightImpact();
              SessionManager.instance.refreshWindow(currentWindow.id);
            },
            tooltip: 'Refresh Directory',
          ),

        // Retry connection button (for error state)
        if (window.hasError)
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: ZenColors.warningOrange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: ZenColors.warningOrange.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: const Icon(
                Icons.refresh_rounded,
                color: ZenColors.warningOrange,
                size: 18,
              ),
            ),
            onPressed: () {
              HapticFeedback.lightImpact();
              SessionManager.instance.retryConnection(currentWindow.id);
            },
            tooltip: 'Retry Connection',
          ),
      ],
    );
  }

  Widget _buildWindowContent() {
    final window = currentWindow;

    if (window.isConnecting) {
      return _buildConnectingState();
    }

    if (window.hasError) {
      return _buildErrorState();
    }

    if (!window.isConnected || window.ftpService == null) {
      return _buildDisconnectedState();
    }

    return _buildFileExplorer();
  }

  Widget _buildConnectingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: ZenColors.warningOrange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: ZenColors.warningOrange.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: const CircularProgressIndicator(
              strokeWidth: 3,
              color: ZenColors.warningOrange,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Connecting to ${currentWindow.session.host}...',
            style: ZenTextStyles.bodyLarge.copyWith(
              color: ZenColors.charcoal,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Please wait while we establish the connection',
            style: ZenTextStyles.bodyMedium.copyWith(
              color: ZenColors.mediumGray,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: ZenColors.errorRed.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: ZenColors.errorRed.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: const Icon(
                Icons.wifi_off_rounded,
                size: 48,
                color: ZenColors.errorRed,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Connection Failed',
              style: ZenTextStyles.headlineMedium.copyWith(
                color: ZenColors.charcoal,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              currentWindow.error ?? 'Unknown error occurred',
              textAlign: TextAlign.center,
              style: ZenTextStyles.bodyMedium.copyWith(
                color: ZenColors.mediumGray,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () {
                HapticFeedback.lightImpact();
                SessionManager.instance.retryConnection(currentWindow.id);
              },
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text('Retry Connection'),
              style: ElevatedButton.styleFrom(
                backgroundColor: ZenColors.primarySage,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDisconnectedState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: ZenColors.mediumGray.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: ZenColors.mediumGray.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: const Icon(
              Icons.cloud_off_rounded,
              size: 48,
              color: ZenColors.mediumGray,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Disconnected',
            style: ZenTextStyles.headlineMedium.copyWith(
              color: ZenColors.charcoal,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'The connection has been terminated',
            style: ZenTextStyles.bodyMedium.copyWith(
              color: ZenColors.mediumGray,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFileExplorer() {
    return Stack(
      children: [
        Column(
          children: [
            Expanded(
              child: AsyncWrapper<List<FTPEntry>>(
                key: ValueKey(
                  '${currentWindow.id}_${currentWindow.currentPath}_${currentWindow.refreshTrigger}',
                ),
                autorun: true,
                fetch: () => currentWindow.ftpService!.listDirectory(
                  currentWindow.currentPath,
                ),
                builder: (refetch, state) {
                  if (state.isPending && state.data == null) {
                    return _buildLoadingState();
                  }

                  if (state.isError) {
                    return _buildFileErrorState(
                      state.error.toString(),
                      refetch,
                    );
                  }

                  if (state.isSuccess && state.data != null) {
                    final files = state.data!;
                    if (files.isEmpty) {
                      return _buildEmptyDirectoryState(refetch);
                    }

                    return _buildFileList(files, refetch);
                  }

                  return _buildLoadingState();
                },
              ),
            ),
          ],
        ),
        // Floating action button positioned in stack
        _buildFloatingActionButton(),
      ],
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: ZenColors.primarySage.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: ZenColors.primarySage.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: const CircularProgressIndicator(
              strokeWidth: 3,
              color: ZenColors.primarySage,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Loading directory...',
            style: ZenTextStyles.bodyMedium.copyWith(
              color: ZenColors.mediumGray,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFileErrorState(String error, VoidCallback onRetry) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: ZenColors.errorRed.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: ZenColors.errorRed.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: const Icon(
                Icons.folder_off_rounded,
                size: 48,
                color: ZenColors.errorRed,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Directory Error',
              style: ZenTextStyles.headlineMedium.copyWith(
                color: ZenColors.charcoal,
                fontSize: 20,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              error,
              textAlign: TextAlign.center,
              style: ZenTextStyles.bodyMedium.copyWith(
                color: ZenColors.mediumGray,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () {
                HapticFeedback.lightImpact();
                onRetry();
              },
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: ZenColors.primarySage,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyDirectoryState(Future<void> Function() onRefresh) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      color: ZenColors.primarySage,
      backgroundColor: ZenColors.paperWhite,
      child: Center(
        child: ListView(
          shrinkWrap: true,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: ZenColors.mediumGray.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: ZenColors.mediumGray.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: const Icon(
                    Icons.folder_open_rounded,
                    size: 48,
                    color: ZenColors.mediumGray,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Empty Directory',
                  style: ZenTextStyles.titleLarge.copyWith(
                    color: ZenColors.darkGray,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'This directory contains no files or folders',
                  style: ZenTextStyles.bodyMedium.copyWith(
                    color: ZenColors.mediumGray,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFileList(List<FTPEntry> files, Future<void> Function() refetch) {
    files.sort((a, b) {
      if (a.type == FTPEntryType.DIR && b.type != FTPEntryType.DIR) return -1;
      if (a.type != FTPEntryType.DIR && b.type == FTPEntryType.DIR) return 1;
      return a.name.toLowerCase().compareTo(b.name.toLowerCase());
    });

    return RefreshIndicator(
      onRefresh: refetch,
      color: ZenColors.primarySage,
      backgroundColor: ZenColors.paperWhite,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: files.length,
        separatorBuilder: (context, index) => const SizedBox(height: 4),
        itemBuilder: (context, index) {
          final entry = files[index];
          return FileItem(
            entry: entry,
            onTap: () {
              if (entry.type == FTPEntryType.DIR) {
                _navigateToDirectory(entry.name);
              } else {
                _showFileOptions(entry);
              }
            },
          );
        },
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    if (!currentWindow.isConnected) return const SizedBox.shrink();

    return Positioned(
      bottom: 20,
      right: 20,
      child: FloatingActionButton.extended(
        onPressed: () {
          HapticFeedback.lightImpact();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Icon(
                      Icons.construction_rounded,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Upload functionality is coming soon',
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                ],
              ),
              backgroundColor: ZenColors.accentBlue,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              margin: const EdgeInsets.all(16),
            ),
          );
        },
        backgroundColor: ZenColors.primarySage,
        foregroundColor: Colors.white,
        elevation: 2,
        icon: const Icon(Icons.upload_rounded, size: 20),
        label: const Text(
          'Upload',
          style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
        ),
      ),
    );
  }

  void _navigateToDirectory(String dirName) {
    final currentPath = currentWindow.currentPath;
    final newPath = currentPath == '/' ? '/$dirName' : '$currentPath/$dirName';

    HapticFeedback.lightImpact();
    SessionManager.instance.updateWindowNavigation(currentWindow.id, newPath);
  }

  void _showFileOptions(FTPEntry entry) {
    HapticFeedback.lightImpact();
    showModalBottomSheet(
      context: context,
      backgroundColor: ZenColors.paperWhite,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: ZenColors.primarySage.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: ZenColors.primarySage.withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                    child: const Icon(
                      Icons.insert_drive_file_rounded,
                      color: ZenColors.primarySage,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          entry.name,
                          style: ZenTextStyles.titleLarge.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'File options',
                          style: ZenTextStyles.labelMedium.copyWith(
                            color: ZenColors.mediumGray,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Divider(color: ZenColors.softGray),
            // Actions
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: ZenColors.accentBlue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Icon(
                  Icons.download_rounded,
                  color: ZenColors.accentBlue,
                  size: 20,
                ),
              ),
              title: const Text('Download'),
              onTap: () {
                Navigator.pop(context);
                _downloadFile(entry.name);
              },
            ),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: ZenColors.accentTeal.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Icon(
                  Icons.info_outline_rounded,
                  color: ZenColors.accentTeal,
                  size: 20,
                ),
              ),
              title: const Text('Properties'),
              onTap: () {
                Navigator.pop(context);
                _showFileProperties(entry);
              },
            ),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: ZenColors.errorRed.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Icon(
                  Icons.delete_outline_rounded,
                  color: ZenColors.errorRed,
                  size: 20,
                ),
              ),
              title: Text(
                'Delete',
                style: TextStyle(color: ZenColors.errorRed),
              ),
              onTap: () {
                Navigator.pop(context);
                _showDeleteConfirmation(entry.name);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _downloadFile(String fileName) async {
    try {
      final localDir = await getDownloadDirectory();
      if (localDir == null) {
        throw Exception("Could not determine download directory.");
      }
      final localPath = '$localDir/$fileName';
      final remotePath = _buildRemotePath(fileName);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              SizedBox(
                width: 20,
                height: 20,
                child: const CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
              const SizedBox(width: 12),
              Text('Downloading $fileName...'),
            ],
          ),
          backgroundColor: ZenColors.accentBlue,
          behavior: SnackBarBehavior.floating,
        ),
      );

      await currentWindow.ftpService!.downloadFile(remotePath, localPath);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Icon(
                    Icons.check_rounded,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
                const SizedBox(width: 12),
                const Text('Downloaded to Downloads folder'),
              ],
            ),
            backgroundColor: ZenColors.successGreen,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Icon(
                    Icons.error_outline_rounded,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(child: Text('Download failed: $e')),
              ],
            ),
            backgroundColor: ZenColors.errorRed,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _deleteFile(String fileName) async {
    try {
      final remotePath = _buildRemotePath(fileName);
      await currentWindow.ftpService!.deleteFile(remotePath);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Icon(
                    Icons.check_rounded,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
                const SizedBox(width: 12),
                Text('$fileName deleted'),
              ],
            ),
            backgroundColor: ZenColors.successGreen,
            behavior: SnackBarBehavior.floating,
          ),
        );
        SessionManager.instance.refreshWindow(widget.window.id);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Icon(
                    Icons.error_outline_rounded,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(child: Text('Delete failed: $e')),
              ],
            ),
            backgroundColor: ZenColors.errorRed,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _showDeleteConfirmation(String fileName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: ZenColors.paperWhite,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: ZenColors.errorRed.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.delete_outline_rounded,
                color: ZenColors.errorRed,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            const Text('Delete File'),
          ],
        ),
        content: Text(
          'Are you sure you want to delete "$fileName"?\n\nThis action cannot be undone.',
          style: ZenTextStyles.bodyMedium.copyWith(height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: ZenColors.mediumGray,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _deleteFile(fileName);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: ZenColors.errorRed,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showFileProperties(FTPEntry entry) {
    final size = entry.size != null ? _formatFileSize(entry.size!) : 'Unknown';
    final modified = entry.modifyTime != null
        ? DateFormat.yMMMd().add_jms().format(entry.modifyTime!)
        : 'Unknown';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: ZenColors.paperWhite,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: ZenColors.accentTeal.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.info_outline_rounded,
                color: ZenColors.accentTeal,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            const Text('File Properties'),
          ],
        ),
        content: Container(
          constraints: const BoxConstraints(maxWidth: 300),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildPropertyRow('Name', entry.name),
              const SizedBox(height: 12),
              _buildPropertyRow('Path', _buildRemotePath(entry.name)),
              const SizedBox(height: 12),
              _buildPropertyRow('Size', size),
              const SizedBox(height: 12),
              _buildPropertyRow('Modified', modified),
              const SizedBox(height: 12),
              _buildPropertyRow(
                'Type',
                entry.type == FTPEntryType.DIR ? 'Directory' : 'File',
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Close',
              style: TextStyle(
                color: ZenColors.primarySage,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPropertyRow(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: ZenTextStyles.labelMedium.copyWith(
            color: ZenColors.mediumGray,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: ZenColors.paperCream,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: ZenColors.softGray, width: 0.5),
          ),
          child: Text(
            value,
            style: ZenTextStyles.bodyMedium.copyWith(
              color: ZenColors.charcoal,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  String _buildRemotePath(String fileName) {
    final currentPath = currentWindow.currentPath;
    return currentPath == '/' ? '/$fileName' : '$currentPath/$fileName';
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024)
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  Color _getStatusColor(SessionStatus status) {
    switch (status) {
      case SessionStatus.connected:
        return ZenColors.successGreen;
      case SessionStatus.connecting:
        return ZenColors.warningOrange;
      case SessionStatus.error:
        return ZenColors.errorRed;
      case SessionStatus.disconnected:
        return ZenColors.mediumGray;
    }
  }
}
