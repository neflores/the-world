import 'world_city.dart';
import 'world_location.dart';
import 'world_presence.dart';
import 'world_recruitment.dart';

class WorldSnapshot {
  WorldSnapshot({
    required List<WorldCity> cities,
    required List<WorldLocation> locations,
    List<WorldPresence> people = const [],
    List<WorldRecruitment> recruitment = const [],
    this.status = SocialStatus.browsing,
    this.isSimulation = false,
  }) : cities = List.unmodifiable(cities),
       locations = List.unmodifiable(locations),
       people = List.unmodifiable(people),
       recruitment = List.unmodifiable(recruitment) {
    final cityIds = this.cities.map((c) => c.id).toSet();
    if (cityIds.length != this.cities.length) {
      throw ArgumentError('Duplicate city IDs');
    }
    final ids = <String>{};
    final plots = <String>{};
    for (final location in this.locations) {
      if (!ids.add(location.id) || location.id.isEmpty) {
        throw ArgumentError('Invalid location ID');
      }
      if (!cityIds.contains(location.cityId)) {
        throw ArgumentError('Unknown location city');
      }
      if (location.plot < 0 ||
          !plots.add(
            '${location.cityId}/${location.district.name}/${location.plot}',
          )) {
        throw ArgumentError('Invalid or occupied district plot');
      }
      if (location.kind == WorldLocationKind.physicalClub &&
          location.address.trim().isEmpty) {
        throw ArgumentError('Physical clubs require an address');
      }
    }
  }
  final List<WorldCity> cities;
  final List<WorldLocation> locations;
  final List<WorldPresence> people;
  final List<WorldRecruitment> recruitment;
  final SocialStatus status;
  final bool isSimulation;
  List<WorldLocation> inCity(String id) =>
      locations.where((l) => l.cityId == id).toList();
  WorldSnapshot copyWith({
    List<WorldLocation>? locations,
    List<WorldPresence>? people,
    List<WorldRecruitment>? recruitment,
    SocialStatus? status,
  }) => WorldSnapshot(
    cities: cities,
    locations: locations ?? this.locations,
    people: people ?? this.people,
    recruitment: recruitment ?? this.recruitment,
    status: status ?? this.status,
    isSimulation: isSimulation,
  );
}
