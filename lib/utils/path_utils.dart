class PathUtils {
  static String normalizePath(String path) {
    if (path.isEmpty || path == '/') return '/';
    return path.endsWith('/') ? path.substring(0, path.length - 1) : path;
  }

  static String buildRemotePath(String currentPath, String fileName) {
    return currentPath == '/' ? '/$fileName' : '$currentPath/$fileName';
  }

  static String combinePath(String currentPath, String newPath) {
    return normalizePath(
      currentPath == '/' ? '/$newPath' : '$currentPath/$newPath',
    );
  }
}
