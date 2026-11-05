import 'package:zedu/core/core.dart';
import 'package:zedu/features/features.dart';

/// The workspace's channels in the home sidebar. Tapping a row opens it.
class SidebarChannelList extends ConsumerWidget {
  const SidebarChannelList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final channelState = ref.watch(channelProvider);
    final orgId = ref.watch(
      workspaceProvider.select((s) => s.selectedWorkspace?.id),
    );
    final colors = context.colors;
    // Right after a workspace switch, and when the new workspace's load
    // failed, the state still holds the previous workspace's channels. Show
    // only channels of the selected workspace, and none after a failed load.
    // A channel without an organisation id is kept, since we can't tell.
    final allChannels =
        (channelState.hasError
                ? const <Channel>[]
                : channelState.value ?? const <Channel>[])
        .where(
          (c) =>
              (c.organisationId.isEmpty || c.organisationId == orgId),
        )
        .toList();

    final activeChannels = allChannels.where((c) => !c.archived).toList();
    final archivedChannels = allChannels.where((c) => c.archived).toList();

    return ConstrainedBox(
      constraints: const BoxConstraints(maxHeight: 240),
      child: ListView(
        shrinkWrap: true,
        padding: EdgeInsets.zero,
        children: [
          for (final channel in activeChannels)
            _SidebarChannelItem(
              label: channel.name,
              onTap: () => ref
                  .read(activeChatProvider.notifier)
                  .selectChannel(channel.name),
              isArchived: false,
            ),
          if (archivedChannels.isNotEmpty) ...[
            const Divider(height: 24, thickness: 1),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Text(
                'Archived',
                style: TextStyle(
                  color: colors.textHint.withValues(alpha: 0.6),
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            for (final channel in archivedChannels)
              _SidebarChannelItem(
                label: channel.name,
                onTap: () => ref
                    .read(activeChatProvider.notifier)
                    .selectChannel(channel.name),
                isArchived: true,
              ),
          ],
        ],
      ),
    );
  }
}

class _SidebarChannelItem extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final bool isArchived;

  const _SidebarChannelItem({
    required this.label,
    required this.onTap,
    this.isArchived = false,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        child: Row(
          children: [
            Text(
              isArchived ? '📦 #' : '#',
              style: TextStyle(
                color: colors.onPrimary.withValues(alpha: isArchived ? 0.3 : 0.54),
                fontSize: 18,
              ),
            ),
            const SizedBox(width: 12),
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: colors.onPrimary.withValues(alpha: isArchived ? 0.5 : 1.0),
                  fontSize: 15,
                  decoration: isArchived ? TextDecoration.lineThrough : null,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
