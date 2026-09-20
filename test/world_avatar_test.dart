import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:world/world.dart';
import 'package:world/world_simulation.dart';

void main() {
  test(
    'viewer avatar follows context, persists, and hidden status removes projection',
    () async {
      final clock = ManualWorldClock(DateTime.utc(2026, 9, 20));
      final source = SimulationWorldDataSource(clock: clock);
      expect(
        source.snapshot.people.any((p) => p.id == 'local-player'),
        isFalse,
      );

      await source.handle(const SetWorldContext('haifa'));
      expect(
        source.snapshot.people
            .singleWhere((p) => p.id == 'local-player')
            .contextId,
        'haifa',
      );

      const avatar = WorldAvatar(
        hairstyle: WorldHairstyle.long,
        hairColor: 0xFF2F313B,
        eyeColor: 0xFF687DB5,
        clothingColor: 0xFF8B535D,
      );
      await source.handle(const ApplyWorldAvatar(avatar));
      expect(source.snapshot.viewer!.avatar, avatar);
      expect(
        source.snapshot.people
            .singleWhere((p) => p.id == 'local-player')
            .avatar,
        avatar,
      );

      await source.handle(const SetWorldStatus(SocialStatus.hidden));
      expect(
        source.snapshot.people.any((p) => p.id == 'local-player'),
        isFalse,
      );
      await source.handle(const SetWorldStatus(SocialStatus.browsing));
      expect(source.snapshot.people.any((p) => p.id == 'local-player'), isTrue);

      final restored = SimulationWorldDataSource(
        clock: clock,
        savedState: source.encode(source.snapshot),
      );
      expect(restored.snapshot.viewer!.avatar, avatar);
      await expectLater(
        source.handle(const SetWorldContext('unknown')),
        throwsArgumentError,
      );
      expect(source.snapshot.viewer!.contextId, 'haifa');

      await source.dispose();
      await restored.dispose();
      clock.dispose();
    },
  );

  testWidgets('avatar editor returns a typed appearance intent', (
    tester,
  ) async {
    WorldIntent? intent;
    await tester.pumpWidget(
      MaterialApp(
        home: WorldAvatarEditor(
          initial: const WorldAvatar(),
          onIntent: (value) async => intent = value,
        ),
      ),
    );
    await tester.tap(find.text('Long hair'));
    await tester.pump();
    await tester.tap(find.byKey(const ValueKey('save-avatar')));
    await tester.pump();
    expect(intent, isA<ApplyWorldAvatar>());
    expect((intent! as ApplyWorldAvatar).avatar.hairstyle, WorldHairstyle.long);
  });
}
