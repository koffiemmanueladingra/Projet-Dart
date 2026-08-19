import '../exceptions/task_exceptions.dart';

enum Priority {
  low,
  medium,
  high;

  String get label {
    switch (this) {
      case Priority.low:
        return 'Basse';
      case Priority.medium:
        return 'Moyenne';
      case Priority.high:
        return 'Haute';
    }
  }

  static Priority fromString(String value) {
    return Priority.values.firstWhere(
      (p) => p.name.toLowerCase() == value.trim().toLowerCase(),
      orElse: () => throw InvalidPriorityException(value),
    );
  }
}
