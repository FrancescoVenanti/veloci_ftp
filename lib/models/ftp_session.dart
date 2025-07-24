class FTPSession {
  final String id;
  final String name;
  final String host;
  final String username;
  final String password;
  final int port;

  FTPSession({
    required this.id,
    required this.name,
    required this.host,
    required this.username,
    required this.password,
    this.port = 21,
  });

  // Convert to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'host': host,
      'username': username,
      'password': password,
      'port': port,
    };
  }

  // Create from JSON
  factory FTPSession.fromJson(Map<String, dynamic> json) {
    return FTPSession(
      id: json['id'],
      name: json['name'],
      host: json['host'],
      username: json['username'],
      password: json['password'],
      port: json['port'] ?? 21,
    );
  }

  // Create a copy with updated fields
  FTPSession copyWith({
    String? id,
    String? name,
    String? host,
    String? username,
    String? password,
    int? port,
  }) {
    return FTPSession(
      id: id ?? this.id,
      name: name ?? this.name,
      host: host ?? this.host,
      username: username ?? this.username,
      password: password ?? this.password,
      port: port ?? this.port,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FTPSession && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
