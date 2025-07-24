// lib/services/session_manager.dart

import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/ftp_session.dart';
import '../models/session_window.dart';
import 'ftp_service.dart';
import 'session_service.dart';

class SessionManager extends ChangeNotifier {
  static SessionManager? _instance;
  static SessionManager get instance {
    _instance ??= SessionManager._();
    return _instance!;
  }

  SessionManager._();

  final Map<String, SessionWindow> _activeWindows = {};
  String? _currentWindowId;

  List<SessionWindow> get activeWindows => _activeWindows.values.toList();
  SessionWindow? get currentWindow =>
      _currentWindowId != null ? _activeWindows[_currentWindowId] : null;

  String? get currentWindowId => _currentWindowId;
  bool get hasActiveWindows => _activeWindows.isNotEmpty;

  /// Open a new session window
  Future<SessionWindow> openSessionWindow(FTPSession session) async {
    final windowId = _generateWindowId();

    try {
      // Create FTP service for this session
      final ftpService = FTPService(
        host: session.host,
        user: session.username,
        pass: session.password,
        port: session.port,
      );

      // Attempt connection
      await ftpService.connect();

      // Create session window
      final window = SessionWindow(
        id: windowId,
        session: session,
        ftpService: ftpService,
        status: SessionStatus.connected,
        currentPath: '/',
        pathHistory: ['/'],
      );

      _activeWindows[windowId] = window;
      _currentWindowId = windowId;

      notifyListeners();
      return window;
    } catch (e) {
      // If connection fails, create window in error state
      final window = SessionWindow(
        id: windowId,
        session: session,
        ftpService: null,
        status: SessionStatus.error,
        currentPath: '/',
        pathHistory: ['/'],
        error: e.toString(),
      );

      _activeWindows[windowId] = window;
      _currentWindowId = windowId;

      notifyListeners();
      return window;
    }
  }

  /// Switch to a specific window
  void switchToWindow(String windowId) {
    if (_activeWindows.containsKey(windowId)) {
      _currentWindowId = windowId;
      notifyListeners();
    }
  }

  /// Close a session window
  Future<void> closeWindow(String windowId) async {
    final window = _activeWindows[windowId];
    if (window != null) {
      // Disconnect FTP service if connected
      if (window.ftpService != null) {
        await window.ftpService!.disconnect();
      }

      _activeWindows.remove(windowId);

      // Switch to another window if current was closed
      if (_currentWindowId == windowId) {
        if (_activeWindows.isNotEmpty) {
          _currentWindowId = _activeWindows.keys.first;
        } else {
          _currentWindowId = null;
        }
      }

      notifyListeners();
    }
  }

  /// Update window navigation
  void updateWindowNavigation(String windowId, String newPath) {
    final window = _activeWindows[windowId];
    if (window != null) {
      final updatedHistory = List<String>.from(window.pathHistory);
      if (updatedHistory.isEmpty || updatedHistory.last != newPath) {
        updatedHistory.add(newPath);
      }

      _activeWindows[windowId] = window.copyWith(
        currentPath: newPath,
        pathHistory: updatedHistory,
        refreshTrigger: DateTime.now().millisecondsSinceEpoch, // Force refresh
      );

      notifyListeners();
    }
  }

  /// Navigate back in window history
  void navigateBack(String windowId) {
    final window = _activeWindows[windowId];
    if (window != null && window.pathHistory.length > 1) {
      final updatedHistory = List<String>.from(window.pathHistory);
      updatedHistory.removeLast();

      _activeWindows[windowId] = window.copyWith(
        currentPath: updatedHistory.last,
        pathHistory: updatedHistory,
        refreshTrigger: DateTime.now().millisecondsSinceEpoch, // Force refresh
      );

      notifyListeners();
    }
  }

  /// Retry connection for a failed window
  Future<void> retryConnection(String windowId) async {
    final window = _activeWindows[windowId];
    if (window != null) {
      // Update status to connecting
      _activeWindows[windowId] = window.copyWith(
        status: SessionStatus.connecting,
        error: null,
      );
      notifyListeners();

      try {
        final ftpService = FTPService(
          host: window.session.host,
          user: window.session.username,
          pass: window.session.password,
          port: window.session.port,
        );

        await ftpService.connect();

        _activeWindows[windowId] = window.copyWith(
          ftpService: ftpService,
          status: SessionStatus.connected,
          error: null,
        );
      } catch (e) {
        _activeWindows[windowId] = window.copyWith(
          status: SessionStatus.error,
          error: e.toString(),
        );
      }

      notifyListeners();
    }
  }

  /// Refresh current directory for a window
  void refreshWindow(String windowId) {
    final window = _activeWindows[windowId];
    if (window != null) {
      _activeWindows[windowId] = window.copyWith(
        refreshTrigger: DateTime.now().millisecondsSinceEpoch,
      );
      notifyListeners();
    }
  }

  /// Get window by ID
  SessionWindow? getWindow(String windowId) {
    return _activeWindows[windowId];
  }

  /// Open session from saved sessions
  Future<SessionWindow> openSavedSession(String sessionId) async {
    final sessions = await SessionService.instance.getSessions();
    final session = sessions.firstWhere(
      (s) => s.id == sessionId,
      orElse: () => throw Exception('Session not found'),
    );

    return await openSessionWindow(session);
  }

  /// Check if session is already open
  bool isSessionOpen(String sessionId) {
    return _activeWindows.values.any((w) => w.session.id == sessionId);
  }

  /// Get window for session ID
  SessionWindow? getWindowBySessionId(String sessionId) {
    try {
      return _activeWindows.values.firstWhere((w) => w.session.id == sessionId);
    } catch (e) {
      return null;
    }
  }

  /// Close all windows
  Future<void> closeAllWindows() async {
    final windowIds = List<String>.from(_activeWindows.keys);
    for (final windowId in windowIds) {
      await closeWindow(windowId);
    }
  }

  /// Generate unique window ID
  String _generateWindowId() {
    return 'window_${DateTime.now().millisecondsSinceEpoch}';
  }

  @override
  void dispose() {
    closeAllWindows();
    super.dispose();
  }
}
