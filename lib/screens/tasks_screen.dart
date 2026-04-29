import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../theme/app_theme.dart';

class Task {
  final String id;
  final String title;
  final bool isDone;

  Task({required this.id, required this.title, this.isDone = false});

  Map<String, dynamic> toJson() => {'id': id, 'title': title, 'isDone': isDone};

  factory Task.fromJson(Map<String, dynamic> json) => Task(
        id: json['id'],
        title: json['title'],
        isDone: json['isDone'],
      );
}

class TasksScreen extends HookWidget {
  const TasksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final tasks = useState<List<Task>>([]);
    final controller = useTextEditingController();
    final prefs = useState<SharedPreferences?>(null);

    useEffect(() {
      SharedPreferences.getInstance().then((p) {
        prefs.value = p;
        final saved = p.getStringList('tasks') ?? [];
        tasks.value = saved.map((t) => Task.fromJson(jsonDecode(t))).toList();
      });
      return null;
    }, []);

    void saveTasks(List<Task> updated) {
      tasks.value = updated;
      prefs.value?.setStringList(
        'tasks',
        updated.map((t) => jsonEncode(t.toJson())).toList(),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('TASKS')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Add a new task...',
                      hintStyle: const TextStyle(color: AppTheme.grey),
                      filled: true,
                      fillColor: AppTheme.darkGrey,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    ),
                    onSubmitted: (value) {
                      if (value.isNotEmpty) {
                        saveTasks([
                          ...tasks.value,
                          Task(id: DateTime.now().toString(), title: value),
                        ]);
                        controller.clear();
                      }
                    },
                  ),
                ),
                const SizedBox(width: 12),
                IconButton(
                  icon: const Icon(Icons.add_circle, color: AppTheme.neonCyan, size: 32),
                  onPressed: () {
                    if (controller.text.isNotEmpty) {
                      saveTasks([
                        ...tasks.value,
                        Task(id: DateTime.now().toString(), title: controller.text),
                      ]);
                      controller.clear();
                    }
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: tasks.value.isEmpty
                ? const Center(
                    child: Text('No tasks yet. Add one above!', style: TextStyle(color: AppTheme.grey)),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: tasks.value.length,
                    itemBuilder: (context, index) {
                      final task = tasks.value[index];
                      return Dismissible(
                        key: Key(task.id),
                        background: Container(
                          color: Colors.red,
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20),
                          child: const Icon(Icons.delete, color: Colors.white),
                        ),
                        onDismissed: (_) => saveTasks(
                          tasks.value.where((t) => t.id != task.id).toList(),
                        ),
                        child: Card(
                          color: AppTheme.darkGrey,
                          margin: const EdgeInsets.only(bottom: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: CheckboxListTile(
                            value: task.isDone,
                            onChanged: (value) => saveTasks(
                              tasks.value.map((t) => t.id == task.id ? Task(id: t.id, title: t.title, isDone: value!) : t).toList(),
                            ),
                            title: Text(
                              task.title,
                              style: TextStyle(
                                color: task.isDone ? AppTheme.grey : Colors.white,
                                decoration: task.isDone ? TextDecoration.lineThrough : null,
                              ),
                            ),
                            activeColor: AppTheme.neonCyan,
                            checkColor: AppTheme.deepBlack,
                          ),
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