/// A mention of the signed-in user, as returned by
/// `GET /organisations/:org_id/mentions` (backend `pkg/router/activity.go`).
class UserMentionActivityModel {
  const UserMentionActivityModel({
    required this.id,
    required this.messageId,
    required this.channelId,
    this.channelName,
    this.senderId,
    this.senderName,
    this.senderAvatarUrl,
    this.content,
    this.createdAt,
  });

  factory UserMentionActivityModel.fromJson(Map<String, dynamic> json) {
    return UserMentionActivityModel(
      id: _string(json['id']),
      messageId: _string(json['message_id'] ?? json['messageId']),
      channelId: _string(json['channel_id'] ?? json['channelId']),
      channelName: _nullableString(json['channel_name'] ?? json['channelName']),
      senderId: _nullableString(json['sender_id'] ?? json['senderId']),
      senderName: _nullableString(json['sender_name'] ?? json['senderName']),
      senderAvatarUrl: _nullableString(
        json['sender_avatar_url'] ?? json['senderAvatarUrl'],
      ),
      content: _nullableString(json['content']),
      createdAt: _date(json['created_at'] ?? json['createdAt']),
    );
  }

  final String id;
  final String messageId;
  final String channelId;
  final String? channelName;
  final String? senderId;
  final String? senderName;
  final String? senderAvatarUrl;
  final String? content;
  final DateTime? createdAt;

  /// A mention has to point at the message it came from, otherwise tapping the
  /// row has nowhere to go.
  bool get isValid => messageId.isNotEmpty && channelId.isNotEmpty;

  /// The name to show for the sender, falling back to a neutral label because
  /// the backend can omit the sender (deleted or private account).
  String get senderDisplayName =>
      senderName?.isNotEmpty == true ? senderName! : 'Someone';

  Map<String, dynamic> toJson() => <String, dynamic>{
    'id': id,
    'message_id': messageId,
    'channel_id': channelId,
    'channel_name': channelName,
    'sender_id': senderId,
    'sender_name': senderName,
    'sender_avatar_url': senderAvatarUrl,
    'content': content,
    'created_at': createdAt?.toIso8601String(),
  };

  static String _string(Object? value) => value is String ? value : '';

  static String? _nullableString(Object? value) {
    if (value is String && value.isNotEmpty) return value;
    return null;
  }

  static DateTime? _date(Object? value) =>
      value is String ? DateTime.tryParse(value) : null;

  @override
  bool operator ==(Object other) =>
      other is UserMentionActivityModel &&
      other.id == id &&
      other.messageId == messageId &&
      other.channelId == channelId &&
      other.channelName == channelName &&
      other.senderId == senderId &&
      other.senderName == senderName &&
      other.senderAvatarUrl == senderAvatarUrl &&
      other.content == content &&
      other.createdAt == createdAt;

  @override
  int get hashCode => Object.hash(
    id,
    messageId,
    channelId,
    channelName,
    senderId,
    senderName,
    senderAvatarUrl,
    content,
    createdAt,
  );

  @override
  String toString() =>
      'UserMentionActivityModel(messageId: $messageId, channelId: $channelId)';
}
