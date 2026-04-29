import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/app_theme.dart';
import '../models/achievement.dart';
import '../services/achievement_service.dart';

class AchievementsScreen extends HookWidget {
  const AchievementsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final achievements = useState<List<Achievement>>([]);
    final unlockedCount = useState(0);

    Future<void> loadAchievements() async {
      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getStringList('achievements') ?? [];
      final loaded = allAchievements.map((template) {
        final savedJson = saved.firstWhere(
          (s) => s.contains('"id":"${template.id}"'),
          orElse: () => '{"id":"${template.id}","isUnlocked":false}',
        );
        final json = Map<String, dynamic>.from(
          const JsonDecoder().convert(savedJson) as Map,
        );
        return Achievement.fromJson(json, template);
      }).toList();
      achievements.value = loaded;
      unlockedCount.value = loaded.where((a) => a.isUnlocked).length;
    }

    useEffect(() {
      loadAchievements();
      final timer = Stream.periodic(const Duration(seconds: 10)).listen((_) => loadAchievements());
      return () => timer.cancel();
    }, []);

    return Scaffold(
      appBar: AppBar(title: const Text('ACHIEVEMENTS')),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.darkGrey,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.neonCyan.withOpacity(0.5)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('🏆', style: TextStyle(fontSize: 32)),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Progress',
                      style: TextStyle(color: AppTheme.grey, fontSize: 14),
                    ),
                    Text(
                      '${unlockedCount.value}/${allAchievements.length} Unlocked',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.85,
              ),
              itemCount: achievements.value.length,
              itemBuilder: (context, index) {
                final a = achievements.value[index];
                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: a.isUnlocked ? AppTheme.darkGrey : AppTheme.darkGrey.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: a.isUnlocked ? AppTheme.neonCyan.withOpacity(0.5) : Colors.transparent,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        a.emoji,
                        style: TextStyle(
                          fontSize: 40,
                          color: a.isUnlocked ? null : Colors.grey.withOpacity(0.3),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        a.name,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: a.isUnlocked ? Colors.white : AppTheme.grey,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        a.description,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: a.isUnlocked ? AppTheme.grey : AppTheme.grey.withOpacity(0.5),
                          fontSize: 12,
                        ),
                      ),
                      if (a.isUnlocked) ...[
                        const SizedBox(height: 8),
                        Icon(Icons.check_circle, color: AppTheme.neonCyan, size: 20),
                      ],
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
