import 'package:flutter_test/flutter_test.dart';
import 'package:zedu/features/channels/data/models/webhook_model.dart';

void main() {
  group('WebhookModel.fromJson', () {
    test('parses the fields the backend returns', () {
      final hook = WebhookModel.fromJson(const {
        'id': 'hook_1',
        'channel_id': 'chan_1',
        'name': 'Deploys',
        'slug': 'deploys',
        'url': 'https://example.com/hooks/deploys',
        'status': 'active',
        'created_at': '2026-10-19T12:10:00.000Z',
      });

      expect(hook.id, 'hook_1');
      expect(hook.channelId, 'chan_1');
      expect(hook.name, 'Deploys');
      expect(hook.slug, 'deploys');
      expect(hook.url, 'https://example.com/hooks/deploys');
      expect(hook.isActive, isTrue);
      expect(hook.createdAt, DateTime.parse('2026-10-19T12:10:00.000Z'));
      expect(hook.isValid, isTrue);
    });

    test('maps an inactive status string to isActive false', () {
      expect(
        WebhookModel.fromJson(const {
          'id': 'h',
          'channel_id': 'c',
          'name': 'n',
          'status': 'inactive',
        }).isActive,
        isFalse,
      );
      expect(
        WebhookModel.fromJson(const {
          'id': 'h',
          'channel_id': 'c',
          'name': 'n',
          'status': 'enabled',
        }).isActive,
        isTrue,
      );
    });

    test('accepts a boolean is_active as well as a status string', () {
      expect(
        WebhookModel.fromJson(const {
          'id': 'h',
          'channel_id': 'c',
          'name': 'n',
          'is_active': true,
        }).isActive,
        isTrue,
      );
      expect(
        WebhookModel.fromJson(const {
          'id': 'h',
          'channel_id': 'c',
          'name': 'n',
          'is_active': 0,
        }).isActive,
        isFalse,
      );
    });

    test(
      'missing optional fields become null and the hook stays valid only with a url',
      () {
        final hook = WebhookModel.fromJson(const {
          'id': 'hook_2',
          'channel_id': 'chan_2',
          'name': 'No destination',
        });

        expect(hook.slug, isNull);
        expect(hook.url, isNull);
        expect(hook.createdAt, isNull);
        expect(hook.isActive, isFalse);
        expect(hook.isValid, isFalse);
      },
    );

    test('does not throw on an empty payload', () {
      final hook = WebhookModel.fromJson(const {});

      expect(hook.id, '');
      expect(hook.channelId, '');
      expect(hook.name, '');
      expect(hook.isValid, isFalse);
    });
  });

  group('serialization', () {
    test('round-trips through toJson and fromJson', () {
      final hook = WebhookModel.fromJson(const {
        'id': 'hook_1',
        'channel_id': 'chan_1',
        'name': 'Deploys',
        'slug': 'deploys',
        'url': 'https://example.com/hooks/deploys',
        'status': 'active',
        'created_at': '2026-10-19T12:10:00.000Z',
      });

      expect(WebhookModel.fromJson(hook.toJson()), hook);
    });

    test('toJson writes status back as a string', () {
      const hook = WebhookModel(
        id: 'h',
        channelId: 'c',
        name: 'n',
        isActive: true,
      );

      expect(hook.toJson()['status'], 'active');
    });

    test('copyWith replaces only what it is given', () {
      const hook = WebhookModel(id: 'h', channelId: 'c', name: 'n');
      final updated = hook.copyWith(isActive: true, url: 'https://x.test/h');

      expect(updated.isActive, isTrue);
      expect(updated.url, 'https://x.test/h');
      expect(updated.name, 'n');
    });
  });
}
