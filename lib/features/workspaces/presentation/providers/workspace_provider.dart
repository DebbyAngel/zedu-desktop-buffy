import 'package:zedu/core/core.dart';

import '../../data/models/workspace.dart';
import 'workspace_state.dart';

class WorkspaceNotifier extends Notifier<WorkspaceState> {
  static const loadErrorMessage = "Couldn't load your organisations";

  @override
  WorkspaceState build() {
    Future.microtask(fetchWorkspaces);
    return const WorkspaceState(isLoading: true);
  }

  Future<void> fetchWorkspaces() async {
    if (locator<AppConfig>().usesMockData) {
      state = _mockState();
      return;
    }

    state = WorkspaceState(
      workspaces: state.workspaces,
      selectedWorkspace: state.selectedWorkspace,
      isLoading: true,
    );
    try {
      final api = locator<ApiBaseService>();
      final response = await api.get<Map<String, dynamic>>(
        path: '/users/organisations',
      );
      final data = response.data['data'] as List<dynamic>? ?? [];

      final List<Workspace> workspaces = [];
      for (var item in data) {
        if (item is! Map<String, dynamic>) continue;

        final id = _parseOrganisationId(item['id']);
        if (id == null) {
          // Never invent an id. Defaulting every organisation that lacks one
          // to '1' collapsed the whole list to a single workspace: the second
          // was dropped by addWorkspace's de-duplication and could not be
          // selected, because switchWorkspace returns early when the id already
          // matches. Skipping it keeps the list honest instead.
          AppLogger.w(
            'Skipping organisation without an id (name: ${item['name']})',
            tag: 'WorkspaceNotifier',
          );
          continue;
        }
        if (workspaces.any((workspace) => workspace.id == id)) continue;

        workspaces.add(
          Workspace(
            id: id,
            name: item['name'] as String? ?? 'Workspace',
            avatar: item['logo_url'] as String? ?? '',
            channelsCount: (item['channels_count'] as num?)?.toInt() ?? 0,
          ),
        );
      }

      // Keep the current selection if it's still in the list (e.g. an org
      // created while this request was in flight).
      final previousId = state.selectedWorkspace?.id;
      final selected = workspaces.isEmpty
          ? null
          : workspaces.firstWhere(
              (ws) => ws.id == previousId,
              orElse: () => workspaces.first,
            );

      state = WorkspaceState(
        workspaces: workspaces,
        selectedWorkspace: selected,
      );
    } catch (e, stackTrace) {
      AppLogger.e(
        'Failed to load organisations',
        tag: 'WorkspaceNotifier',
        error: e,
        stackTrace: stackTrace,
      );
      state = const WorkspaceState(errorMessage: loadErrorMessage);
    }
  }

  /// Reads an organisation's id exactly as the API returned it, without
  /// substituting a default. Returns null when the payload carries no usable
  /// id, so the caller can leave that organisation out rather than invent one.
  static String? _parseOrganisationId(Object? value) {
    if (value is String) {
      final trimmed = value.trim();
      return trimmed.isEmpty ? null : trimmed;
    }
    if (value is num) return value.toString();
    return null;
  }

  // Demo organisations, only used when the app runs with USE_MOCK_DATA.
  WorkspaceState _mockState() {
    final workspaces = [
      const Workspace(
        id: '1',
        name: 'HNG Workspace',
        avatar: '',
        unreadCount: 1351,
        channelsCount: 1351,
      ),
      const Workspace(
        id: '2',
        name: 'TeamFlow Collective',
        avatar: '',
        unreadCount: 15,
        channelsCount: 42,
      ),
      const Workspace(
        id: '3',
        name: 'Coffee & Code House',
        avatar: '',
        unreadCount: 0,
        channelsCount: 12,
      ),
      const Workspace(
        id: '4',
        name: 'ConnectHub',
        avatar: '',
        unreadCount: 3,
        channelsCount: 89,
      ),
    ];

    return WorkspaceState(
      workspaces: workspaces,
      selectedWorkspace: workspaces.first,
    );
  }

  void addWorkspace(Workspace workspace, {bool switchTo = true}) {
    final current = state.workspaces;
    if (current.any((w) => w.id == workspace.id)) return;
    final updated = [...current, workspace];
    state = state.copyWith(
      workspaces: updated,
      selectedWorkspace: switchTo ? workspace : state.selectedWorkspace,
    );
  }

  Future<void> switchWorkspace(Workspace workspace) async {
    if (state.selectedWorkspace?.id == workspace.id) return;

    state = state.copyWith(isLoading: true);

    await Future<void>.delayed(const Duration(milliseconds: 300));

    state = state.copyWith(selectedWorkspace: workspace, isLoading: false);
  }

  void removeWorkspace(String id) {
    final updatedWorkspaces = state.workspaces
        .where((w) => w.id != id)
        .toList();
    Workspace? nextSelected = state.selectedWorkspace;
    if (state.selectedWorkspace?.id == id) {
      nextSelected = updatedWorkspaces.isNotEmpty
          ? updatedWorkspaces.first
          : null;
    }
    state = state.copyWith(
      workspaces: updatedWorkspaces,
      selectedWorkspace: nextSelected,
    );
  }
}

final workspaceProvider = NotifierProvider<WorkspaceNotifier, WorkspaceState>(
  WorkspaceNotifier.new,
);
