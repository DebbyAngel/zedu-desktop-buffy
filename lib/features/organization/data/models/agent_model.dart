/// An organisation AI agent (bot), as returned by
/// `GET /organisations/:org_id/fetch-bots` and `/organisations/:org_id/agents`.
class AgentModel {
  const AgentModel({
    required this.id,
    required this.name,
    this.description,
    this.systemPrompt,
    this.avatarUrl,
    this.isActive = false,
    this.createdAt,
  });

  factory AgentModel.fromJson(Map<String, dynamic> json) {
    return AgentModel(
      id: _string(json['id']),
      name: _string(json['name'] ?? json['agent_name']),
      description: _nullableString(json['description']),
      systemPrompt: _nullableString(
        json['system_prompt'] ?? json['systemPrompt'],
      ),
      avatarUrl: _nullableString(json['avatar_url'] ?? json['avatarUrl']),
      isActive: _bool(json['is_active'] ?? json['isActive']),
      createdAt: _date(json['created_at'] ?? json['createdAt']),
    );
  }

  final String id;
  final String name;
  final String? description;
  final String? systemPrompt;
  final String? avatarUrl;
  final bool isActive;
  final DateTime? createdAt;

  /// A bot without an id or a name cannot be listed or opened, so it is
  /// treated as unusable rather than rendered as a blank row.
  bool get isValid => id.isNotEmpty && name.isNotEmpty;

  Map<String, dynamic> toJson() => <String, dynamic>{
    'id': id,
    'name': name,
    'description': description,
    'system_prompt': systemPrompt,
    'avatar_url': avatarUrl,
    'is_active': isActive,
    'created_at': createdAt?.toIso8601String(),
  };

  AgentModel copyWith({
    String? id,
    String? name,
    String? description,
    String? systemPrompt,
    String? avatarUrl,
    bool? isActive,
    DateTime? createdAt,
  }) {
    return AgentModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      systemPrompt: systemPrompt ?? this.systemPrompt,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  static String _string(Object? value) => value is String ? value : '';

  static String? _nullableString(Object? value) {
    if (value is String && value.isNotEmpty) return value;
    return null;
  }

  static bool _bool(Object? value) {
    if (value is bool) return value;
    if (value is num) return value != 0;
    if (value is String) return value.toLowerCase() == 'true';
    return false;
  }

  static DateTime? _date(Object? value) =>
      value is String ? DateTime.tryParse(value) : null;

  @override
  bool operator ==(Object other) =>
      other is AgentModel &&
      other.id == id &&
      other.name == name &&
      other.description == description &&
      other.systemPrompt == systemPrompt &&
      other.avatarUrl == avatarUrl &&
      other.isActive == isActive &&
      other.createdAt == createdAt;

  @override
  int get hashCode => Object.hash(
    id,
    name,
    description,
    systemPrompt,
    avatarUrl,
    isActive,
    createdAt,
  );

  @override
  String toString() => 'AgentModel(id: $id, name: $name, isActive: $isActive)';
}
