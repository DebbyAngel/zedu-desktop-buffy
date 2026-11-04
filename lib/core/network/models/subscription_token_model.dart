/// A Centrifugo channel subscription token.
///
/// The backend exposes `POST /token/subscription`, which accepts
/// `{ "channel": "..." }` and answers
/// `{ "status": "success", "data": { "token": "..." } }`.
///
/// [fromJson] accepts both the wrapped response envelope and a bare payload,
/// because the token route is also called with the `data` object alone by the
/// web client.
class SubscriptionTokenModel {
  const SubscriptionTokenModel({required this.channel, required this.token});

  factory SubscriptionTokenModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'];
    final payload = data is Map<String, dynamic>
        ? data
        : const <String, dynamic>{};

    return SubscriptionTokenModel(
      channel: _asString(payload['channel'] ?? json['channel']),
      token: _asString(payload['token'] ?? json['token']),
    );
  }

  /// The channel this token subscribes to.
  final String channel;

  /// The token to hand to the Centrifugo client.
  final String token;

  /// A token is useless without both halves, so an empty pair is invalid.
  bool get isValid => channel.isNotEmpty && token.isNotEmpty;

  Map<String, dynamic> toJson() => <String, dynamic>{
    'channel': channel,
    'token': token,
  };

  /// The request body `POST /token/subscription` expects.
  Map<String, dynamic> toRequestJson() => <String, dynamic>{'channel': channel};

  static String _asString(Object? value) => value is String ? value : '';

  @override
  bool operator ==(Object other) =>
      other is SubscriptionTokenModel &&
      other.channel == channel &&
      other.token == token;

  @override
  int get hashCode => Object.hash(channel, token);

  // The token is a credential: keep it out of logs and crash reports.
  @override
  String toString() =>
      'SubscriptionTokenModel(channel: $channel, token: <redacted>)';
}
