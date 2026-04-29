import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/app_theme.dart';

class StatsScreen extends HookWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final prefs = useState<SharedPreferences?>(null);
    final pomodoros = useState(0);
    final tasksDone = useState(0);

    useEffect(() {
      SharedPreferences.getInstance().then((p) {
        prefs.value = p;
        pomodoros.value = p.getInt('total_pomodoros') ?? 0;
        tasksDone.value = p.getInt('completed_tasks') ?? 0;
      });
      return null;
    }, []);

    return Scaffold(
      appBar: AppBar(title: const Text('STATS')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
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
            const SizedBox(height: 30),
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
              value: (pomodoros.value * 25).toString(),
            ),
            const SizedBox(height: 30),
            const Text(
              'TIP: Complete at least 1 pomodoro daily to build a streak!',
              style: TextStyle(color: AppTheme.grey, fontSize: 14),
            ),
          ],
        ),
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