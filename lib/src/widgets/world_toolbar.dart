import 'package:flutter/material.dart';
import '../model/world_presence.dart';
import '../localization/world_strings.dart';

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
  Widget build(BuildContext context) {
    final strings = WorldLocalization.of(context);
    return Wrap(
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
        if (simulation) Chip(label: Text(strings.get('playground'))),
        if (onStatus != null)
          PopupMenuButton<SocialStatus>(
            tooltip: strings.get('socialStatus'),
            initialValue: status,
            onSelected: onStatus,
            itemBuilder: (_) => [
              for (final s in SocialStatus.values)
                PopupMenuItem(value: s, child: Text(strings.status(s))),
            ],
            child: Chip(
              avatar: Icon(
                status == SocialStatus.hidden
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                size: 18,
              ),
              label: Text(strings.status(status)),
            ),
          ),
        IconButton.filledTonal(
          tooltip: quiet ? strings.get('animate') : strings.get('quiet'),
          onPressed: onQuiet,
          icon: Icon(
            quiet
                ? Icons.pause_circle_outline
                : Icons.motion_photos_on_outlined,
          ),
        ),
        IconButton.filledTonal(
          tooltip: listOnly ? strings.get('map') : strings.get('list'),
          onPressed: onListOnly,
          icon: Icon(listOnly ? Icons.map_outlined : Icons.view_list_outlined),
        ),
        if (onAdd != null)
          FilledButton.icon(
            key: const ValueKey('add-club'),
            onPressed: onAdd,
            icon: const Icon(Icons.add),
            label: Text(strings.get('addClub')),
          ),
        if (onAvatar != null)
          IconButton.filledTonal(
            key: const ValueKey('edit-avatar'),
            tooltip: strings.get('avatar'),
            onPressed: onAvatar,
            icon: const Icon(Icons.face_retouching_natural),
          ),
      ],
    );
  }
}
