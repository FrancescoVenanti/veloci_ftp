// lib/models/session_window.dart

import '../models/ftp_session.dart';
import '../services/ftp_service.dart';

enum SessionStatus { connecting, connected, disconnected, error }

class SessionWindow {
  final String id;
  final FTPSession session;
  final FTPService? ftpService;
  final SessionStatus status;
  final String currentPath;
  final List<String> pathHistory;
  final String? error;
  final int refreshTrigger;

  const SessionWindow({
    required this.id,
    required this.session,
    required this.ftpService,
    required this.status,
    required this.currentPath,
    required this.pathHistory,
    this.error,
    this.refreshTrigger = 0,
  });

  SessionWindow copyWith({
    String? id,
    FTPSession? session,
    FTPService? ftpService,
    SessionStatus? status,
    String? currentPath,
    List<String>? pathHistory,
    String? error,
    int? refreshTrigger,
  }) {
    return SessionWindow(
      id: id ?? this.id,
      session: session ?? this.session,
      ftpService: ftpService ?? this.ftpService,
      status: status ?? this.status,
      currentPath: currentPath ?? this.currentPath,
      pathHistory: pathHistory ?? this.pathHistory,
      error: error ?? this.error,
      refreshTrigger: refreshTrigger ?? this.refreshTrigger,
    );
  }

  bool get isConnected =>
      status == SessionStatus.connected && ftpService != null;
  bool get isConnecting => status == SessionStatus.connecting;
  bool get hasError => status == SessionStatus.error;
  bool get canGoBack => pathHistory.length > 1;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SessionWindow &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
