import 'dart:io';
import 'package:ftpconnect/ftpconnect.dart';

class FTPService {
  final String host;
  final String user;
  final String pass;
  final int port;
  final bool debug;

  late FTPConnect _ftp;

  FTPService({
    required this.host,
    required this.user,
    required this.pass,
    this.port = 21,
    this.debug = false,
  }) {
    _ftp = FTPConnect(host, user: user, pass: pass, port: port);
  }

  Future<List<String>> listDirectory([String path = '/']) async {
    try {
      await _ftp.connect();

      if (path.isNotEmpty && path != '/') {
        await _ftp.changeDirectory(path);
      }

      final files = await _ftp.listDirectoryContent();

      await _ftp.disconnect();

      return files.map((file) => file.name).toList();
    } catch (e) {
      await _safeDisconnect();
      rethrow;
    }
  }

  Future<void> downloadFile(String remotePath, String localPath) async {
    try {
      await _ftp.connect();

      final file = File(localPath);
      final success = await _ftp.downloadFile(remotePath, file);

      if (!success) {
        throw Exception('Failed to download $remotePath');
      }

      await _ftp.disconnect();
    } catch (e) {
      await _safeDisconnect();
      rethrow;
    }
  }

  Future<void> uploadFile(String localPath, [String? remotePath]) async {
    try {
      await _ftp.connect();

      final file = File(localPath);
      final success = await _ftp.uploadFileWithRetry(
        file,
        pRemoteName: remotePath ?? "",
      );

      if (!success) {
        throw Exception('Failed to upload $localPath');
      }

      await _ftp.disconnect();
    } catch (e) {
      await _safeDisconnect();
      rethrow;
    }
  }

  Future<void> deleteFile(String path) async {
    try {
      await _ftp.connect();
      await _ftp.deleteFile(path);
      await _ftp.disconnect();
    } catch (e) {
      await _safeDisconnect();
      rethrow;
    }
  }

  Future<void> createDirectory(String path) async {
    try {
      await _ftp.connect();
      await _ftp.makeDirectory(path);
      await _ftp.disconnect();
    } catch (e) {
      await _safeDisconnect();
      rethrow;
    }
  }

  Future<String> getCurrentDirectory() async {
    try {
      await _ftp.connect();
      final dir = await _ftp.currentDirectory();
      await _ftp.disconnect();
      return dir;
    } catch (e) {
      await _safeDisconnect();
      rethrow;
    }
  }

  Future<void> changeDirectory(String path) async {
    try {
      await _ftp.connect();
      await _ftp.changeDirectory(path);
      await _ftp.disconnect();
    } catch (e) {
      await _safeDisconnect();
      rethrow;
    }
  }

  Future<void> _safeDisconnect() async {
    try {
      await _ftp.disconnect();
    } catch (err) {
      throw Exception(err);
    }
  }
}
