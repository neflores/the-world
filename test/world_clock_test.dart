import 'package:flutter_test/flutter_test.dart';
import 'package:world/world.dart';
import 'package:world/world_simulation.dart';

void main() {
  test(
    'public snapshot strips hidden users; sampling is stable and prioritizes viewer',
    () {
      final now = DateTime.utc(2026, 9, 19);
      final people = [
        for (var i = 0; i < 50; i++)
          WorldPresence(id: '$i', name: 'Player $i', contextId: 'haifa'),
        const WorldPresence(
          id: 'secret',
          name: 'Hidden',
          contextId: 'haifa',
          status: SocialStatus.hidden,
        ),
      ];
      final snapshot = createDemoSnapshot(now: now).copyWith(people: people);
      expect(snapshot.people.any((p) => p.id == 'secret'), isFalse);
      const policy = WorldRenderPolicy(maxAvatars: 14);
      final sampled = policy.sample(people, now, viewerId: '49');
      expect(sampled.length, 14);
      expect(sampled.first.id, '49');
      expect(
        policy.sample(people.reversed, now, viewerId: '49').map((p) => p.id),
        sampled.map((p) => p.id),
      );
    },
  );
  test(
    'manual clock expires recent traces and recruitment at exact boundaries',
    () {
      final clock = ManualWorldClock(DateTime.utc(2026, 9, 19));
      final person = WorldPresence(
        id: 'p',
        name: 'P',
        contextId: 'haifa',
        leftAt: clock.now(),
      );
      expect(person.opacityAt(clock.now()), 1);
      clock.advance(const Duration(minutes: 15));
      expect(person.opacityAt(clock.now()), 0);
      final game = createDemoSnapshot(now: clock.now()).recruitment.first;
      expect(game.isPublicAt(clock.now()), isTrue);
      clock.set(game.startsAt);
      expect(game.isPublicAt(clock.now()), isFalse);
      clock.dispose();
    },
  );
  test(
    'replayed actions generate repeatable IDs and do not collide on restore',
    () async {
      final clock = ManualWorldClock(DateTime.utc(2026, 9, 19));
      final a = SimulationWorldDataSource(clock: clock);
      final b = SimulationWorldDataSource(clock: clock);
      const intent = CreateWorldClub(
        ClubDraft(
          cityId: 'haifa',
          name: 'Replay',
          address: '12 Example Road',
          district: CityDistrict.north,
        ),
      );
      await a.handle(intent);
      await b.handle(intent);
      expect(a.snapshot.locations.last.id, b.snapshot.locations.last.id);
      final restored = SimulationWorldDataSource(
        clock: clock,
        savedState: a.encode(a.snapshot),
      );
      await restored.handle(intent);
      expect(
        restored.snapshot.locations.map((l) => l.id).toSet().length,
        restored.snapshot.locations.length,
      );
      await a.dispose();
      await b.dispose();
      await restored.dispose();
      clock.dispose();
    },
  );
}
