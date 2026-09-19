import 'package:flutter/material.dart';
import '../model/world_city.dart';
import '../model/world_presence.dart';
import '../model/world_snapshot.dart';
import '../renderer/atlas_scene.dart';
import '../renderer/scene_pin.dart';
import 'atlas_canvas.dart';

class WorldMapPane extends StatelessWidget {
  const WorldMapPane({
    required this.mapKey,
    required this.scene,
    required this.city,
    required this.snapshot,
    required this.selected,
    required this.quiet,
    required this.onPin,
    required this.onPerson,
    super.key,
  });
  final GlobalKey<AtlasCanvasState> mapKey;
  final AtlasScene scene;
  final WorldCity? city;
  final WorldSnapshot snapshot;
  final String? selected;
  final bool quiet;
  final ValueChanged<ScenePin> onPin;
  final ValueChanged<WorldPresence> onPerson;
  @override
  Widget build(BuildContext context) => ClipRRect(
    borderRadius: BorderRadius.circular(16),
    child: Stack(
      children: [
        Positioned.fill(
          child: AtlasCanvas(
            key: mapKey,
            scene: scene,
            selected: selected,
            onSelect: onPin,
            people: snapshot.people
                .where((p) => p.contextId == city?.id)
                .toList(),
            onPerson: onPerson,
            quiet: quiet,
          ),
        ),
        Positioned(
          top: 12,
          left: 12,
          right: 12,
          child: IgnorePointer(
            child: Align(
              alignment: AlignmentDirectional.topStart,
              child: Card(
                color: const Color(0xE6E8D6AC),
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Text(
                    city == null
                        ? 'ISRAEL · THE ILLUSTRATED ATLAS'
                        : '${city!.name.toUpperCase()} · A CITY OF STORIES',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ),
          ),
        ),
        Positioned(
          right: 10,
          bottom: 25,
          child: Card(
            color: const Color(0xE6E8D6AC),
            child: Column(
              children: [
                IconButton(
                  key: const ValueKey('zoom-in'),
                  tooltip: 'Zoom in',
                  onPressed: () => mapKey.currentState?.zoomBy(1.4),
                  icon: const Icon(Icons.add),
                ),
                IconButton(
                  key: const ValueKey('zoom-out'),
                  tooltip: 'Zoom out',
                  onPressed: () => mapKey.currentState?.zoomBy(1 / 1.4),
                  icon: const Icon(Icons.remove),
                ),
                IconButton(
                  key: const ValueKey('zoom-reset'),
                  tooltip: 'Show whole map',
                  onPressed: () => mapKey.currentState?.reset(),
                  icon: const Icon(Icons.crop_free),
                ),
              ],
            ),
          ),
        ),
        Positioned(
          left: 10,
          bottom: 4,
          right: 10,
          child: IgnorePointer(
            child: Text(
              city == null
                  ? 'Regional geography: Natural Earth'
                  : 'Fictional city · locations preserve direction only',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 10,
                color: Color(0xFFE8D6AC),
                shadows: [Shadow(color: Colors.black, blurRadius: 4)],
              ),
            ),
          ),
        ),
      ],
    ),
  );
}
