import 'package:flutter_test/flutter_test.dart';
import 'package:zedu/core/network/models/subscription_token_model.dart';

void main() {
  group('SubscriptionTokenModel.fromJson', () {
    test('reads the wrapped response envelope the backend returns', () {
      final model = SubscriptionTokenModel.fromJson(const {
        'status': 'success',
        'data': {'token': 'tok_123'},
      });

      expect(model.token, 'tok_123');
      expect(model.channel, '');
    });

    test('reads a bare payload with both fields', () {
      final model = SubscriptionTokenModel.fromJson(const {
        'channel': 'channel:org-1:general',
        'token': 'tok_abc',
      });

      expect(model.channel, 'channel:org-1:general');
      expect(model.token, 'tok_abc');
      expect(model.isValid, isTrue);
    });

    test('prefers the data envelope over top-level fields', () {
      final model = SubscriptionTokenModel.fromJson(const {
        'channel': 'outer',
        'token': 'outer-token',
        'data': {'channel': 'inner', 'token': 'inner-token'},
      });

      expect(model.channel, 'inner');
      expect(model.token, 'inner-token');
    });

    test('falls back to empty strings when fields are missing', () {
      final model = SubscriptionTokenModel.fromJson(const {});

      expect(model.channel, '');
      expect(model.token, '');
      expect(model.isValid, isFalse);
    });

    test('ignores non-string values instead of throwing', () {
      final model = SubscriptionTokenModel.fromJson(const {
        'channel': 'c',
        'token': 42,
      });

      expect(model.channel, 'c');
      expect(model.token, '');
    });

    test('a token without a channel is not valid', () {
      final model = SubscriptionTokenModel.fromJson(const {
        'data': {'token': 'tok_only'},
      });

      expect(model.isValid, isFalse);
    });
  });

  group('serialization', () {
    const secret = 'ziki_secret_value_123';
    const model = SubscriptionTokenModel(channel: 'channel:1', token: secret);

    test('toJson keeps both fields', () {
      expect(model.toJson(), {'channel': 'channel:1', 'token': secret});
    });

    test('toRequestJson sends only the channel', () {
      expect(model.toRequestJson(), {'channel': 'channel:1'});
    });

    test('round-trips through toJson and fromJson', () {
      expect(SubscriptionTokenModel.fromJson(model.toJson()), model);
    });

    test('toString does not leak the token value', () {
      expect(model.toString(), isNot(contains(secret)));
      expect(model.toString(), contains('channel:1'));
    });
  });
}
