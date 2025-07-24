import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/ftp_session.dart';

class SessionService {
  static const String _sessionsKey = 'ftp_sessions';
  static SessionService? _instance;
  SharedPreferences? _prefs;

  SessionService._();

  static SessionService get instance {
    _instance ??= SessionService._();
    return _instance!;
  }

  Future<void> _initPrefs() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  // Save all sessions
  Future<void> _saveSessions(List<FTPSession> sessions) async {
    await _initPrefs();
    final jsonList = sessions.map((session) => session.toJson()).toList();
    await _prefs!.setString(_sessionsKey, jsonEncode(jsonList));
  }

  // Load all sessions
  Future<List<FTPSession>> getSessions() async {
    await _initPrefs();
    final jsonString = _prefs!.getString(_sessionsKey);
    if (jsonString == null) return [];

    try {
      final jsonList = jsonDecode(jsonString) as List;
      return jsonList.map((json) => FTPSession.fromJson(json)).toList();
    } catch (e) {
      debugPrint('Error loading sessions: $e');
      return [];
    }
  }

  // Add new session
  Future<void> addSession(FTPSession session) async {
    final sessions = await getSessions();
    sessions.add(session);
    await _saveSessions(sessions);
  }

  // Update existing session
  Future<void> updateSession(FTPSession updatedSession) async {
    final sessions = await getSessions();
    final index = sessions.indexWhere((s) => s.id == updatedSession.id);
    if (index != -1) {
      sessions[index] = updatedSession;
      await _saveSessions(sessions);
    }
  }

  // Delete session
  Future<void> deleteSession(String sessionId) async {
    final sessions = await getSessions();
    sessions.removeWhere((s) => s.id == sessionId);
    await _saveSessions(sessions);
  }

  // Generate unique ID
  String generateId() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }
}
