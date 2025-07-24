import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

Future<String?> getDownloadDirectory() async {
  if (kIsWeb) return null;

  if (Platform.isAndroid) {
    // import 'package:downloads_path_provider_28/downloads_path_provider_28.dart';
    // Use external downloads directory
    throw Exception("android not handled");
  } else if (Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
    final dir = await getDownloadsDirectory(); // path_provider
    return dir?.path;
  } else if (Platform.isIOS) {
    // iOS has no Downloads folder; fallback to Documents
    final dir = await getApplicationDocumentsDirectory();
    return dir.path;
  }

  return null;
}
