/// A channel webhook, as returned by the `/webhooks/:channel_id` endpoints
/// (backend `pkg/router/webhook.go`): `id`, `channel_id`, `name`, `slug`,
/// `url` and `status`.
class WebhookModel {
  const WebhookModel({
    required this.id,
    required this.channelId,
    required this.name,
    this.slug,
    this.url,
    this.isActive = false,
    this.createdAt,
  });

  factory WebhookModel.fromJson(Map<String, dynamic> json) {
    return WebhookModel(
      id: _string(json['id']),
      channelId: _string(json['channel_id'] ?? json['channelId']),
      name: _string(json['name']),
      slug: _nullableString(json['slug']),
      url: _nullableString(json['url']),
      isActive: _isActive(
        json['status'] ?? json['is_active'] ?? json['isActive'],
      ),
      createdAt: _date(json['created_at'] ?? json['createdAt']),
    );
  }

  final String id;
  final String channelId;
  final String name;
  final String? slug;
  final String? url;

  /// The backend reports `status` as an "active"/"inactive" string, so a bool
  /// flag is derived from either spelling.
  final bool isActive;
  final DateTime? createdAt;

  /// A webhook needs a destination URL to deliver to.
  bool get isValid => id.isNotEmpty && (url?.isNotEmpty ?? false);

  Map<String, dynamic> toJson() => <String, dynamic>{
    'id': id,
    'channel_id': channelId,
    'name': name,
    'slug': slug,
    'url': url,
    'status': isActive ? 'active' : 'inactive',
    'created_at': createdAt?.toIso8601String(),
  };

  WebhookModel copyWith({
    String? id,
    String? channelId,
    String? name,
    String? slug,
    String? url,
    bool? isActive,
    DateTime? createdAt,
  }) {
    return WebhookModel(
      id: id ?? this.id,
      channelId: channelId ?? this.channelId,
      name: name ?? this.name,
      slug: slug ?? this.slug,
      url: url ?? this.url,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  static String _string(Object? value) => value is String ? value : '';

  static String? _nullableString(Object? value) {
    if (value is String && value.isNotEmpty) return value;
    return null;
  }

  static bool _isActive(Object? value) {
    if (value is bool) return value;
    if (value is num) return value != 0;
    if (value is String) {
      final normalized = value.toLowerCase();
      return normalized == 'active' ||
          normalized == 'enabled' ||
          normalized == 'true';
    }
    return false;
  }

  static DateTime? _date(Object? value) =>
      value is String ? DateTime.tryParse(value) : null;

  @override
  bool operator ==(Object other) =>
      other is WebhookModel &&
      other.id == id &&
      other.channelId == channelId &&
      other.name == name &&
      other.slug == slug &&
      other.url == url &&
      other.isActive == isActive &&
      other.createdAt == createdAt;

  @override
  int get hashCode =>
      Object.hash(id, channelId, name, slug, url, isActive, createdAt);

  @override
  String toString() =>
      'WebhookModel(id: $id, name: $name, isActive: $isActive)';
}
