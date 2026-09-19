import 'package:flutter_test/flutter_test.dart';
import 'package:world/world.dart';
import 'package:world/world_simulation.dart';
import 'package:world/src/layout/atlas_projection.dart';
import 'package:world/src/layout/city_layout.dart';

void main() {
  test('Regional projection preserves geographical coordinates and aspect', () {
    final projection = AtlasProjection(
      west: 34,
      south: 29,
      east: 36,
      north: 34,
      width: 1000,
    );
    expect(projection.project(34, 34), Offset.zero);
    expect(projection.project(29, 36), Offset(1000, projection.height));
    expect(
      projection.project(32.794, 34.9896).dy,
      lessThan(projection.project(32.0853, 34.7818).dy),
    );
    expect(projection.height, greaterThan(2500));
  });
  test(
    'New clubs preserve direction, existing plots and restart identity',
    () async {
      String? saved;
      final source = SimulationWorldDataSource(
        persist: (s) async {
          saved = s;
        },
      );
      final before = {
        for (final l in source.snapshot.locations) l.id: CityLayout.position(l),
      };
      await source.handle(
        const CreateWorldClub(
          ClubDraft(
            cityId: 'haifa',
            name: 'North Star',
            address: '10 Test Street',
            district: CityDistrict.north,
          ),
        ),
      );
      final added = source.snapshot.locations.last;
      expect(
        CityLayout.position(added).dy,
        lessThan(CityLayout.centralSquare.dy),
      );
      for (final l in source.snapshot.locations.reversed) {
        if (before.containsKey(l.id)) {
          expect(CityLayout.position(l), before[l.id]);
        }
      }
      final restarted = SimulationWorldDataSource(savedState: saved);
      expect(restarted.snapshot.locations.last.id, added.id);
      expect(
        CityLayout.position(restarted.snapshot.locations.last),
        CityLayout.position(added),
      );
      await source.dispose();
      await restarted.dispose();
    },
  );
  test(
    'Full district extends into neighborhoods without dropping clubs or moving plots',
    () async {
      final source = SimulationWorldDataSource();
      for (var i = 0; i < 20; i++) {
        await source.handle(
          CreateWorldClub(
            ClubDraft(
              cityId: 'haifa',
              name: 'Club $i',
              address: '$i Test Street',
              district: CityDistrict.south,
            ),
          ),
        );
      }
      final south = source.snapshot
          .inCity('haifa')
          .where((l) => l.district == CityDistrict.south)
          .toList();
      expect(south.length, 21);
      expect(
        south
            .map((l) => '${l.neighborhood}/${CityLayout.position(l)}')
            .toSet()
            .length,
        21,
      );
      expect(
        south.every(
          (l) => CityLayout.position(l).dy > CityLayout.centralSquare.dy,
        ),
        isTrue,
      );
      await source.dispose();
    },
  );
  test('Save failure is atomic; source recovers for the next action', () async {
    var failSave = true;
    final source = SimulationWorldDataSource(
      persist: (_) async {
        if (failSave) throw StateError('Disk unavailable');
      },
    );
    final count = source.snapshot.locations.length;
    const action = CreateWorldClub(
      ClubDraft(
        cityId: 'haifa',
        name: 'Test Club',
        address: '1 Example Street',
        district: CityDistrict.east,
      ),
    );
    await expectLater(source.handle(action), throwsStateError);
    expect(source.snapshot.locations.length, count);
    failSave = false;
    await source.handle(action);
    expect(source.snapshot.locations.length, count + 1);
    await source.dispose();
  });
  test(
    'Subscribers receive initial state and ordered live replacements',
    () async {
      final source = SimulationWorldDataSource();
      final received = <WorldSnapshot>[];
      final subscription = source.watch().listen(received.add);
      await source.handle(const SetWorldStatus(SocialStatus.hidden));
      await Future<void>.delayed(Duration.zero);
      expect(received.first.status, SocialStatus.browsing);
      expect(received.last.status, SocialStatus.hidden);
      await subscription.cancel();
      await source.dispose();
    },
  );
  test(
    'Missing address, unknown city, and occupied plots are rejected',
    () async {
      final source = SimulationWorldDataSource();
      await expectLater(
        source.handle(
          const CreateWorldClub(
            ClubDraft(
              cityId: 'haifa',
              name: 'X',
              address: '',
              district: CityDistrict.north,
            ),
          ),
        ),
        throwsArgumentError,
      );
      await expectLater(
        source.handle(
          const CreateWorldClub(
            ClubDraft(
              cityId: 'missing',
              name: 'X',
              address: 'Valid address',
              district: CityDistrict.north,
            ),
          ),
        ),
        throwsArgumentError,
      );
      expect(
        () => source.snapshot.copyWith(
          locations: [
            ...source.snapshot.locations,
            source.snapshot.locations.first,
          ],
        ),
        throwsArgumentError,
      );
      await source.dispose();
    },
  );
  test(
    'Hidden presence never renders; recent trace expires after 15 minutes',
    () {
      final now = DateTime(2026, 9, 19, 12);
      expect(
        const WorldPresence(
          id: 'p',
          name: 'P',
          contextId: 'c',
          status: SocialStatus.hidden,
        ).opacityAt(now),
        0,
      );
      expect(
        WorldPresence(
          id: 'p',
          name: 'P',
          contextId: 'c',
          leftAt: now.subtract(const Duration(minutes: 5)),
        ).opacityAt(now),
        closeTo(2 / 3, .001),
      );
      expect(
        WorldPresence(
          id: 'p',
          name: 'P',
          contextId: 'c',
          leftAt: now.subtract(const Duration(minutes: 16)),
        ).opacityAt(now),
        0,
      );
    },
  );
  test('Filled, closed or started games leave public recruitment', () {
    final now = DateTime(2026, 9, 19, 12);
    WorldRecruitment game({
      int occupied = 0,
      bool closed = false,
      Duration delta = const Duration(hours: 1),
    }) => WorldRecruitment(
      id: 'g',
      locationId: 'l',
      title: 'Game',
      master: 'M',
      system: 'D&D',
      startsAt: now.add(delta),
      capacity: 4,
      participantIds: List.generate(occupied, (i) => 'p$i'),
      closed: closed,
    );
    expect(game(occupied: 3).isPublicAt(now), isTrue);
    expect(game(occupied: 4).isPublicAt(now), isFalse);
    expect(game(closed: true).isPublicAt(now), isFalse);
    expect(game(delta: const Duration(hours: -1)).isPublicAt(now), isFalse);
  });
}
