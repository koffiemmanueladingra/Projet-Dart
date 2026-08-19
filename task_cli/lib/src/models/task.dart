import '../exceptions/task_exceptions.dart';
import '../utils/json_serializable.dart';
import 'priority.dart';

abstract class Task implements JsonSerializable, Comparable<Task> {
  final String id;
  String title;
  Priority priority;
  DateTime? deadline;
  bool isCompleted;
  final DateTime createdAt;

  Task({
    required this.id,
    required String title,
    required this.priority,
    this.deadline,
    this.isCompleted = false,
    DateTime? createdAt,
  })  : title = _validateTitle(title),
        createdAt = createdAt ?? DateTime.now();

  static String _validateTitle(String title) {
    if (title.trim().isEmpty) {
      throw InvalidTaskException('Le titre d\'une tâche ne peut pas être vide.');
    }
    return title.trim();
  }

  String get typeLabel => 'Task';

  void markAsCompleted() {
    isCompleted = true;
  }

  @override
  Map<String, dynamic> toJson() => {
        'id': id,
        'type': typeLabel,
        'title': title,
        'priority': priority.name,
        'deadline': deadline?.toIso8601String(),
        'isCompleted': isCompleted,
        'createdAt': createdAt.toIso8601String(),
      };

  @override
  int compareTo(Task other) => other.priority.index.compareTo(priority.index);

  @override
  bool operator ==(Object other) => other is Task && other.id == id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    final status = isCompleted ? '[x]' : '[ ]';
    final deadlineText =
        deadline == null ? '' : '  échéance: ${_formatDate(deadline!)}';
    return '$status ($typeLabel) [${priority.label}] $title$deadlineText';
  }

  static String _formatDate(DateTime date) {
    String two(int n) => n.toString().padLeft(2, '0');
    return '${date.year}-${two(date.month)}-${two(date.day)}';
  }
}
