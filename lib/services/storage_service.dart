import 'package:shared_preferences/shared_preferences.dart';
import '../models/task.dart';
import 'dart:convert';

class StorageService {
  static const _tasksKey = 'tasks';
  static const _pomodorosKey = 'total_pomodoros';
  static const _completedTasksKey = 'completed_tasks';

  Future<List<Task>> getTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getStringList(_tasksKey) ?? [];
    return saved.map((t) => Task.fromJson(jsonDecode(t))).toList();
  }

  Future<void> saveTasks(List<Task> tasks) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      _tasksKey,
      tasks.map((t) => jsonEncode(t.toJson())).toList(),
    );
    // Update completed count
    final completed = tasks.where((t) => t.isDone).length;
    await prefs.setInt(_completedTasksKey, completed);
  }

  Future<int> getPomodoroCount() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_pomodorosKey) ?? 0;
  }

  Future<void> savePomodoroCount(int count) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_pomodorosKey, count);
  }

  Future<int> getCompletedTasksCount() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_completedTasksKey) ?? 0;
  }

  // Timer state persistence
  Future<void> saveTimerState({
    required String phase,
    required int remaining,
    required bool isRunning,
    required int endTime,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('timer_phase', phase);
    await prefs.setInt('timer_remaining', remaining);
    await prefs.setBool('timer_running', isRunning);
    await prefs.setInt('timer_end_time', endTime);
  }

  Future<Map<String, dynamic>> loadTimerState() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'phase': prefs.getString('timer_phase'),
      'remaining': prefs.getInt('timer_remaining') ?? 0,
      'isRunning': prefs.getBool('timer_running') ?? false,
      'endTime': prefs.getInt('timer_end_time') ?? 0,
    };
  }

  Future<int> getStreak() async {
    final prefs = await SharedPreferences.getInstance();
    final history = prefs.getStringList('session_history') ?? [];
    if (history.isEmpty) return 0;
    // Parse dates, get unique days, sort descending
    final dates = history.map((s) {
      final dt = DateTime.parse(s);
      return DateTime(dt.year, dt.month, dt.day);
    }).toSet().toList();
    dates.sort((a, b) => b.compareTo(a));
    int streak = 0;
    DateTime current = DateTime.now();
    current = DateTime(current.year, current.month, current.day);
    for (final date in dates) {
      if (date == current) {
        streak++;
        current = current.subtract(const Duration(days: 1));
      } else if (date.isBefore(current)) {
        break;
      }
    }
    return streak;
  }
}
