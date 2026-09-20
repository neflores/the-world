import 'package:flutter/material.dart';
import '../model/world_presence.dart';

class WorldToolbar extends StatelessWidget {
  const WorldToolbar({
    required this.simulation,
    required this.status,
    required this.onStatus,
    required this.quiet,
    required this.onQuiet,
    required this.listOnly,
    required this.onListOnly,
    this.onAdd,
    this.onAvatar,
    super.key,
  });
  final bool simulation, quiet, listOnly;
  final SocialStatus status;
  final ValueChanged<SocialStatus>? onStatus;
  final VoidCallback onQuiet, onListOnly;
  final VoidCallback? onAdd;
  final VoidCallback? onAvatar;
  @override
  Widget build(BuildContext context) => Wrap(
    spacing: 12,
    runSpacing: 6,
    crossAxisAlignment: WrapCrossAlignment.center,
    children: [
      const Padding(
        padding: EdgeInsetsDirectional.only(end: 20),
        child: Text(
          'WORLD',
          style: TextStyle(
            fontFamily: 'Georgia',
            color: Color(0xFFE6D4A4),
            fontWeight: FontWeight.bold,
            fontSize: 24,
            letterSpacing: 5,
          ),
        ),
      ),
      if (simulation) const Chip(label: Text('Playground · local data')),
      if (onStatus != null)
        PopupMenuButton<SocialStatus>(
          tooltip: 'Social status',
          initialValue: status,
          onSelected: onStatus,
          itemBuilder: (_) => [
            for (final s in SocialStatus.values)
              PopupMenuItem(value: s, child: Text(s.label)),
          ],
          child: Chip(
            avatar: Icon(
              status == SocialStatus.hidden
                  ? Icons.visibility_off_outlined
                  : Icons.visibility_outlined,
              size: 18,
            ),
            label: Text(status.label),
          ),
        ),
      IconButton.filledTonal(
        tooltip: quiet ? 'Enable animation' : 'Quiet mode',
        onPressed: onQuiet,
        icon: Icon(
          quiet ? Icons.pause_circle_outline : Icons.motion_photos_on_outlined,
        ),
      ),
      IconButton.filledTonal(
        tooltip: listOnly ? 'Show map' : 'List view',
        onPressed: onListOnly,
        icon: Icon(listOnly ? Icons.map_outlined : Icons.view_list_outlined),
      ),
      if (onAdd != null)
        FilledButton.icon(
          key: const ValueKey('add-club'),
          onPressed: onAdd,
          icon: const Icon(Icons.add),
          label: const Text('Add club'),
        ),
      if (onAvatar != null)
        IconButton.filledTonal(
          key: const ValueKey('edit-avatar'),
          tooltip: 'Customize your avatar',
          onPressed: onAvatar,
          icon: const Icon(Icons.face_retouching_natural),
        ),
    ],
  );
}
