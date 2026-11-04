import 'package:flutter_test/flutter_test.dart';
import 'package:zedu/features/dms/domain/notification_preview.dart';

void main() {
  group('notificationPreview', () {
    test('leaves plain text alone', () {
      expect(
        notificationPreview(content: 'Hello Ada', hasMedia: false),
        'Hello Ada',
      );
    });

    test('strips HTML tags that another client sent', () {
      expect(
        notificationPreview(
          content: 'Hello <strong>Ada</strong>',
          hasMedia: false,
        ),
        'Hello Ada',
      );
    });

    test('decodes entities before truncation', () {
      expect(
        notificationPreview(content: 'Tom &amp; Jerry &lt;3', hasMedia: false),
        'Tom & Jerry <3',
      );
    });

    test('keeps entities it does not know instead of dropping them', () {
      expect(
        notificationPreview(content: 'a &weird; b', hasMedia: false),
        'a &weird; b',
      );
    });

    test('decodes numeric entities', () {
      expect(
        notificationPreview(content: 'caf&#233; &#x1F680;', hasMedia: false),
        'café 🚀',
      );
    });

    test('a tag-only message falls back like empty content', () {
      expect(
        notificationPreview(content: '<p></p>', hasMedia: false),
        'New message',
      );
      expect(
        notificationPreview(content: '<p></p>', hasMedia: true),
        'Sent an attachment',
      );
    });

    test('falls back for empty and whitespace-only content', () {
      expect(notificationPreview(content: '', hasMedia: false), 'New message');
      expect(
        notificationPreview(content: '   ', hasMedia: false),
        'New message',
      );
      expect(
        notificationPreview(content: null, hasMedia: false),
        'New message',
      );
      expect(
        notificationPreview(content: null, hasMedia: true),
        'Sent an attachment',
      );
    });

    test('truncates to 80 characters and never leaves a broken tag', () {
      final preview = notificationPreview(
        content: '<strong>${'a' * 200}</strong>',
        hasMedia: false,
      );

      expect(preview.length, 80);
      expect(preview.endsWith('...'), isTrue);
      expect(preview, isNot(contains('<')));
    });

    test('short content is not truncated', () {
      final content = 'a' * 80;

      expect(notificationPreview(content: content, hasMedia: false), content);
    });

    test('collapses the whitespace that tag removal leaves behind', () {
      expect(
        notificationPreview(
          content: '<p>Hello</p> <p>Ada</p>',
          hasMedia: false,
        ),
        'Hello Ada',
      );
    });
  });
}
