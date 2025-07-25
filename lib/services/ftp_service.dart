import 'dart:io';
import 'package:ftpconnect/ftpconnect.dart';

class FTPService {
  final String host;
  final String user;
  final String pass;
  final int port;

  final FTPConnect _ftp;

  FTPService({
    required this.host,
    required this.user,
    required this.pass,
    this.port = 21,
  }) : _ftp = FTPConnect(
         host,
         user: user,
         pass: pass,
         port: port,
         showLog: true,
       );

  /// Connects to the FTP server. Must be called before other methods.
  Future<void> connect() async {
    await _ftp.connect();
  }

  /// Disconnects from the FTP server.
  Future<void> disconnect() async {
    try {
      await _ftp.disconnect();
    } catch (e) {
      // Ignore errors on disconnect, as the connection might already be closed.
      print('Error during disconnect: $e');
    }
  }

  /// Lists the contents of a specified directory.
  /// Assumes an active connection.
  Future<List<FTPEntry>> listDirectory([String path = '/']) async {
    // Navigate to the correct directory first. The path from the UI is always absolute.
    await _ftp.changeDirectory(path);
    // Then list the contents of the *current* directory using the correct method.
    final files = await _ftp.listDirectoryContent();
    return files;
  }

  /// Downloads a remote file to a local path.
  /// Assumes an active connection.
  Future<void> downloadFile(String remotePath, String localPath) async {
    final file = File(localPath);
    final success = await _ftp.downloadFile(remotePath, file);
    if (!success) {
      throw Exception('Failed to download $remotePath');
    }
  }

  /// Deletes a file on the server.
  /// Assumes an active connection.
  Future<void> deleteFile(String path) async {
    await _ftp.deleteFile(path);
  }

  /// Uploads a local file to the specified remote path.
  /// Assumes an active connection.
  Future<void> uploadFile(String localPath, String remotePath) async {
    final file = File(localPath);

    if (!await file.exists()) {
      throw Exception('Local file does not exist: $localPath');
    }

    final success = await _ftp.uploadFile(file, sRemoteName: remotePath);

    if (!success) {
      throw Exception('Failed to upload $localPath to $remotePath');
    }
  }
}
