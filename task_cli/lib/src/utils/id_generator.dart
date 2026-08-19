import 'dart:math';

class IdGenerator {
  IdGenerator._();

  static final Random _random = Random();

  static String generate() {
    final timestamp = DateTime.now().microsecondsSinceEpoch.toRadixString(36);
    final suffix = _random.nextInt(0xFFFF).toRadixString(16).padLeft(4, '0');
    return '$timestamp$suffix';
  }
}
