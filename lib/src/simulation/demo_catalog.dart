import '../model/city_district.dart';
import '../model/world_appearance.dart';
import '../model/world_city.dart';
import '../runtime/world_clock.dart';
import '../model/world_location.dart';
import '../model/world_presence.dart';
import '../model/world_recruitment.dart';
import '../model/world_snapshot.dart';

const demoCities = [
  WorldCity(id: 'haifa', name: 'Haifa', latitude: 32.794, longitude: 34.9896),
  WorldCity(
    id: 'netanya',
    name: 'Netanya',
    latitude: 32.3215,
    longitude: 34.8532,
  ),
  WorldCity(
    id: 'tel-aviv',
    name: 'Tel Aviv',
    latitude: 32.0853,
    longitude: 34.7818,
  ),
  WorldCity(
    id: 'ramat-gan',
    name: 'Ramat Gan',
    latitude: 32.068,
    longitude: 34.8248,
  ),
  WorldCity(
    id: 'petah-tikva',
    name: 'Petah Tikva',
    latitude: 32.0871,
    longitude: 34.8875,
  ),
  WorldCity(
    id: 'rishon-lezion',
    name: 'Rishon LeZion',
    latitude: 31.973,
    longitude: 34.7925,
  ),
  WorldCity(
    id: 'rehovot',
    name: 'Rehovot',
    latitude: 31.8928,
    longitude: 34.8113,
  ),
  WorldCity(
    id: 'jerusalem',
    name: 'Jerusalem',
    latitude: 31.7683,
    longitude: 35.2137,
  ),
  WorldCity(
    id: 'ashdod',
    name: 'Ashdod',
    latitude: 31.8044,
    longitude: 34.6553,
  ),
  WorldCity(
    id: 'modiin',
    name: "Modi'in",
    latitude: 31.8969,
    longitude: 35.0104,
  ),
  WorldCity(
    id: 'beer-sheva',
    name: 'Beer Sheva',
    latitude: 31.2529,
    longitude: 34.7915,
  ),
  WorldCity(id: 'eilat', name: 'Eilat', latitude: 29.5577, longitude: 34.9519),
];

WorldSnapshot createDemoSnapshot({DateTime? now}) {
  final time = now ?? const SystemWorldClock().now();
  final locations = <WorldLocation>[];
  for (final city in demoCities) {
    for (var i = 0; i < 5; i++) {
      locations.add(
        WorldLocation(
          id: 'demo-${city.id}-$i',
          cityId: city.id,
          name: [
            'The Amber Lantern',
            'Moonwatch Guild',
            'The Copper Dragon',
            'Mira’s Workshop',
            'Dice & Ink',
          ][i],
          district: [
            CityDistrict.north,
            CityDistrict.east,
            CityDistrict.south,
            CityDistrict.west,
            CityDistrict.northWest,
          ][i],
          plot: i == 0 ? 1 : 0,
          kind: [
            WorldLocationKind.physicalClub,
            WorldLocationKind.community,
            WorldLocationKind.physicalClub,
            WorldLocationKind.master,
            WorldLocationKind.craft,
          ][i],
          address: i == 0 || i == 2 ? 'Demo address — not a real venue' : '',
          description: [
            'A warm welcome for first-time adventurers.',
            'Stories, friendships and a place at the table.',
            'Campaigns by the hearth.',
            'A master gathering a party for the next adventure.',
            'Miniatures, maps and handmade dice.',
          ][i],
          appearance: WorldAppearance(
            building: WorldBuilding.values[i % 4],
            plants: i.isEven,
            banner: i == 1,
            festival: i == 0,
          ),
          isDemo: true,
          isFavorite: i == 0,
        ),
      );
    }
  }
  return WorldSnapshot(
    cities: demoCities,
    locations: locations,
    isSimulation: true,
    people: [
      for (final city in demoCities)
        for (var i = 0; i < 8; i++)
          WorldPresence(
            id: 'demo-person-${city.id}-$i',
            name: [
              'Rowan',
              'Mira',
              'Noa',
              'Ari',
              'Tamar',
              'Kai',
              'Sam',
              'Eli',
            ][i],
            contextId: city.id,
            status: SocialStatus.values[i % 7],
            canMessage: true,
            leftAt: i == 7 ? time.subtract(const Duration(minutes: 5)) : null,
          ),
    ],
    recruitment: [
      for (final city in demoCities)
        for (var i = 0; i < 3; i++)
          WorldRecruitment(
            id: 'demo-game-${city.id}-$i',
            locationId: 'demo-${city.id}-${i == 0 ? 0 : 3}',
            title: [
              'Lanterns of the Lost Coast',
              'A Door beneath the Library',
              'Cloudbound',
            ][i],
            master: 'Mira',
            system: i == 1 ? 'Pathfinder 2e' : 'D&D 5e',
            startsAt: time.add(Duration(days: 1 + i, hours: 2)),
            capacity: 5,
            participantIds: [
              'demo-person-${city.id}-0',
              'demo-person-${city.id}-2',
            ],
            phrase: 'Curious explorers welcome. Let’s tell a story.',
            isOnline: i == 2,
          ),
    ],
  );
}
