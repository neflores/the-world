import 'package:flutter/material.dart';
import '../interaction/world_intent.dart';
import '../model/world_presence.dart';
import '../module/world_host_capabilities.dart';

class PersonCard extends StatelessWidget {
  const PersonCard({
    required this.person,
    required this.onAction,
    this.capabilities = const WorldHostCapabilities(),
    super.key,
  });
  final WorldHostCapabilities capabilities;
  final WorldPresence person;
  final ValueChanged<WorldDestination> onAction;
  @override
  Widget build(BuildContext context) => AlertDialog(
    title: Text(person.name),
    content: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(person.status.label),
        if (person.publicHeadline.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(person.publicHeadline),
        ],
        const SizedBox(height: 12),
        Text(
          person.leftAt == null
              ? 'Active in this app context'
              : 'Recently active in this app context',
        ),
        const Text(
          'This does not indicate their physical location.',
          style: TextStyle(fontSize: 12),
        ),
      ],
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('Close'),
      ),
      if (capabilities.canNavigate && capabilities.canOpenProfiles)
        TextButton(
          onPressed: () => onAction(WorldDestination.profile),
          child: const Text('View profile'),
        ),
      if (person.canMessage &&
          capabilities.canNavigate &&
          capabilities.canOpenMessages)
        TextButton(
          onPressed: () => onAction(WorldDestination.message),
          child: const Text('Message'),
        ),
      if (person.canInvite &&
          capabilities.canNavigate &&
          capabilities.canInvite)
        TextButton(
          onPressed: () => onAction(WorldDestination.invite),
          child: const Text('Invite'),
        ),
    ],
  );
}
