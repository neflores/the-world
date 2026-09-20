import 'package:flutter/material.dart';
import '../interaction/world_intent.dart';
import '../model/world_location.dart';
import '../model/world_snapshot.dart';
import 'recruitment_table.dart';
import '../runtime/world_clock.dart';
import '../runtime/world_runtime.dart';
import '../runtime/world_render_policy.dart';
import '../renderer/atlas_assets.dart';
import '../renderer/npc_layer.dart';
import '../model/world_presence.dart';

class TavernHall extends StatelessWidget {
  const TavernHall({
    required this.location,
    required this.snapshot,
    required this.onAction,
    this.clock = const SystemWorldClock(),
    this.assets,
    this.onPerson,
    super.key,
  });
  final WorldLocation location;
  final WorldSnapshot snapshot;
  final WorldClock clock;
  final AtlasAssets? assets;
  final ValueChanged<WorldPresence>? onPerson;
  final ValueChanged<OpenWorldDestination> onAction;
  @override
  Widget build(BuildContext context) {
    final runtime = WorldRuntimeData.maybeOf(context);
    final visitors = (runtime?.policy ?? const WorldRenderPolicy()).sample(
      snapshot.people.where((p) => p.contextId == location.id),
      runtime?.now ?? clock.now(),
      viewerId: runtime?.viewerId,
    );
    final tables =
        snapshot.recruitment
            .where(
              (g) =>
                  g.locationId == location.id &&
                  !g.isOnline &&
                  g.isPublicAt(
                    WorldRuntimeData.maybeOf(context)?.now ?? clock.now(),
                  ),
            )
            .toList()
          ..sort((a, b) => a.startsAt.compareTo(b.startsAt));
    return Dialog(
      clipBehavior: Clip.antiAlias,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1000, maxHeight: 720),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      '${location.name} · Main hall',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                  IconButton(
                    tooltip: 'Back to city',
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Image.asset(
                      'packages/world/assets/art/tavern_hall.png',
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) =>
                          const ColoredBox(color: Color(0xFF433D2C)),
                    ),
                  ),
                  if (assets != null)
                    for (var i = 0; i < visitors.take(6).length; i++)
                      Positioned(
                        left: 105.0 + (i % 3) * 270,
                        top: 240.0 + (i ~/ 3) * 125,
                        width: 50,
                        height: 75,
                        child: Semantics(
                          button: onPerson != null,
                          label:
                              '${visitors[i].name}, ${visitors[i].status.label}',
                          child: Tooltip(
                            message:
                                '${visitors[i].name} · ${visitors[i].status.label}',
                            child: GestureDetector(
                              onTap: onPerson == null
                                  ? null
                                  : () => onPerson!(visitors[i]),
                              child: CustomPaint(
                                painter: AvatarPainter(
                                  assets!,
                                  i % 2,
                                  0,
                                  i.isOdd,
                                  visitors[i].status,
                                  visitors[i].avatar,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                  Positioned.fill(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Wrap(
                            spacing: 10,
                            runSpacing: 10,
                            alignment: WrapAlignment.center,
                            children: [
                              _sign(
                                'Club sign · Profile',
                                WorldDestination.profile,
                              ),
                              _sign(
                                'Official game board',
                                WorldDestination.recruitment,
                              ),
                              _sign(
                                'Community board',
                                WorldDestination.communityBoard,
                              ),
                            ],
                          ),
                          const SizedBox(height: 140),
                          Wrap(
                            spacing: 24,
                            runSpacing: 22,
                            alignment: WrapAlignment.center,
                            children: [
                              for (final game in tables.take(9))
                                RecruitmentTable(
                                  game: game,
                                  people: snapshot.people,
                                  onTap: () => onAction(
                                    OpenWorldDestination(
                                      WorldDestination.game,
                                      game.id,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          if (tables.isEmpty)
                            const Card(
                              child: Padding(
                                padding: EdgeInsets.all(16),
                                child: Text(
                                  'No open recruitment tables. Visit the board for other games.',
                                ),
                              ),
                            ),
                          if (tables.length > 9)
                            Padding(
                              padding: const EdgeInsets.all(12),
                              child: _sign(
                                'More recruitment',
                                WorldDestination.recruitment,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(12),
              child: Text(
                'Tables show games recruiting players. Seated figures are party projections.',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sign(String label, WorldDestination destination) =>
      FilledButton.tonal(
        onPressed: () =>
            onAction(OpenWorldDestination(destination, location.id)),
        child: Text(label),
      );
}
