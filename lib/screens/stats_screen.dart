import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/app_theme.dart';

class StatsScreen extends HookWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final pomodoros = useState(0);
    final tasksDone = useState(0);
    final focusMinutes = useState(0);
    final sessionsLast7Days = useState(0);
    final dailyGoal = useState(4);
    final todaysPomodoros = useState(0);

    Future<void> loadStats() async {
      final prefs = await SharedPreferences.getInstance();
      pomodoros.value = prefs.getInt('total_pomodoros') ?? 0;
      tasksDone.value = prefs.getInt('completed_tasks') ?? 0;
      focusMinutes.value = pomodoros.value * 25;
      dailyGoal.value = prefs.getInt('daily_goal') ?? 4;

      // Calculate sessions in last 7 days
      final history = prefs.getStringList('session_history') ?? [];
      final now = DateTime.now();
      final sevenDaysAgo = now.subtract(const Duration(days: 7));
      sessionsLast7Days.value = history.where((dateStr) {
        final date = DateTime.parse(dateStr);
        return date.isAfter(sevenDaysAgo);
      }).length;

      // Calculate today's pomodoros
      final today = DateTime(now.year, now.month, now.day);
      todaysPomodoros.value = history.where((dateStr) {
        final date = DateTime.parse(dateStr);
        final d = DateTime(date.year, date.month, date.day);
        return d == today;
      }).length;
    }

    useEffect(() {
      loadStats();
      final timer = Timer.periodic(const Duration(seconds: 10), (_) => loadStats());
      return () => timer.cancel();
    }, []);

    void showDailyGoalDialog() {
      final controller = TextEditingController(text: dailyGoal.value.toString());
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: AppTheme.darkGrey,
          title: const Text('Set Daily Goal', style: TextStyle(color: AppTheme.neonCyan)),
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'Enter daily pomodoro goal',
              hintStyle: const TextStyle(color: AppTheme.grey),
              filled: true,
              fillColor: AppTheme.deepBlack,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(color: AppTheme.grey)),
            ),
            ElevatedButton(
              onPressed: () async {
                final goal = int.tryParse(controller.text) ?? 4;
                final prefs = await SharedPreferences.getInstance();
                await prefs.setInt('daily_goal', goal);
                dailyGoal.value = goal;
                Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('STATS')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            'YOUR FOCUS SUMMARY',
            style: TextStyle(
              color: AppTheme.neonCyan,
              fontSize: 20,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 20),
          // Daily Goal Card
          GestureDetector(
            onTap: showDailyGoalDialog,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.darkGrey,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.neonCyan.withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Daily Goal', style: TextStyle(color: AppTheme.grey, fontSize: 14)),
                      Icon(Icons.edit, color: AppTheme.grey, size: 16),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '$todaysPomodoros / ${dailyGoal.value}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  LinearProgressIndicator(
                    value: dailyGoal.value > 0 ? (todaysPomodoros.value / dailyGoal.value).clamp(0.0, 1.0) : 0,
                    backgroundColor: AppTheme.deepBlack,
                    valueColor: AlwaysStoppedAnimation<Color>(AppTheme.neonCyan),
                    minHeight: 8,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          _StatCard(
            icon: Icons.timer,
            color: AppTheme.neonCyan,
            label: 'Total Pomodoros',
            value: pomodoros.value.toString(),
          ),
          const SizedBox(height: 16),
          _StatCard(
            icon: Icons.task_alt,
            color: AppTheme.neonPurple,
            label: 'Tasks Completed',
            value: tasksDone.value.toString(),
          ),
          const SizedBox(height: 16),
          _StatCard(
            icon: Icons.local_fire_department,
            color: Colors.orange,
            label: 'Focus Minutes',
            value: focusMinutes.value.toString(),
          ),
          const SizedBox(height: 16),
          _StatCard(
            icon: Icons.history,
            color: Colors.greenAccent,
            label: 'Sessions (Last 7 Days)',
            value: sessionsLast7Days.value.toString(),
          ),
          const SizedBox(height: 30),
          const Text(
            'TIP: Complete your daily goal to maintain your streak!',
            style: TextStyle(color: AppTheme.grey, fontSize: 14),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final String value;

  const _StatCard({
    required this.icon,
    required this.color,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.darkGrey,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(width: 20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(color: AppTheme.grey, fontSize: 14)),
              const SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(
                  color: color,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
