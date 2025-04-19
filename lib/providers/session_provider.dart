import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/timer_session.dart';
import '../services/notification_service.dart';
import '../services/tts_service.dart';

class SessionProvider extends ChangeNotifier {
  final List<TimerSession> _sessions = [];
  final Map<String, Timer> _timers = {};
  final Map<String, Timer> _endTimers = {};

  final NotificationService _notifications = NotificationService();
  final TTSService _tts = TTSService();

  List<TimerSession> get sessions => List.unmodifiable(_sessions);

  SessionProvider() {
    _loadSessions();
  }

  Future<void> _loadSessions() async {
    final prefs = await SharedPreferences.getInstance();
    final String? sessionsJson = prefs.getString('timerSessions');

    if (sessionsJson != null) {
      final List<dynamic> decoded = jsonDecode(sessionsJson);

      _sessions.clear();
      _sessions.addAll(
        decoded.map((item) => TimerSession.fromJson(item)).toList(),
      );

      // Resume active sessions
      for (final session in _sessions.where((s) => s.isActive)) {
        _startSession(session);
      }

      notifyListeners();
    }
  }

  Future<void> _saveSessions() async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(_sessions.map((s) => s.toJson()).toList());
    await prefs.setString('timerSessions', encoded);
  }

  Future<TimerSession> addSession(
    int intervalMinutes,
    int durationMinutes, {
    String? name,
  }) async {
    final session = TimerSession(
      intervalMinutes: intervalMinutes,
      durationMinutes: durationMinutes,
      name: name,
    );

    _sessions.add(session);
    await _saveSessions();
    notifyListeners();

    return session;
  }

  Future<void> updateSession(
    String id, {
    String? name,
    int? intervalMinutes,
    int? durationMinutes,
  }) async {
    final index = _sessions.indexWhere((s) => s.id == id);
    if (index == -1) return;

    final session = _sessions[index];
    final wasActive = session.isActive;

    if (wasActive) {
      await stopSession(id);
    }

    final updatedSession = TimerSession(
      id: session.id,
      name: name ?? session.name,
      intervalMinutes: intervalMinutes ?? session.intervalMinutes,
      durationMinutes: durationMinutes ?? session.durationMinutes,
      createdAt: session.createdAt,
    );

    _sessions[index] = updatedSession;

    if (wasActive) {
      await startSession(id);
    }

    await _saveSessions();
    notifyListeners();
  }

  Future<void> removeSession(String id) async {
    final index = _sessions.indexWhere((s) => s.id == id);

    if (index == -1) return;

    final session = _sessions[index];

    if (session.isActive) {
      await stopSession(id);
    }

    _sessions.removeAt(index);
    await _saveSessions();
    notifyListeners();
  }

  Future<void> startSession(String id) async {
    final index = _sessions.indexWhere((s) => s.id == id);
    if (index == -1) return;

    final session = _sessions[index];

    if (session.isActive) return;

    session.start();
    _startSession(session);

    await _saveSessions();
    notifyListeners();
  }

  void _startSession(TimerSession session) {
    _tts.speakCurrentTime(sessionName: session.name);

    _timers[session.id] = Timer.periodic(
      Duration(minutes: session.intervalMinutes),
      (_) => _announceTime(session),
    );

    _endTimers[session.id] = Timer(
      Duration(minutes: session.durationMinutes),
      () => _endSession(session),
    );
  }

  Future<void> stopSession(String id) async {
    final index = _sessions.indexWhere((s) => s.id == id);
    if (index == -1) return;

    final session = _sessions[index];

    if (!session.isActive) return;

    session.stop();

    _timers[session.id]?.cancel();
    _timers.remove(session.id);

    _endTimers[session.id]?.cancel();
    _endTimers.remove(session.id);

    await _saveSessions();
    notifyListeners();
  }

  void _announceTime(TimerSession session) {
    if (!session.isActive) return;

    _tts.speakCurrentTime(sessionName: session.name);
    _notifications.showTimeNotification(
      'Time Check',
      'The time is ${DateFormat('h:mm a').format(DateTime.now())}.',
    );
  }

  void _endSession(TimerSession session) {
    if (!session.isActive) return;

    final index = _sessions.indexWhere((s) => s.id == session.id);
    if (index == -1) return;

    _sessions[index].stop();

    _timers[session.id]?.cancel();
    _timers.remove(session.id);

    _endTimers[session.id]?.cancel();
    _endTimers.remove(session.id);

    _tts.speakSessionEnd(session.name);
    _notifications.showTimeNotification(
      'Session Ended',
      'Your ${session.name} session has ended.',
    );

    _saveSessions();
    notifyListeners();
  }

  @override
  void dispose() {
    for (final timer in _timers.values) {
      timer.cancel();
    }
    for (final timer in _endTimers.values) {
      timer.cancel();
    }

    _tts.stop();
    super.dispose();
  }
}
