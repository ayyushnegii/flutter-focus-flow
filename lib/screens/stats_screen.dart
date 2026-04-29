import 'dart:async';
import 'dart:convert';
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
    final chartData = useState<List<int>>([]);

    Future<void> loadStats() async {
      final prefs = await SharedPreferences.getInstance();
      pomodoros.value = prefs.getInt('total_pomodoros') ?? 0;
      tasksDone.value = prefs.getInt('completed_tasks') ?? 0;
      focusMinutes.value = pomodoros.value * 25;
      dailyGoal.value = prefs.getInt('daily_goal') ?? 4;

      final history = prefs.getStringList('session_history') ?? [];
      final now = DateTime.now();
      final sevenDaysAgo = now.subtract(const Duration(days: 7));
      sessionsLast7Days.value = history.where((dateStr) {
        final date = DateTime.parse(dateStr);
        return date.isAfter(sevenDaysAgo);
      }).length;

      final today = DateTime(now.year, now.month, now.day);
      todaysPomodoros.value = history.where((dateStr) {
        final date = DateTime.parse(dateStr);
        final d = DateTime(date.year, date.month, date.day);
        return d == today;
      }).length;

      // Prepare chart data (last 7 days)
      List<int> data = [];
      for (int i = 6; i >= 0; i--) {
        final day = now.subtract(Duration(days: i));
        final dayStart = DateTime(day.year, day.month, day.day);
        final count = history.where((dateStr) {
          final date = DateTime.parse(dateStr);
          final d = DateTime(date.year, date.month, date.day);
          return d == dayStart;
        }).length;
        data.add(count);
      }
      chartData.value = data;
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

    void exportToCSV() async {
      final prefs = await SharedPreferences.getInstance();
      final history = prefs.getStringList('session_history') ?? [];
      if (history.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No session data to export')),
        );
        return;
      }
      String csv = 'Date,Time,Duration (min)\n';
      for (final session in history) {
        final dt = DateTime.parse(session);
        csv += '${dt.year}-${dt.month.toString().padLeft(2,'0')}-${dt.day.toString().padLeft(2,'0')},';
        csv += '${dt.hour.toString().padLeft(2,'0')}:${dt.minute.toString().padLeft(2,'0')},25\n';
      }
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: AppTheme.darkGrey,
          title: const Text('Export Data', style: TextStyle(color: AppTheme.neonCyan)),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('CSV Data:', style: TextStyle(color: AppTheme.grey)),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  color: AppTheme.deepBlack,
                  child: Text(
                    csv,
                    style: const TextStyle(color: Colors.white, fontSize: 12, fontFamily: 'monospace'),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close', style: TextStyle(color: AppTheme.grey)),
            ),
            ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('CSV copied to clipboard (simulated)')),
                );
                Navigator.pop(context);
              },
              child: const Text('Copy CSV'),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('STATS'),
        actions: [
          IconButton(
            icon: const Icon(Icons.download, color: AppTheme.neonCyan),
            onPressed: exportToCSV,
            tooltip: 'Export to CSV',
          ),
        ],
      ),
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
          const SizedBox(height: 20),
          // Simple Chart (last 7 days)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.darkGrey,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Focus Sessions (Last 7 Days)', style: TextStyle(color: AppTheme.neonCyan, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                SizedBox(
                  height: 150,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: List.generate(7, (index) {
                      final value = chartData.value.length > index ? chartData.value[index] : 0;
                      final maxVal = 10; // Assume max 10 per day for visualization
                      final height = value / maxVal * 100;
                      final dayName = ['Mon','Tue','Wed','Thu','Fri','Sat','Sun'][(DateTime.now().weekday - 7 + index) % 7];
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text('$value', style: const TextStyle(color: Colors.white, fontSize: 12)),
                          const SizedBox(height: 4),
                          Container(
                            width: 30,
                            height: height.clamp(4, 100),
                            decoration: BoxDecoration(
                              color: AppTheme.neonCyan,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(dayName, style: const TextStyle(color: AppTheme.grey, fontSize: 10)),
                        ],
                      );
                    }),
                  ),
                ),
              ],
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
