import 'package:flutter/material.dart';

enum AchievementType { pomodoros, streak, tasks, destinations, timeOfDay }

class Achievement {
  final String id;
  final String name;
  final String description;
  final String emoji;
  final AchievementType type;
  final int requiredCount;
  final bool isUnlocked;

  Achievement({
    required this.id,
    required this.name,
    required this.description,
    required this.emoji,
    required this.type,
    required this.requiredCount,
    this.isUnlocked = false,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'isUnlocked': isUnlocked,
      };

  factory Achievement.fromJson(Map<String, dynamic> json, Achievement template) => Achievement(
        id: template.id,
        name: template.name,
        description: template.description,
        emoji: template.emoji,
        type: template.type,
        requiredCount: template.requiredCount,
        isUnlocked: json['isUnlocked'] ?? false,
      );
}

final allAchievements = [
  Achievement(
    id: 'first_pomodoro',
    name: 'First Step',
    description: 'Complete your first pomodoro',
    emoji: '🎉',
    type: AchievementType.pomodoros,
    requiredCount: 1,
  ),
  Achievement(
    id: 'pomodoro_10',
    name: 'Getting Started',
    description: 'Complete 10 pomodoros',
    emoji: '🔥',
    type: AchievementType.pomodoros,
    requiredCount: 10,
  ),
  Achievement(
    id: 'pomodoro_50',
    name: 'Marathon Runner',
    description: 'Complete 50 pomodoros',
    emoji: '🏃',
    type: AchievementType.pomodoros,
    requiredCount: 50,
  ),
  Achievement(
    id: 'streak_7',
    name: 'Week Warrior',
    description: 'Maintain a 7-day streak',
    emoji: '⚔️',
    type: AchievementType.streak,
    requiredCount: 7,
  ),
  Achievement(
    id: 'streak_30',
    name: 'Monthly Master',
    description: 'Maintain a 30-day streak',
    emoji: '👑',
    type: AchievementType.streak,
    requiredCount: 30,
  ),
  Achievement(
    id: 'dest_3',
    name: 'Globe Trotter',
    description: 'Unlock 3 destinations',
    emoji: '🌍',
    type: AchievementType.destinations,
    requiredCount: 3,
  ),
  Achievement(
    id: 'dest_5',
    name: 'World Explorer',
    description: 'Unlock 5 destinations',
    emoji: '🗺️',
    type: AchievementType.destinations,
    requiredCount: 5,
  ),
  Achievement(
    id: 'tasks_10',
    name: 'Task Master',
    description: 'Complete 10 tasks',
    emoji: '✅',
    type: AchievementType.tasks,
    requiredCount: 10,
  ),
  Achievement(
    id: 'early_bird',
    name: 'Early Bird',
    description: 'Complete a pomodoro before 8am',
    emoji: '🐦',
    type: AchievementType.timeOfDay,
    requiredCount: 1,
  ),
  Achievement(
    id: 'night_owl',
    name: 'Night Owl',
    description: 'Complete a pomodoro after 10pm',
    emoji: '🦉',
    type: AchievementType.timeOfDay,
    requiredCount: 1,
  ),
];
