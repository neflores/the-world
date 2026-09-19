import 'package:flutter/material.dart';
import '../interaction/world_intent.dart';
import '../model/world_presence.dart';

class PersonCard extends StatelessWidget {
  const PersonCard({required this.person, required this.onAction, super.key});
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
      TextButton(
        onPressed: () => onAction(WorldDestination.profile),
        child: const Text('View profile'),
      ),
      if (person.canMessage)
        TextButton(
          onPressed: () => onAction(WorldDestination.message),
          child: const Text('Message'),
        ),
      if (person.canInvite)
        TextButton(
          onPressed: () => onAction(WorldDestination.invite),
          child: const Text('Invite'),
        ),
    ],
  );
}
