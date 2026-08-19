import 'dart:io';

import '../exceptions/task_exceptions.dart';
import '../models/priority.dart';
import '../models/standard_task.dart';
import '../models/task.dart';
import '../models/urgent_task.dart';
import '../repository/task_repository.dart';
import '../utils/id_generator.dart';

class CliApp {
  final TaskRepository repository;
  final Stdout _out;

  CliApp({TaskRepository? repository, Stdout? out})
      : repository = repository ?? TaskRepository(),
        _out = out ?? stdout;

  int run(List<String> arguments) {
    if (arguments.isEmpty) {
      _printHelp();
      return 0;
    }

    final command = arguments.first;
    final options = _parseOptions(arguments.skip(1).toList());

    try {
      switch (command) {
        case 'add':
          _handleAdd(options);
          return 0;
        case 'list':
          _handleList(options);
          return 0;
        case 'complete':
          _handleComplete(options);
          return 0;
        case 'delete':
          _handleDelete(options);
          return 0;
        case 'help':
        case '--help':
        case '-h':
          _printHelp();
          return 0;
        default:
          stderr.writeln('Commande inconnue: "$command"');
          _printHelp();
          return 64;
      }
    } on TaskException catch (e) {
      stderr.writeln('${e.message}');
      return 1;
    }
  }


  Map<String, String> _parseOptions(List<String> args) {
    final options = <String, String>{};
    for (var i = 0; i < args.length; i++) {
      var token = args[i];
      if (!token.startsWith('--')) continue;
      token = token.substring(2);

      if (token.contains('=')) {
        final parts = token.split('=');
        options[parts.first] = parts.sublist(1).join('=');
        continue;
      }

      final isLast = i == args.length - 1;
      final nextIsFlag = !isLast && args[i + 1].startsWith('--');
      if (isLast || nextIsFlag) {
        options[token] = 'true';
      } else {
        options[token] = args[++i];
      }
    }
    return options;
  }

  void _handleAdd(Map<String, String> options) {
    final title = options['title'];
    if (title == null || title.trim().isEmpty) {
      throw InvalidTaskException(
        'Le titre est obligatoire, ex: --title "Payer la facture EDT"',
      );
    }

    DateTime? deadline;
    final deadlineRaw = options['deadline'];
    if (deadlineRaw != null) {
      try {
        deadline = DateTime.parse(deadlineRaw);
      } on FormatException {
        throw InvalidTaskException(
          'Format de date invalide: "$deadlineRaw" (attendu AAAA-MM-JJ).',
        );
      }
    }

    final id = IdGenerator.generate();
    final isUrgent = options['urgent'] == 'true';

    final Task task;
    if (isUrgent) {
      task = UrgentTask(id: id, title: title, deadline: deadline);
    } else {
      final priority = Priority.fromString(options['priority'] ?? 'medium');
      task = StandardTask(
        id: id,
        title: title,
        priority: priority,
        deadline: deadline,
      );
    }

    repository.add(task);
    _out.writeln('Tâche ajoutée [${task.id}]');
    _out.writeln('   $task');
  }

  void _handleList(Map<String, String> options) {
    final sortBy = options['sort'] ?? 'priority';
    final List<Task> tasks;
    switch (sortBy) {
      case 'deadline':
        tasks = repository.sortedByDeadline();
        break;
      case 'priority':
        tasks = repository.sortedByPriority();
        break;
      default:
        throw InvalidTaskException(
          'Critère de tri invalide: "$sortBy" (attendu: priority, deadline).',
        );
    }

    if (tasks.isEmpty) {
      _out.writeln('Aucune tâche enregistrée pour le moment.');
      return;
    }

    _out.writeln('=== ${tasks.length} tâche(s), triées par $sortBy ===');
    for (final task in tasks) {
      _out.writeln('[${task.id}] $task');
    }
  }

  void _handleComplete(Map<String, String> options) {
    final id = _requireId(options);
    final task = repository.complete(id);
    _out.writeln('Tâche marquée comme terminée: $task');
  }

  void _handleDelete(Map<String, String> options) {
    final id = _requireId(options);
    repository.delete(id);
    _out.writeln('Tâche supprimée: $id');
  }

  String _requireId(Map<String, String> options) {
    final id = options['id'];
    if (id == null || id.trim().isEmpty) {
      throw InvalidTaskException('L\'identifiant est obligatoire: --id <id>');
    }
    return id;
  }

  void _printHelp() {
    _out.writeln('''
Gestionnaire de tâches en ligne de commande

Usage:
  dart run bin/main.dart <commande> [options]

Commandes:
  add --title "<titre>" [--priority low|medium|high] [--deadline AAAA-MM-JJ] [--urgent]
      Ajoute une nouvelle tâche. --urgent force la priorité à "high" et crée
      une UrgentTask.

  list [--sort priority|deadline]
      Liste toutes les tâches (tri par priorité par défaut).

  complete --id <id>
      Marque la tâche <id> comme terminée.

  delete --id <id>
      Supprime la tâche <id>.

  help
      Affiche ce message.

Exemples:
  dart run bin/main.dart add --title "Payer la facture" --priority high --deadline 2026-08-25
  dart run bin/main.dart add --title "Serveur en panne" --urgent
  dart run bin/main.dart list --sort deadline
  dart run bin/main.dart complete --id 1a2b3c
  dart run bin/main.dart delete --id 1a2b3c
''');
  }
}
