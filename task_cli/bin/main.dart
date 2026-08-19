import 'dart:io';

import 'package:task_cli/src/cli/cli_app.dart';

void main(List<String> arguments) {
  final app = CliApp();
  exitCode = app.run(arguments);
}
