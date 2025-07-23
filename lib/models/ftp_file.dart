class FTPFile {
  final String name;
  final String path;
  final bool isDirectory;
  final int size;
  final DateTime modifiedDate;

  FTPFile({
    required this.name,
    required this.path,
    required this.isDirectory,
    required this.size,
    required this.modifiedDate,
  });
}
