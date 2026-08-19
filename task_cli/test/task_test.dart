import 'package:task_cli/src/exceptions/task_exceptions.dart';
import 'package:task_cli/src/models/priority.dart';
import 'package:task_cli/src/models/standard_task.dart';
import 'package:task_cli/src/models/urgent_task.dart';
import 'package:test/test.dart';

void main() {
  group('StandardTask', () {
    test('rejette un titre vide', () {
      expect(
        () => StandardTask(id: '1', title: '   ', priority: Priority.low),
        throwsA(isA<InvalidTaskException>()),
      );
    });

    test('n\'est pas terminée par défaut, puis le devient après markAsCompleted()', () {
      final task =
          StandardTask(id: '1', title: 'Test', priority: Priority.medium);
      expect(task.isCompleted, isFalse);

      task.markAsCompleted();
      expect(task.isCompleted, isTrue);
    });

    test('se sérialise en JSON avec les clés attendues', () {
      final task =
          StandardTask(id: '42', title: 'Test JSON', priority: Priority.high);
      final json = task.toJson();

      expect(json['id'], '42');
      expect(json['title'], 'Test JSON');
      expect(json['priority'], 'high');
      expect(json['type'], 'StandardTask');
      expect(json['isCompleted'], isFalse);
    });
  });

  group('UrgentTask', () {
    test('est toujours créée avec la priorité "high"', () {
      final task = UrgentTask(id: '1', title: 'Serveur en feu');
      expect(task.priority, Priority.high);
    });

    test('isEscalated est vrai quand l\'échéance est proche', () {
      final soon = DateTime.now().add(const Duration(hours: 2));
      final task = UrgentTask(
        id: '1',
        title: 'Escalade imminente',
        deadline: soon,
        escalationWindowHours: 24,
      );
      expect(task.isEscalated, isTrue);
    });

    test('isEscalated redevient faux une fois la tâche terminée', () {
      final soon = DateTime.now().add(const Duration(hours: 2));
      final task = UrgentTask(id: '1', title: 'Test', deadline: soon);
      task.markAsCompleted();
      expect(task.isEscalated, isFalse);
    });
  });

  group('Task.compareTo', () {
    test('trie les tâches de la priorité la plus haute à la plus basse', () {
      final low = StandardTask(id: '1', title: 'Basse', priority: Priority.low);
      final high =
          StandardTask(id: '2', title: 'Haute', priority: Priority.high);

      final tasks = [low, high]..sort();

      expect(tasks.first, high);
      expect(tasks.last, low);
    });
  });
}
