import 'package:flutter_test/flutter_test.dart';
import 'package:quality_assurance/is_valid_task_title.dart';

void main() {
  group('isValidTaskTitle', () {
    // --- happy path ---
    test('accepts a title with text', () {
      expect(isValidTaskTitle('Learn Flutter'), isTrue);
    });

    test('accepts a title that is a single character', () {
      expect(isValidTaskTitle('A'), isTrue);
    });

    test('accepts a title that has leading and trailing whitespace', () {
      // Whitespace around real text is still a valid title.
      expect(isValidTaskTitle('  Flutter  '), isTrue);
    });

    // --- edge cases / failure path ---
    test('rejects an empty string', () {
      expect(isValidTaskTitle(''), isFalse);
    });

    test('rejects a whitespace-only string', () {
      expect(isValidTaskTitle('   '), isFalse);
    });

    test('rejects a tab-only string', () {
      expect(isValidTaskTitle('\t'), isFalse);
    });
  });
}
