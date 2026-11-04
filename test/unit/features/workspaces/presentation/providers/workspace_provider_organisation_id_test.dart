import '../../../../../helpers/helpers.dart';
import 'package:zedu/core/core.dart';
import 'package:zedu/features/features.dart';

class MockApiBaseService extends Mock implements ApiBaseService {}

void main() {
  group('WorkspaceNotifier organisation ids', () {
    late MockApiBaseService mockApi;

    setUp(() {
      mockApi = MockApiBaseService();
      locator.registerSingleton<ApiBaseService>(mockApi);
      locator.registerSingleton<AppConfig>(
        AppConfig(apiBaseUrl: 'https://api.example.com', usesMockData: false),
      );
    });

    tearDown(() async {
      await locator.reset();
    });

    Future<WorkspaceState> load(
      ProviderContainer container,
      List<Map<String, dynamic>> orgs,
    ) async {
      when(
        () => mockApi.get<Map<String, dynamic>>(path: '/users/organisations'),
      ).thenAnswer(
        (_) async => ApiResponseModel(data: {'data': orgs}, statusCode: 200),
      );
      container.read(workspaceProvider);
      await container.read(workspaceProvider.notifier).fetchWorkspaces();
      return container.read(workspaceProvider);
    }

    test(
      'two organisations without an id no longer collapse into one',
      () async {
        final container = ProviderContainer();
        addTearDown(container.dispose);

        final state = await load(container, [
          {'name': 'No Id One'},
          {'name': 'No Id Two'},
        ]);

        // Previously both became id '1', the second was dropped by
        // addWorkspace, and switching to it did nothing.
        expect(state.workspaces, isEmpty);
        expect(state.selectedWorkspace, isNull);
      },
    );

    test('an organisation is never given the invented id 1', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final state = await load(container, [
        {'name': 'No Id'},
        {'id': 'org-9', 'name': 'Has Id'},
      ]);

      expect(state.workspaces.map((w) => w.id), ['org-9']);
      expect(state.workspaces.map((w) => w.name), ['Has Id']);
      expect(state.selectedWorkspace?.id, 'org-9');
    });

    test(
      'ids are kept as returned, so each organisation stays selectable',
      () async {
        final container = ProviderContainer();
        addTearDown(container.dispose);

        final state = await load(container, [
          {'id': 'org-1', 'name': 'One'},
          {'id': 'org-2', 'name': 'Two'},
        ]);

        expect(state.workspaces.map((w) => w.id), ['org-1', 'org-2']);
        expect(state.selectedWorkspace?.id, 'org-1');
      },
    );

    test('a blank id is treated as missing', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final state = await load(container, [
        {'id': '   ', 'name': 'Blank Id'},
      ]);

      expect(state.workspaces, isEmpty);
    });

    test('numeric ids are kept rather than discarded', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final state = await load(container, [
        {'id': 42, 'name': 'Numeric'},
      ]);

      expect(state.workspaces.map((w) => w.id), ['42']);
    });

    test('duplicate ids are still listed once', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final state = await load(container, [
        {'id': 'org-1', 'name': 'One'},
        {'id': 'org-1', 'name': 'One again'},
      ]);

      expect(state.workspaces, hasLength(1));
    });
  });
}
