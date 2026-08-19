import 'dart:io';

import 'package:task_cli/src/exceptions/task_exceptions.dart';
import 'package:task_cli/src/models/priority.dart';
import 'package:task_cli/src/models/standard_task.dart';
import 'package:task_cli/src/models/urgent_task.dart';
import 'package:task_cli/src/repository/task_repository.dart';
import 'package:test/test.dart';

void main() {
  late Directory tempDir;
  late String filePath;
  late TaskRepository repository;

  setUp(() {
    tempDir = Directory.systemTemp.createTempSync('task_cli_test_');
    filePath = '${tempDir.path}/tasks.json';
    repository = TaskRepository(filePath: filePath);
  });

  tearDown(() {
    if (tempDir.existsSync()) {
      tempDir.deleteSync(recursive: true);
    }
  });

  test('add() enregistre la tâche et la persiste dans le fichier JSON', () {
    final task = StandardTask(
      id: '1',
      title: 'Écrire le README',
      priority: Priority.medium,
    );
    repository.add(task);

    expect(repository.getAll(), hasLength(1));
    expect(File(filePath).existsSync(), isTrue);

    final content = File(filePath).readAsStringSync();
    expect(content, contains('Écrire le README'));
  });

  test('complete() marque une tâche comme terminée', () {
    repository.add(StandardTask(id: '1', title: 'Test', priority: Priority.low));

    final completed = repository.complete('1');

    expect(completed.isCompleted, isTrue);
    expect(repository.getById('1')!.isCompleted, isTrue);
  });

  test('complete() lève TaskNotFoundException pour un id inconnu', () {
    expect(
      () => repository.complete('does-not-exist'),
      throwsA(isA<TaskNotFoundException>()),
    );
  });

  test('delete() retire la tâche du dépôt', () {
    repository
        .add(StandardTask(id: '1', title: 'À supprimer', priority: Priority.low));
    expect(repository.getAll(), hasLength(1));

    repository.delete('1');

    expect(repository.getAll(), isEmpty);
    expect(repository.getById('1'), isNull);
  });

  test('delete() lève TaskNotFoundException pour un id inconnu', () {
    expect(
      () => repository.delete('ghost'),
      throwsA(isA<TaskNotFoundException>()),
    );
  });

  test('sortedByPriority() trie de la priorité haute vers basse par défaut', () {
    repository.add(StandardTask(id: '1', title: 'Basse', priority: Priority.low));
    repository.add(StandardTask(id: '2', title: 'Haute', priority: Priority.high));
    repository
        .add(StandardTask(id: '3', title: 'Moyenne', priority: Priority.medium));

    final sorted = repository.sortedByPriority();

    expect(
      sorted.map((t) => t.priority),
      [Priority.high, Priority.medium, Priority.low],
    );
  });

  test('les données survivent à un rechargement depuis le disque, y compris UrgentTask', () {
    repository
        .add(StandardTask(id: '1', title: 'Normale', priority: Priority.medium));
    repository.add(
      UrgentTask(id: '2', title: 'Critique', deadline: DateTime(2030, 1, 1)),
    );

    final reloaded = TaskRepository(filePath: filePath);
    final tasks = reloaded.getAll();

    expect(tasks, hasLength(2));
    final urgent = tasks.firstWhere((t) => t.id == '2');
    expect(urgent, isA<UrgentTask>());
    expect(urgent.priority, Priority.high);
  });
}
