import 'dart:convert';
import 'dart:io';

import '../exceptions/task_exceptions.dart';
import '../models/priority.dart';
import '../models/standard_task.dart';
import '../models/task.dart';
import '../models/urgent_task.dart';
import 'repository.dart';

class TaskRepository implements Repository<Task> {
  final String filePath;
  final List<Task> _tasks = [];

  TaskRepository({this.filePath = 'tasks.json'}) {
    _load();
  }

  @override
  List<Task> getAll() => List.unmodifiable(_tasks);

  @override
  Task? getById(String id) {
    for (final task in _tasks) {
      if (task.id == id) return task;
    }
    return null;
  }

  @override
  void add(Task item) {
    _tasks.add(item);
    _save();
  }

  @override
  void delete(String id) {
    final task = getById(id);
    if (task == null) throw TaskNotFoundException(id);
    _tasks.remove(task);
    _save();
  }

  Task complete(String id) {
    final task = getById(id);
    if (task == null) throw TaskNotFoundException(id);
    task.markAsCompleted();
    _save();
    return task;
  }

  List<Task> sortedByPriority({bool descending = true}) {
    final tasks = List<Task>.from(_tasks)..sort();
    return descending ? tasks : tasks.reversed.toList();
  }

  List<Task> sortedByDeadline() {
    final tasks = List<Task>.from(_tasks);
    tasks.sort((a, b) {
      final deadlineA = a.deadline;
      final deadlineB = b.deadline;
      if (deadlineA == null && deadlineB == null) return 0;
      if (deadlineA == null) return 1;
      if (deadlineB == null) return -1;
      return deadlineA.compareTo(deadlineB);
    });
    return tasks;
  }

  void _load() {
    final file = File(filePath);
    if (!file.existsSync()) return;

    final content = file.readAsStringSync();
    if (content.trim().isEmpty) return;

    try {
      final decoded = jsonDecode(content) as List<dynamic>;
      _tasks
        ..clear()
        ..addAll(decoded.map((e) => _taskFromJson(e as Map<String, dynamic>)));
    } on TaskException {
      rethrow;
    } catch (e) {
      throw TaskPersistenceException(
        'le fichier "$filePath" est corrompu ou mal formé ($e).',
      );
    }
  }

  void _save() {
    try {
      final file = File(filePath);
      final data = _tasks.map((t) => t.toJson()).toList();
      file.writeAsStringSync(const JsonEncoder.withIndent('  ').convert(data));
    } catch (e) {
      throw TaskPersistenceException(
        'impossible d\'écrire dans "$filePath" ($e).',
      );
    }
  }

  Task _taskFromJson(Map<String, dynamic> json) {
    final id = json['id'] as String;
    final title = json['title'] as String;
    final isCompleted = json['isCompleted'] as bool? ?? false;
    final createdAt = json['createdAt'] != null
        ? DateTime.parse(json['createdAt'] as String)
        : DateTime.now();
    final deadline = json['deadline'] != null
        ? DateTime.parse(json['deadline'] as String)
        : null;
    final type = json['type'] as String? ?? 'StandardTask';

    if (type == 'UrgentTask') {
      return UrgentTask(
        id: id,
        title: title,
        deadline: deadline,
        isCompleted: isCompleted,
        createdAt: createdAt,
      );
    }

    final priority = Priority.fromString(json['priority'] as String? ?? 'medium');
    return StandardTask(
      id: id,
      title: title,
      priority: priority,
      deadline: deadline,
      isCompleted: isCompleted,
      createdAt: createdAt,
    );
  }
}
