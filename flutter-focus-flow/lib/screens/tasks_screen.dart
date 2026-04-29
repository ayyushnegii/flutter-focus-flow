import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../theme/app_theme.dart';
import '../models/task.dart';

class TasksScreen extends HookWidget {
  const TasksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final tasks = useState<List<Task>>([]);
    final controller = useTextEditingController();
    final priorityController = useState<TaskPriority>(TaskPriority.medium);
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
      // Update completed tasks count
      final completed = updated.where((t) => t.isDone).length;
      prefs.value?.setInt('completed_tasks', completed);
    }

    void showEditDialog(Task task) {
      final editController = TextEditingController(text: task.title);
      TaskPriority editPriority = task.priority;
      showDialog(
        context: context,
        builder: (context) => StatefulBuilder(
          builder: (context, setState) => AlertDialog(
            backgroundColor: AppTheme.darkGrey,
            title: const Text('Edit Task', style: TextStyle(color: AppTheme.neonCyan)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: editController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Task title',
                    hintStyle: const TextStyle(color: AppTheme.grey),
                    filled: true,
                    fillColor: AppTheme.deepBlack,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButton<TaskPriority>(
                  value: editPriority,
                  dropdownColor: AppTheme.darkGrey,
                  style: const TextStyle(color: Colors.white),
                  underline: Container(height: 2, color: AppTheme.neonCyan),
                  items: TaskPriority.values.map((p) => DropdownMenuItem(
                    value: p,
                    child: Row(
                      children: [
                        Container(width: 12, height: 12, color: p.color),
                        const SizedBox(width: 8),
                        Text(p.label),
                      ],
                    ),
                  )).toList(),
                  onChanged: (value) => setState(() => editPriority = value!),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel', style: TextStyle(color: AppTheme.grey)),
              ),
              ElevatedButton(
                onPressed: () {
                  if (editController.text.isNotEmpty) {
                    saveTasks(tasks.value.map((t) => t.id == task.id
                        ? Task(
                            id: t.id,
                            title: editController.text,
                            isDone: t.isDone,
                            priority: editPriority,
                            dueDate: t.dueDate,
                          )
                        : t).toList());
                    Navigator.pop(context);
                  }
                },
                child: const Text('Save'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('TASKS')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
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
                              Task(
                                id: DateTime.now().toString(),
                                title: value,
                                priority: priorityController.value,
                              ),
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
                            Task(
                              id: DateTime.now().toString(),
                              title: controller.text,
                              priority: priorityController.value,
                            ),
                          ]);
                          controller.clear();
                        }
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Text('Priority:', style: TextStyle(color: AppTheme.grey)),
                    const SizedBox(width: 12),
                    ...TaskPriority.values.map((p) => Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(p.label, style: TextStyle(
                          color: priorityController.value == p ? AppTheme.deepBlack : Colors.white,
                          fontSize: 12,
                        )),
                        selected: priorityController.value == p,
                        selectedColor: p.color,
                        backgroundColor: AppTheme.darkGrey,
                        onSelected: (_) => priorityController.value = p,
                      ),
                    )),
                  ],
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
                        child: GestureDetector(
                          onLongPress: () => showEditDialog(task),
                          child: Card(
                            color: AppTheme.darkGrey,
                            margin: const EdgeInsets.only(bottom: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: BorderSide(
                                color: task.priority.color.withOpacity(0.5),
                                width: 1,
                              ),
                            ),
                            child: CheckboxListTile(
                              value: task.isDone,
                              onChanged: (value) => saveTasks(
                                tasks.value.map((t) => t.id == task.id
                                    ? Task(
                                        id: t.id,
                                        title: t.title,
                                        isDone: value!,
                                        priority: t.priority,
                                        dueDate: t.dueDate,
                                      )
                                    : t).toList(),
                              ),
                              title: Text(
                                task.title,
                                style: TextStyle(
                                  color: task.isDone ? AppTheme.grey : Colors.white,
                                  decoration: task.isDone ? TextDecoration.lineThrough : null,
                                ),
                              ),
                              secondary: Container(
                                width: 4,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: task.priority.color,
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                              activeColor: AppTheme.neonCyan,
                              checkColor: AppTheme.deepBlack,
                            ),
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
