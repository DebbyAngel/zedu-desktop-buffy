import 'package:flutter_test/flutter_test.dart';
import 'package:zedu/features/home/presentation/widgets/message_composer.dart';

void main() {
  group('mentionAvatarInitial', () {
    test('uses the first letter of a name, upper-cased', () {
      expect(mentionAvatarInitial('ada'), 'A');
    });

    test('trims before taking the first character', () {
      expect(mentionAvatarInitial('  ada'), 'A');
      expect(mentionAvatarInitial('ada  '), 'A');
    });

    test('a whitespace-only name falls back to ?', () {
      // Previously `name.isNotEmpty` was true for '   ', so the avatar
      // rendered a blank space instead of the fallback.
      expect(mentionAvatarInitial('   '), '?');
    });

    test('an empty name falls back to ?', () {
      expect(mentionAvatarInitial(''), '?');
    });

    test('keeps an emoji intact instead of splitting its surrogate pair', () {
      final initial = mentionAvatarInitial('🚀 Bob');

      expect(initial, '🚀');
      expect(initial.runes.length, 1);
    });

    test('keeps a non-BMP character from an emoji name', () {
      // `name[0]` used to return only the high surrogate, which rendered as a
      // corrupt glyph.
      final initial = mentionAvatarInitial('👩‍💻 Alice');

      expect(initial.runes.length, 1);
      expect(initial.codeUnitAt(0), greaterThan(0xD7FF));
    });

    test('upper-cases a plain ASCII initial and leaves others unchanged', () {
      expect(mentionAvatarInitial('bob'), 'B');
      expect(mentionAvatarInitial('élodie'), 'É');
    });
  });
}
