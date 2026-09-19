import 'package:flutter/material.dart';
import 'package:world/world.dart';

/// Explicit host-side demo destinations. No messages, bookings or joins are sent.
Future<void> showPlaygroundDestination(
  BuildContext context,
  WorldSnapshot snapshot,
  OpenWorldDestination intent, {
  WorldClock clock = const SystemWorldClock(),
}) async {
  final location = snapshot.locations
      .where((l) => l.id == intent.entityId)
      .firstOrNull;
  final game = snapshot.recruitment
      .where((g) => g.id == intent.entityId)
      .firstOrNull;
  final games = snapshot.recruitment
      .where(
        (g) =>
            g.isPublicAt(clock.now()) &&
            (intent.destination == WorldDestination.online
                ? g.isOnline
                : !g.isOnline &&
                      (g.locationId == intent.entityId ||
                          snapshot
                              .inCity(intent.entityId)
                              .any((l) => l.id == g.locationId))),
      )
      .toList();
  final title = switch (intent.destination) {
    WorldDestination.profile => location?.name ?? 'Player profile',
    WorldDestination.recruitment => 'Official game board',
    WorldDestination.communityBoard => 'Community board',
    WorldDestination.online => 'Beyond the portal · Online games',
    WorldDestination.craft => 'Craft District',
    WorldDestination.game => game?.title ?? 'Game',
    WorldDestination.message => 'Message',
    WorldDestination.invite => 'Invite',
    WorldDestination.favorites => 'Favorites',
    WorldDestination.rooms => 'Rooms',
  };
  await showDialog<void>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: Text(title),
      content: SizedBox(
        width: 500,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (location != null &&
                  intent.destination == WorldDestination.profile) ...[
                Text(location.description),
                Text(location.address),
                const SizedBox(height: 16),
              ],
              if (game != null) ...[
                Text('${game.system} · ${game.language} · ${game.priceLabel}'),
                Text('Master: ${game.master}'),
                Text('Starts: ${game.startsAt.toLocal()}'),
                Text('${game.openSeats} of ${game.capacity} seats available'),
                Text(game.phrase),
                const SizedBox(height: 16),
              ],
              if (intent.destination == WorldDestination.recruitment ||
                  intent.destination == WorldDestination.online)
                if (games.isEmpty)
                  const Text('No open recruitment right now.')
                else
                  for (final g in games)
                    ListTile(
                      title: Text(g.title),
                      subtitle: Text('${g.system} · ${g.openSeats} open seats'),
                      onTap: () {
                        Navigator.pop(dialogContext);
                        showPlaygroundDestination(
                          context,
                          snapshot,
                          OpenWorldDestination(WorldDestination.game, g.id),
                        );
                      },
                    ),
              if (intent.destination == WorldDestination.craft)
                for (final l
                    in snapshot
                        .inCity(intent.entityId)
                        .where((l) => l.kind == WorldLocationKind.craft))
                  ListTile(title: Text(l.name), subtitle: Text(l.description)),
              if (intent.destination == WorldDestination.communityBoard)
                const Text(
                  'A place for drawings, questions and short local notes. Publishing will be connected through the host app.',
                ),
              const SizedBox(height: 12),
              const Text(
                'Playground preview. Profiles, messaging and joining real games are handled by the connected host app.',
                style: TextStyle(fontSize: 12),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext),
          child: const Text('Close'),
        ),
      ],
    ),
  );
}
