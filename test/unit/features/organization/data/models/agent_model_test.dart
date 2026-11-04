import 'package:flutter_test/flutter_test.dart';
import 'package:zedu/features/organization/data/models/agent_model.dart';

void main() {
  group('AgentModel.fromJson', () {
    test('parses a full snake_case payload', () {
      final agent = AgentModel.fromJson(const {
        'id': 'agent_1',
        'name': 'Support Bot',
        'description': 'Answers billing questions',
        'system_prompt': 'Be helpful',
        'avatar_url': 'https://cdn/avatar.png',
        'is_active': true,
        'created_at': '2026-10-19T12:10:00.000Z',
      });

      expect(agent.id, 'agent_1');
      expect(agent.name, 'Support Bot');
      expect(agent.description, 'Answers billing questions');
      expect(agent.systemPrompt, 'Be helpful');
      expect(agent.avatarUrl, 'https://cdn/avatar.png');
      expect(agent.isActive, isTrue);
      expect(agent.createdAt, DateTime.parse('2026-10-19T12:10:00.000Z'));
      expect(agent.isValid, isTrue);
    });

    test('accepts camelCase keys', () {
      final agent = AgentModel.fromJson(const {
        'id': 'agent_2',
        'name': 'Ops Bot',
        'systemPrompt': 'Watch deploys',
        'avatarUrl': 'https://cdn/ops.png',
        'isActive': true,
        'createdAt': '2026-10-19T12:10:00.000Z',
      });

      expect(agent.systemPrompt, 'Watch deploys');
      expect(agent.avatarUrl, 'https://cdn/ops.png');
      expect(agent.isActive, isTrue);
      expect(agent.createdAt, isNotNull);
    });

    test('falls back safely for missing fields', () {
      final agent = AgentModel.fromJson(const {'id': 'agent_3', 'name': 'Bot'});

      expect(agent.description, isNull);
      expect(agent.systemPrompt, isNull);
      expect(agent.avatarUrl, isNull);
      expect(agent.isActive, isFalse);
      expect(agent.createdAt, isNull);
    });

    test('treats empty strings as null for optional text', () {
      final agent = AgentModel.fromJson(const {
        'id': 'agent_4',
        'name': 'Bot',
        'description': '',
        'avatar_url': '',
      });

      expect(agent.description, isNull);
      expect(agent.avatarUrl, isNull);
    });

    test('reads is_active from a string or a number', () {
      expect(
        AgentModel.fromJson(const {'id': 'a', 'is_active': 'true'}).isActive,
        isTrue,
      );
      expect(
        AgentModel.fromJson(const {'id': 'a', 'is_active': 1}).isActive,
        isTrue,
      );
      expect(
        AgentModel.fromJson(const {'id': 'a', 'is_active': 'false'}).isActive,
        isFalse,
      );
    });

    test('an unparseable date becomes null instead of throwing', () {
      final agent = AgentModel.fromJson(const {
        'id': 'a',
        'name': 'Bot',
        'created_at': 'not-a-date',
      });

      expect(agent.createdAt, isNull);
    });

    test('a bot without an id or a name is not valid', () {
      expect(AgentModel.fromJson(const {'id': 'a'}).isValid, isFalse);
      expect(AgentModel.fromJson(const {'name': 'Bot'}).isValid, isFalse);
    });
  });

  group('serialization', () {
    test('round-trips through toJson and fromJson', () {
      final agent = AgentModel.fromJson(const {
        'id': 'agent_1',
        'name': 'Support Bot',
        'description': 'Answers billing questions',
        'system_prompt': 'Be helpful',
        'avatar_url': 'https://cdn/avatar.png',
        'is_active': true,
        'created_at': '2026-10-19T12:10:00.000Z',
      });

      expect(AgentModel.fromJson(agent.toJson()), agent);
    });

    test('toJson emits snake_case keys the backend uses', () {
      const agent = AgentModel(id: 'a', name: 'Bot', systemPrompt: 'Be nice');

      expect(agent.toJson()['system_prompt'], 'Be nice');
      expect(agent.toJson()['is_active'], isFalse);
    });

    test('copyWith replaces only what it is given', () {
      const agent = AgentModel(id: 'a', name: 'Bot');
      final updated = agent.copyWith(isActive: true);

      expect(updated.isActive, isTrue);
      expect(updated.id, 'a');
      expect(updated.name, 'Bot');
    });
  });
}
