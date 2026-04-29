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

  @override
  Widget build(BuildContext context) {
    final totalPomodoros = useState(0);

    useEffect(() {
      SharedPreferences.getInstance().then((prefs) {
        totalPomodoros.value = prefs.getInt('total_pomodoros') ?? 0;
      });
      return null;
    }, []);

    return Scaffold(
      appBar: AppBar(title: const Text('TRAVEL MODE')),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: destinations.length,
        itemBuilder: (context, index) {
          final dest = destinations[index];
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
