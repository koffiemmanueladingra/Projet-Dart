import 'package:task_cli/src/exceptions/task_exceptions.dart';
import 'package:task_cli/src/models/priority.dart';
import 'package:test/test.dart';

void main() {
  group('Priority.fromString', () {
    test('parse les valeurs valides sans tenir compte de la casse', () {
      expect(Priority.fromString('low'), Priority.low);
      expect(Priority.fromString('MEDIUM'), Priority.medium);
      expect(Priority.fromString('High'), Priority.high);
    });

    test('lève InvalidPriorityException pour une valeur inconnue', () {
      expect(
        () => Priority.fromString('urgentissime'),
        throwsA(isA<InvalidPriorityException>()),
      );
    });
  });
}
