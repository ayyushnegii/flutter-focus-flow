import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum TimerPhase { work, shortBreak, longBreak }

class TimerController extends ChangeNotifier {
  static const workDuration = 25 * 60;
  static const shortBreakDuration = 5 * 60;
  static const longBreakDuration = 15 * 60;

  TimerPhase _phase = TimerPhase.work;
  int _secondsRemaining = workDuration;
  bool _isRunning = false;
  int _pomodoroCount = 0;
  Timer? _timer;

  TimerPhase get phase => _phase;
  int get secondsRemaining => _secondsRemaining;
  bool get isRunning => _isRunning;
  int get pomodoroCount => _pomodoroCount;

  int get currentDuration {
    return switch (_phase) {
      TimerPhase.work => workDuration,
      TimerPhase.shortBreak => shortBreakDuration,
      TimerPhase.longBreak => longBreakDuration,
    };
  }

  double get percent {
    final total = currentDuration;
    if (total == 0) return 0;
    return 1 - (_secondsRemaining / total);
  }

  void start() {
    if (_isRunning) return;
    _isRunning = true;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), _tick);
    _saveState();
    notifyListeners();
  }

  void pause() {
    _isRunning = false;
    _timer?.cancel();
    _timer = null;
    _saveState();
    notifyListeners();
  }

  void reset() {
    _isRunning = false;
    _timer?.cancel();
    _timer = null;
    _secondsRemaining = currentDuration;
    _saveState();
    notifyListeners();
  }

  void _tick(Timer timer) {
    if (_secondsRemaining > 0) {
      _secondsRemaining--;
      _saveState();
      notifyListeners();
    } else {
      _handlePhaseComplete();
    }
  }

  void _handlePhaseComplete() {
    // Haptic feedback on phase complete
    HapticFeedback.mediumImpact();
    if (_phase == TimerPhase.work) {
      _pomodoroCount++;
      _savePomodoroCount();
      _recordSession();
      if (_pomodoroCount % 4 == 0) {
        _phase = TimerPhase.longBreak;
      } else {
        _phase = TimerPhase.shortBreak;
      }
    } else {
      _phase = TimerPhase.work;
    }
    _secondsRemaining = currentDuration;
    _isRunning = false;
    _timer?.cancel();
    _timer = null;
    _saveState();
    notifyListeners();
  }

  Future<void> _recordSession() async {
    final prefs = await SharedPreferences.getInstance();
    final history = prefs.getStringList('session_history') ?? [];
    history.add(DateTime.now().toIso8601String());
    // Keep only last 100 sessions
    if (history.length > 100) {
      history.removeRange(0, history.length - 100);
    }
    await prefs.setStringList('session_history', history);
  }

  Future<void> _saveState() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('timer_phase', _phase.name);
    prefs.setInt('timer_remaining', _secondsRemaining);
    prefs.setBool('timer_running', _isRunning);
    prefs.setInt('timer_end_time', _isRunning ? DateTime.now().add(Duration(seconds: _secondsRemaining)).millisecondsSinceEpoch : 0);
  }

  Future<void> _savePomodoroCount() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setInt('total_pomodoros', _pomodoroCount);
  }

  Future<void> loadState() async {
    final prefs = await SharedPreferences.getInstance();
    final savedPhase = prefs.getString('timer_phase');
    if (savedPhase != null) {
      _phase = TimerPhase.values.firstWhere((e) => e.name == savedPhase, orElse: () => TimerPhase.work);
    }
    _secondsRemaining = prefs.getInt('timer_remaining') ?? currentDuration;
    _isRunning = false; // Always start paused
    _pomodoroCount = prefs.getInt('total_pomodoros') ?? 0;

    // Check if timer was running and restore if needed
    final endTime = prefs.getInt('timer_end_time') ?? 0;
    if (endTime > 0) {
      final remaining = (endTime - DateTime.now().millisecondsSinceEpoch) ~/ 1000;
      if (remaining > 0) {
        _secondsRemaining = remaining;
        // Don't auto-start, let user resume
      } else {
        _secondsRemaining = 0;
        _handlePhaseComplete();
      }
    }
    notifyListeners();
  }

  String get phaseLabel {
    return switch (_phase) {
      TimerPhase.work => 'WORK SESSION',
      TimerPhase.shortBreak => 'SHORT BREAK',
      TimerPhase.longBreak => 'LONG BREAK',
    };
  }

  Color get phaseColor {
    return switch (_phase) {
      TimerPhase.work => const Color(0xFF00F5FF),
      TimerPhase.shortBreak => const Color(0xFF9D00FF),
      TimerPhase.longBreak => const Color(0xFF0066FF),
    };
  }

  String formatTime(int seconds) {
    final mins = (seconds ~/ 60).toString().padLeft(2, '0');
    final secs = (seconds % 60).toString().padLeft(2, '0');
    return '$mins:$secs';
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
