abstract class TaskException implements Exception {
  final String message;

  const TaskException(this.message);

  @override
  String toString() => message;
}

class TaskNotFoundException extends TaskException {
  final String taskId;

  TaskNotFoundException(this.taskId)
      : super('Aucune tâche trouvée avec l\'identifiant "$taskId".');
}

class InvalidTaskException extends TaskException {
  InvalidTaskException(super.message);
}

class InvalidPriorityException extends TaskException {
  InvalidPriorityException(String value)
      : super(
          'Priorité invalide: "$value". Valeurs attendues: low, medium, high.',
        );
}

class TaskPersistenceException extends TaskException {
  TaskPersistenceException(String detail)
      : super('Erreur de persistance des données: $detail');
}
