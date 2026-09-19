import 'package:flutter_test/flutter_test.dart';
import 'package:world/world.dart';
import 'package:world/world_simulation.dart';

void main() {
  test('legacy craft/appearance saves migrate without moving locations', () {
    final original = createDemoSnapshot().locations.last;
    final json = original.toJson();
    json['kind'] = 'craft';
    json['appearance'] = {'building': 'cottage', 'plants': true};
    final migrated = WorldLocation.fromJson(json);
    expect(migrated.kind, WorldLocationKind.creator);
    expect(migrated.id, original.id);
    expect(migrated.plot, original.plot);
    expect(migrated.appearance.theme, WorldTheme.hearth);
    expect(migrated.appearance.plants, isTrue);
  });
  test(
    'appearance value roundtrip includes every controlled slot and rejects unknown versions',
    () {
      const value = WorldAppearance(
        theme: WorldTheme.moonlit,
        tier: WorldTier.landmark,
        slots: WorldDecorationSlots(
          lighting: true,
          trophy: true,
          mascot: true,
          wall: true,
          floor: true,
        ),
      );
      expect(WorldAppearance.fromJson(value.toJson()), value);
      expect(
        () =>
            WorldAppearance.fromJson({...value.toJson(), 'schemaVersion': 99}),
        throwsFormatException,
      );
      expect(
        () => WorldSnapshot(cities: [], locations: [], schemaVersion: 99),
        throwsArgumentError,
      );
    },
  );
}
