import 'package:flutter_test/flutter_test.dart';
import 'package:zedu/features/home/data/models/user_mention_activity_model.dart';

void main() {
  group('UserMentionActivityModel.fromJson', () {
    test('parses the fields the backend returns', () {
      final mention = UserMentionActivityModel.fromJson(const {
        'id': 'mention_1',
        'message_id': 'msg_1',
        'channel_id': 'chan_1',
        'channel_name': 'general',
        'sender_id': 'user_2',
        'sender_name': 'Ada',
        'sender_avatar_url': 'https://cdn/ada.png',
        'content': 'hey @ada can you look?',
        'created_at': '2026-10-19T12:10:00.000Z',
      });

      expect(mention.id, 'mention_1');
      expect(mention.messageId, 'msg_1');
      expect(mention.channelId, 'chan_1');
      expect(mention.channelName, 'general');
      expect(mention.senderId, 'user_2');
      expect(mention.senderName, 'Ada');
      expect(mention.senderAvatarUrl, 'https://cdn/ada.png');
      expect(mention.content, 'hey @ada can you look?');
      expect(mention.createdAt, DateTime.parse('2026-10-19T12:10:00.000Z'));
      expect(mention.isValid, isTrue);
    });

    test('missing optional fields become null', () {
      final mention = UserMentionActivityModel.fromJson(const {
        'message_id': 'msg_1',
        'channel_id': 'chan_1',
      });

      expect(mention.id, '');
      expect(mention.channelName, isNull);
      expect(mention.senderName, isNull);
      expect(mention.senderAvatarUrl, isNull);
      expect(mention.content, isNull);
      expect(mention.createdAt, isNull);
    });

    test('a mention without a message or channel is not valid', () {
      expect(
        UserMentionActivityModel.fromJson(const {'channel_id': 'c'}).isValid,
        isFalse,
      );
      expect(
        UserMentionActivityModel.fromJson(const {'message_id': 'm'}).isValid,
        isFalse,
      );
    });

    test('senderDisplayName falls back when the sender is unknown', () {
      expect(
        UserMentionActivityModel.fromJson(const {
          'message_id': 'm',
          'channel_id': 'c',
        }).senderDisplayName,
        'Someone',
      );
      expect(
        UserMentionActivityModel.fromJson(const {
          'message_id': 'm',
          'channel_id': 'c',
          'sender_name': 'Ada',
        }).senderDisplayName,
        'Ada',
      );
    });

    test('an unparseable date becomes null instead of throwing', () {
      expect(
        UserMentionActivityModel.fromJson(const {
          'message_id': 'm',
          'channel_id': 'c',
          'created_at': 'nope',
        }).createdAt,
        isNull,
      );
    });
  });

  group('serialization', () {
    test('round-trips through toJson and fromJson', () {
      final mention = UserMentionActivityModel.fromJson(const {
        'id': 'mention_1',
        'message_id': 'msg_1',
        'channel_id': 'chan_1',
        'channel_name': 'general',
        'sender_name': 'Ada',
        'content': 'hello',
        'created_at': '2026-10-19T12:10:00.000Z',
      });

      expect(UserMentionActivityModel.fromJson(mention.toJson()), mention);
    });

    test('toJson emits the snake_case keys the backend uses', () {
      const mention = UserMentionActivityModel(
        id: 'm1',
        messageId: 'msg_1',
        channelId: 'chan_1',
        senderName: 'Ada',
      );

      expect(mention.toJson()['message_id'], 'msg_1');
      expect(mention.toJson()['channel_id'], 'chan_1');
      expect(mention.toJson()['sender_name'], 'Ada');
    });
  });
}
