import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/achievement.dart';

class AchievementService {
  static const _key = 'achievements';

  Future<List<Achievement>> getUnlockedAchievements() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getStringList(_key) ?? [];
    return allAchievements.map((template) {
      final savedJson = saved.firstWhere(
        (s) => s.contains('"id":"${template.id}"'),
        orElse: () => '{"id":"${template.id}","isUnlocked":false}',
      );
      final json = Map<String, dynamic>.from(
        const JsonDecoder().convert(savedJson) as Map,
      );
      return Achievement.fromJson(json, template);
    }).where((a) => a.isUnlocked).toList();
  }

  Future<void> checkAndUnlock({
    required int pomodoros,
    required int streak,
    required int completedTasks,
    required int unlockedDestinations,
    required bool isEarlyBird,
    required bool isNightOwl,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getStringList(_key) ?? [];
    final achievements = allAchievements.map((template) {
      final savedJson = saved.firstWhere(
        (s) => s.contains('"id":"${template.id}"'),
        orElse: () => '{"id":"${template.id}","isUnlocked":false}',
      );
      return Achievement.fromJson(
        Map<String, dynamic>.from(const JsonDecoder().convert(savedJson) as Map),
        template,
      );
    }).toList();

    bool changed = false;
    for (var a in achievements) {
      if (a.isUnlocked) continue;
      bool shouldUnlock = false;
      switch (a.type) {
        case AchievementType.pomodoros:
          shouldUnlock = pomodoros >= a.requiredCount;
          break;
        case AchievementType.streak:
          shouldUnlock = streak >= a.requiredCount;
          break;
        case AchievementType.tasks:
          shouldUnlock = completedTasks >= a.requiredCount;
          break;
        case AchievementType.destinations:
          shouldUnlock = unlockedDestinations >= a.requiredCount;
          break;
        case AchievementType.timeOfDay:
          if (a.id == 'early_bird') shouldUnlock = isEarlyBird;
          if (a.id == 'night_owl') shouldUnlock = isNightOwl;
          break;
      }
      if (shouldUnlock) {
        a = Achievement(
          id: a.id,
          name: a.name,
          description: a.description,
          emoji: a.emoji,
          type: a.type,
          requiredCount: a.requiredCount,
          isUnlocked: true,
        );
        changed = true;
      }
    }

    if (changed) {
      await prefs.setStringList(
        _key,
        achievements.map((a) => JsonEncoder().convert(a.toJson())).toList(),
      );
    }
  }
}
