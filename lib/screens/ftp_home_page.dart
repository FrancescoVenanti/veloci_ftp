import 'dart:io';

import 'package:flutter/material.dart';
import 'package:async_wrapper/async_wrapper.dart';
import 'package:veloci_client/utils/utils.dart';
import '../services/ftp_service.dart';
import '../widgets/file_item.dart';
import '../widgets/path_header.dart';

class FTPHomePage extends StatefulWidget {
  final FTPService ftpService;

  const FTPHomePage({super.key, required this.ftpService});

  @override
  State<FTPHomePage> createState() => _FTPHomePageState();
}

class _FTPHomePageState extends State<FTPHomePage> {
  String _currentPath = '/';
  final List<String> _pathHistory = ['/'];
  String? _selectedFile;
  int _refreshTrigger = 0;

  String _normalizePath(String path) {
    if (path.isEmpty) return '/';

    // Split path into segments and filter out empty ones
    List<String> segments = path.split('/').where((s) => s.isNotEmpty).toList();

    // If no segments, return root
    if (segments.isEmpty) return '/';

    // Join segments back with single slashes
    return '/${segments.join('/')}';
  }

  void _navigateToPath(String path) {
    String newPath;

    if (path.startsWith('/')) {
      // Absolute path
      newPath = _normalizePath(path);
    } else {
      // Relative path - append to current path
      if (_currentPath == '/') {
        newPath = '/$path';
      } else {
        newPath = '$_currentPath/$path';
      }
      newPath = _normalizePath(newPath);
    }

    if (_currentPath == newPath) return;

    setState(() {
      _currentPath = newPath;
      _pathHistory.add(newPath);
      _selectedFile = null;
      _refreshTrigger++;
    });
  }

  void _navigateBack() {
    if (_pathHistory.length > 1) {
      setState(() {
        _pathHistory.removeLast();
        _currentPath = _pathHistory.last;
        _selectedFile = null;
        _refreshTrigger++;
      });
    }
  }

  void _refresh() {
    setState(() {
      _refreshTrigger++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('VelociFTP'),
        leading: _pathHistory.length > 1
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: _navigateBack,
              )
            : IconButton(
                icon: const Icon(Icons.logout),
                onPressed: () => Navigator.pop(context),
              ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: PathHeader(currentPath: _currentPath),
        ),
      ),
      body: AsyncWrapper<List<String>>(
        fetch: () async {
          // Reference _refreshTrigger to make fetch depend on it
          _refreshTrigger;
          return await widget.ftpService.listDirectory(_currentPath);
        },
        autorun: true,
        builder: (run, state) {
          if (state.isPending) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Loading directory...'),
                ],
              ),
            );
          }

          if (state.isError) {
            return Center(
              child: Card(
                margin: const EdgeInsets.all(16),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 64,
                        color: Colors.red.shade400,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Connection Error',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${state.error}',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: run,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }

          if (state.isSuccess && state.data != null) {
            final files = state.data!;
            return Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          '${files.length} items',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurfaceVariant,
                              ),
                        ),
                      ),
                      IconButton(
                        onPressed: run,
                        icon: const Icon(Icons.refresh),
                        tooltip: 'Refresh',
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: files.isEmpty
                      ? const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.folder_open,
                                size: 64,
                                color: Colors.grey,
                              ),
                              SizedBox(height: 16),
                              Text('This directory is empty'),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          itemCount: files.length,
                          itemBuilder: (context, index) {
                            final file = files[index];
                            return FileItem(
                              file: file,
                              currentPath: _currentPath,
                              onTap: (isDirectory) => isDirectory
                                  ? _navigateToPath(file)
                                  : _showFileOptions(file),
                            );
                          },
                        ),
                ),
              ],
            );
          }

          return const Center(child: Text('No data available'));
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Upload functionality coming soon!'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        },
        child: const Icon(Icons.upload_file),
      ),
    );
  }

  void _showFileOptions(String fileName) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade600,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              fileName,
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.download),
              title: const Text('Download'),
              onTap: () {
                Navigator.pop(context);
                _downloadFile(fileName);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Delete', style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(context);
                _showDeleteConfirmation(fileName);
              },
            ),
            ListTile(
              leading: const Icon(Icons.info),
              title: const Text('Properties'),
              onTap: () {
                Navigator.pop(context);
                _showFileProperties(fileName);
              },
            ),
          ],
        ),
      ),
    );
  }

  String _buildRemotePath(String fileName) {
    if (_currentPath == '/') {
      return '/$fileName';
    } else {
      return '$_currentPath/$fileName';
    }
  }

  void _downloadFile(String fileName) async {
    try {
      final localDir = await getDownloadDirectory();
      final localPath = '$localDir/$fileName';
      final remotePath = _buildRemotePath(fileName);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Downloading $fileName...'),
          backgroundColor: Colors.green.shade700,
          behavior: SnackBarBehavior.floating,
        ),
      );

      await widget.ftpService.downloadFile(remotePath, localPath);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Downloaded to $localPath'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to download: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _deleteFile(String fileName) async {
    try {
      final remotePath = _buildRemotePath(fileName);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Deleting $fileName...'),
          backgroundColor: Colors.orange.shade700,
          behavior: SnackBarBehavior.floating,
        ),
      );

      await widget.ftpService.deleteFile(remotePath);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$fileName deleted'),
            backgroundColor: Colors.orange,
            behavior: SnackBarBehavior.floating,
          ),
        );

        // Refresh the directory listing after deletion
        _refresh();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete: $e'),
            backgroundColor: Colors.red,
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
        title: const Text('Delete File'),
        content: Text('Are you sure you want to delete "$fileName"?'),
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
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showFileProperties(String fileName) {
    final fullPath = _buildRemotePath(fileName);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Properties: $fileName'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Name: $fileName'),
            Text('Full Path: $fullPath'),
            Text('Current Directory: $_currentPath'),
            const Text('Size: Unknown'),
            const Text('Modified: Unknown'),
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
