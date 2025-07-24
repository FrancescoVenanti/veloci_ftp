// lib/screens/ftp_home_page.dart

import 'package:flutter/material.dart';
import 'package:async_wrapper/async_wrapper.dart';
import 'package:ftpconnect/ftpconnect.dart';
import 'package:intl/intl.dart';
import '../services/ftp_service.dart';
import '../widgets/file_item.dart';
import '../widgets/path_header.dart';
import '../widgets/error_state_widget.dart';
import '../widgets/empty_directory_widget.dart';
import '../widgets/file_options_sheet.dart';
import '../utils/path_utils.dart';
import '../utils/file_utils.dart';

class FTPHomePage extends StatefulWidget {
  final FTPService ftpService;

  const FTPHomePage({super.key, required this.ftpService});

  @override
  State<FTPHomePage> createState() => _FTPHomePageState();
}

class _FTPHomePageState extends State<FTPHomePage> {
  String _currentPath = '/';
  final List<String> _pathHistory = ['/'];
  int _refreshTrigger = 0;

  @override
  void dispose() {
    widget.ftpService.disconnect();
    super.dispose();
  }

  void _navigateToPath(String path) {
    final newPath = PathUtils.combinePath(_currentPath, path);
    if (_currentPath == newPath) return;

    setState(() {
      _currentPath = newPath;
      _pathHistory.add(newPath);
      _refreshTrigger++;
    });
  }

  void _navigateBack() {
    if (_pathHistory.length > 1) {
      setState(() {
        _pathHistory.removeLast();
        _currentPath = _pathHistory.last;
        _refreshTrigger++;
      });
    }
  }

  void _refresh() {
    setState(() => _refreshTrigger++);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return PopScope(
      canPop: _pathHistory.length <= 1,
      onPopInvoked: (didPop) {
        if (didPop) return;
        _navigateBack();
      },
      child: Scaffold(
        appBar: _buildAppBar(theme),
        body: _buildBody(),
        floatingActionButton: _buildFloatingActionButton(),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(ThemeData theme) {
    return AppBar(
      title: const Text(
        'VelociFTP',
        style: TextStyle(fontWeight: FontWeight.w400),
      ),
      leading: IconButton(
        icon: Icon(_pathHistory.length > 1 ? Icons.arrow_back : Icons.logout),
        onPressed: () {
          if (_pathHistory.length > 1) {
            _navigateBack();
          } else {
            Navigator.of(context).pop();
          }
        },
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh_outlined),
          onPressed: _refresh,
          tooltip: 'Refresh',
        ),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(40),
        child: PathHeader(currentPath: _currentPath),
      ),
      backgroundColor: theme.colorScheme.surface,
      elevation: 0,
      foregroundColor: theme.colorScheme.onSurface,
    );
  }

  Widget _buildBody() {
    return AsyncWrapper<List<FTPEntry>>(
      key: ValueKey(_refreshTrigger),
      autorun: true,
      fetch: () => widget.ftpService.listDirectory(_currentPath),
      builder: (refetch, state) {
        if (state.isPending && state.data == null) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state.isError) {
          return ErrorStateWidget(
            error: state.error.toString(),
            onRetry: refetch,
          );
        }

        if (state.isSuccess && state.data != null) {
          final files = state.data!;
          if (files.isEmpty) {
            return EmptyDirectoryWidget(onRefresh: refetch);
          }

          return _buildFileList(files, refetch);
        }

        return const Center(child: CircularProgressIndicator());
      },
    );
  }

  Widget _buildFileList(List<FTPEntry> files, Future<void> Function() refetch) {
    final theme = Theme.of(context);

    files.sort((a, b) {
      if (a.type == FTPEntryType.DIR && b.type != FTPEntryType.DIR) return -1;
      if (a.type != FTPEntryType.DIR && b.type == FTPEntryType.DIR) return 1;
      return a.name.toLowerCase().compareTo(b.name.toLowerCase());
    });

    return RefreshIndicator(
      onRefresh: refetch,
      child: ListView.separated(
        itemCount: files.length,
        separatorBuilder: (context, index) => Divider(
          height: 1,
          indent: 72,
          color: theme.dividerColor.withOpacity(0.1),
        ),
        itemBuilder: (context, index) {
          final entry = files[index];
          return FileItem(
            entry: entry,
            onTap: () {
              if (entry.type == FTPEntryType.DIR) {
                _navigateToPath(entry.name);
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
    return FloatingActionButton(
      onPressed: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Upload functionality is not yet implemented.'),
          ),
        );
      },
      tooltip: 'Upload File',
      child: const Icon(Icons.add_outlined),
    );
  }

  void _showFileOptions(FTPEntry entry) {
    showModalBottomSheet(
      context: context,
      builder: (context) => FileOptionsSheet(
        entry: entry,
        onDownload: () => _downloadFile(entry.name),
        onShowProperties: () => _showFileProperties(entry),
        onDelete: () => _showDeleteConfirmation(entry.name),
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
      final remotePath = PathUtils.buildRemotePath(_currentPath, fileName);

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Downloading $fileName...')));

      await widget.ftpService.downloadFile(remotePath, localPath);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Downloaded to Downloads folder'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Download failed: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  void _deleteFile(String fileName) async {
    try {
      final remotePath = PathUtils.buildRemotePath(_currentPath, fileName);
      await widget.ftpService.deleteFile(remotePath);

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('$fileName deleted')));
        _refresh();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Delete failed: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  void _showDeleteConfirmation(String fileName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete File'),
        content: Text(
          'Are you sure you want to delete "$fileName"? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteFile(fileName);
            },
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showFileProperties(FTPEntry entry) {
    final size = entry.size != null
        ? NumberFormat.compact().format(entry.size)
        : 'Unknown';
    final modified = entry.modifyTime != null
        ? DateFormat.yMMMd().add_jms().format(entry.modifyTime!)
        : 'Unknown';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Properties'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Name: ${entry.name}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Path: ${PathUtils.buildRemotePath(_currentPath, entry.name)}',
            ),
            const SizedBox(height: 8),
            Text('Size: $size'),
            const SizedBox(height: 8),
            Text('Modified: $modified'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
