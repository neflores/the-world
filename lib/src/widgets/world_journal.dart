import 'package:flutter/material.dart';
import '../model/world_city.dart';
import '../model/world_location.dart';
import '../model/world_presence.dart';
import '../model/world_snapshot.dart';
import '../runtime/world_runtime.dart';
import '../runtime/world_render_policy.dart';

class WorldJournal extends StatelessWidget {
  const WorldJournal({
    required this.snapshot,
    required this.city,
    required this.search,
    required this.onSearch,
    required this.favoritesOnly,
    required this.onFavorites,
    required this.onCity,
    required this.onLocation,
    required this.onPerson,
    required this.onLandmark,
    super.key,
  });
  final WorldSnapshot snapshot;
  final WorldCity? city;
  final String search;
  final bool favoritesOnly;
  final ValueChanged<String> onSearch, onLandmark;
  final ValueChanged<bool> onFavorites;
  final ValueChanged<WorldCity> onCity;
  final ValueChanged<WorldLocation> onLocation;
  final ValueChanged<WorldPresence> onPerson;
  @override
  Widget build(BuildContext context) {
    final query = search.toLowerCase();
    final locations = city == null
        ? <WorldLocation>[]
        : snapshot
              .inCity(city!.id)
              .where(
                (l) =>
                    (!favoritesOnly || l.isFavorite) &&
                    l.name.toLowerCase().contains(query),
              )
              .toList();
    final cities = snapshot.cities.where(
      (c) => c.name.toLowerCase().contains(query),
    );
    return Material(
      color: const Color(0xFFE8D6AC),
      borderRadius: BorderRadius.circular(14),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Text(
              city?.name ?? 'The atlas of Israel',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
            child: TextField(
              key: ValueKey('search-${city?.id ?? 'region'}'),
              onChanged: onSearch,
              decoration: InputDecoration(
                isDense: true,
                prefixIcon: const Icon(Icons.search),
                hintText: city == null ? 'Find a city' : 'Find a place',
              ),
            ),
          ),
          if (city != null && city!.glory.level > 0)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'City Glory ${city!.glory.level} · ${city!.glory.title}',
                  ),
                  LinearProgressIndicator(
                    value: city!.glory.progress,
                    semanticsLabel: 'City Glory progress',
                  ),
                ],
              ),
            ),
          if (city != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Align(
                alignment: AlignmentDirectional.centerStart,
                child: FilterChip(
                  label: const Text('Favorites'),
                  selected: favoritesOnly,
                  onSelected: onFavorites,
                ),
              ),
            ),
          Expanded(
            child: ListView(
              key: const ValueKey('world-list'),
              padding: const EdgeInsets.all(8),
              children: [
                if (city == null) ...[
                  for (final c in cities)
                    ListTile(
                      key: ValueKey('city-${c.id}'),
                      leading: const Icon(Icons.castle_outlined),
                      title: Text(c.name),
                      subtitle: Text(
                        '${snapshot.inCity(c.id).length} places to discover',
                      ),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => onCity(c),
                    ),
                  if (cities.isEmpty)
                    const ListTile(title: Text('No cities match your search.')),
                ] else ...[
                  const Padding(
                    padding: EdgeInsets.all(8),
                    child: Text(
                      'Fictional streets · real city & directions',
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                  if (query.isEmpty && !favoritesOnly)
                    Wrap(
                      spacing: 4,
                      runSpacing: 4,
                      children: [
                        ActionChip(
                          label: const Text('Central Square'),
                          onPressed: () => onLandmark('central-square'),
                        ),
                        ActionChip(
                          label: const Text('Online Portal'),
                          onPressed: () => onLandmark('online-portal'),
                        ),
                        ActionChip(
                          label: const Text('Craft District'),
                          onPressed: () => onLandmark('craft-district'),
                        ),
                      ],
                    ),
                  for (final l in locations)
                    ListTile(
                      key: ValueKey('location-${l.id}'),
                      leading: Icon(
                        l.isFavorite
                            ? Icons.star_rounded
                            : Icons.cottage_outlined,
                      ),
                      title: Text(l.name),
                      subtitle: Text(
                        '${l.district.label} · ${l.isDemo ? 'Demo' : 'Local club'}',
                      ),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => onLocation(l),
                    ),
                  if (locations.isEmpty)
                    const ListTile(title: Text('No places here yet.')),
                  if (query.isEmpty && !favoritesOnly) ...[
                    const Divider(),
                    const ListTile(
                      title: Text('Around the square'),
                      subtitle: Text('App activity, not physical presence'),
                    ),
                    for (final p
                        in (WorldRuntimeData.maybeOf(context)?.policy ??
                                const WorldRenderPolicy())
                            .sample(
                              snapshot.people.where(
                                (p) =>
                                    p.contextId == city!.id &&
                                    p.opacityAt(
                                          WorldRuntimeData.timeOf(context),
                                        ) >
                                        0,
                              ),
                              WorldRuntimeData.timeOf(context),
                              viewerId: WorldRuntimeData.maybeOf(
                                context,
                              )?.viewerId,
                            ))
                      ListTile(
                        leading: const Icon(Icons.person_outline),
                        title: Text(p.name),
                        subtitle: Text(p.status.label),
                        onTap: () => onPerson(p),
                      ),
                  ],
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
