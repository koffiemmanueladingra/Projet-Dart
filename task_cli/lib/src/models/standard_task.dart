import 'task.dart';

class StandardTask extends Task {
  StandardTask({
    required super.id,
    required super.title,
    required super.priority,
    super.deadline,
    super.isCompleted,
    super.createdAt,
  });

  @override
  String get typeLabel => 'StandardTask';
}
