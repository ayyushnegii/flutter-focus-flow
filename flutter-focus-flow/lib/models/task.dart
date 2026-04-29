enum TaskPriority { low, medium, high }

extension TaskPriorityExtension on TaskPriority {
  String get label => name[0].toUpperCase() + name.substring(1);
  Color get color => switch (this) {
        TaskPriority.low => const Color(0xFF00F5FF), // neon cyan
        TaskPriority.medium => const Color(0xFFFFD600), // neon yellow
        TaskPriority.high => const Color(0xFFFF006E), // neon pink
      };
}

class Task {
  final String id;
  final String title;
  final bool isDone;
  final TaskPriority priority;
  final DateTime? dueDate;

  Task({
    required this.id,
    required this.title,
    this.isDone = false,
    this.priority = TaskPriority.medium,
    this.dueDate,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'isDone': isDone,
        'priority': priority.index,
        'dueDate': dueDate?.toIso8601String(),
      };

  factory Task.fromJson(Map<String, dynamic> json) => Task(
        id: json['id'],
        title: json['title'],
        isDone: json['isDone'],
        priority: TaskPriority.values[json['priority'] ?? 1],
        dueDate: json['dueDate'] != null ? DateTime.parse(json['dueDate']) : null,
      );
}
