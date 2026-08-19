import 'priority.dart';
import 'task.dart';

class UrgentTask extends Task {
  final int escalationWindowHours;

  UrgentTask({
    required String id,
    required String title,
    DateTime? deadline,
    bool isCompleted = false,
    DateTime? createdAt,
    this.escalationWindowHours = 24,
  }) : super(
          id: id,
          title: title,
          priority: Priority.high,
          deadline: deadline,
          isCompleted: isCompleted,
          createdAt: createdAt,
        );

  bool get isEscalated {
    if (isCompleted || deadline == null) return false;
    final hoursLeft = deadline!.difference(DateTime.now()).inHours;
    return hoursLeft <= escalationWindowHours;
  }

  @override
  String get typeLabel => 'UrgentTask';

  @override
  String toString() {
    final base = super.toString();
    return isEscalated ? 'base' : base;
  }
}
