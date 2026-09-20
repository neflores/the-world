import 'package:flutter/material.dart';
import '../model/world_city.dart';
import '../model/world_location.dart';
import '../model/world_presence.dart';
import '../model/world_snapshot.dart';
import '../runtime/world_runtime.dart';
import '../runtime/world_render_policy.dart';
import '../localization/world_strings.dart';

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
    final strings = WorldLocalization.of(context);
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
              city?.name ?? strings.get('atlas'),
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
                hintText: city == null
                    ? strings.get('findCity')
                    : strings.get('findPlace'),
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
                  label: Text(strings.get('favorites')),
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
                        strings.places(snapshot.inCity(c.id).length),
                      ),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => onCity(c),
                    ),
                  if (cities.isEmpty)
                    ListTile(title: Text(strings.get('noCities'))),
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
                          label: Text(strings.get('centralSquare')),
                          onPressed: () => onLandmark('central-square'),
                        ),
                        ActionChip(
                          label: Text(strings.get('onlinePortal')),
                          onPressed: () => onLandmark('online-portal'),
                        ),
                        ActionChip(
                          label: Text(strings.get('creatorDistrict')),
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
                    ListTile(title: Text(strings.get('noPlaces'))),
                  if (query.isEmpty && !favoritesOnly) ...[
                    const Divider(),
                    ListTile(
                      title: Text(strings.get('aroundSquare')),
                      subtitle: Text(strings.get('presenceNotice')),
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
                        subtitle: Text(strings.status(p.status)),
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
