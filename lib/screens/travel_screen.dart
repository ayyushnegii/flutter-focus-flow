import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/app_theme.dart';

class Destination {
  final String name;
  final String emoji;
  final int requiredPomodoros;
  final String description;

  Destination({
    required this.name,
    required this.emoji,
    required this.requiredPomodoros,
    required this.description,
  });
}

final destinations = [
  Destination(name: 'Paris', emoji: '🇫🇷', requiredPomodoros: 5, description: 'City of Lights'),
  Destination(name: 'Tokyo', emoji: '🇯🇵', requiredPomodoros: 10, description: 'Land of the Rising Sun'),
  Destination(name: 'New York', emoji: '🇺🇸', requiredPomodoros: 15, description: 'The Big Apple'),
  Destination(name: 'Sydney', emoji: '🇦🇺', requiredPomodoros: 20, description: 'Harbour City'),
  Destination(name: 'Cairo', emoji: '🇪🇬', requiredPomodoros: 25, description: 'Gift of the Nile'),
  Destination(name: 'Rio', emoji: '🇧🇷', requiredPomodoros: 30, description: 'Cidade Maravilhosa'),
  Destination(name: 'Reykjavik', emoji: '🇮🇸', requiredPomodoros: 40, description: 'Land of Fire and Ice'),
  Destination(name: 'Singapore', emoji: '🇸🇬', requiredPomodoros: 50, description: 'The Lion City'),
];

class TravelScreen extends HookWidget {
  const TravelScreen({super.key});

  Future<int> _getStreak() async {
    final prefs = await SharedPreferences.getInstance();
    final history = prefs.getStringList('session_history') ?? [];
    if (history.isEmpty) return 0;
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

  @override
  Widget build(BuildContext context) {
    final totalPomodoros = useState(0);
    final streak = useState(0);

    useEffect(() {
      SharedPreferences.getInstance().then((prefs) {
        totalPomodoros.value = prefs.getInt('total_pomodoros') ?? 0;
      });
      _getStreak().then((value) => streak.value = value);
      final timer = Stream.periodic(const Duration(seconds: 10)).listen((_) {
        SharedPreferences.getInstance().then((prefs) {
          totalPomodoros.value = prefs.getInt('total_pomodoros') ?? 0;
        });
        _getStreak().then((value) => streak.value = value);
      });
      return () => timer.cancel();
    }, []);

    return Scaffold(
      appBar: AppBar(title: const Text('TRAVEL MODE')),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: destinations.length + 1, // +1 for streak header
        itemBuilder: (context, index) {
          if (index == 0) {
            return Container(
              margin: const EdgeInsets.only(bottom: 20),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.darkGrey,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.neonCyan.withOpacity(0.5)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '🔥 CURRENT STREAK',
                    style: TextStyle(
                      color: AppTheme.neonCyan,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${streak.value} day${streak.value == 1 ? '' : 's'}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Total Pomodoros: ${totalPomodoros.value}',
                    style: const TextStyle(color: AppTheme.grey),
                  ),
                ],
              ),
            );
          }
          final dest = destinations[index - 1];
          final unlocked = totalPomodoros.value >= dest.requiredPomodoros;
          return Card(
            color: AppTheme.darkGrey,
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: Text(dest.emoji, style: const TextStyle(fontSize: 28)),
              title: Text(
                dest.name,
                style: TextStyle(
                  color: unlocked ? Colors.white : AppTheme.grey,
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Text(dest.description, style: const TextStyle(color: AppTheme.grey)),
              trailing: unlocked
                  ? const Icon(Icons.check_circle, color: AppTheme.neonCyan)
                  : Text('${dest.requiredPomodoros}', style: const TextStyle(color: AppTheme.grey)),
            ),
          );
        },
      ),
    );
  }
}
