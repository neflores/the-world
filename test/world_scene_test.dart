import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:world/world.dart';
import 'package:world/world_simulation.dart';
import 'package:world/src/runtime/scene_signature.dart';
import 'package:world/src/widgets/atlas_canvas.dart';
import 'world_widget_test.dart' show ready;

void main() {
  test(
    'scene value equality ignores reordered payloads and activity, detects appearance',
    () {
      final initial = createDemoSnapshot(now: DateTime.utc(2026));
      final first = SceneSignature(initial, 'haifa', 0);
      final live = initial.copyWith(
        status: SocialStatus.hidden,
        people: [],
        recruitment: [],
        locations: initial.locations.reversed
            .map((l) => l.copyWith(isFavorite: !l.isFavorite))
            .toList(),
      );
      expect(SceneSignature(live, 'haifa', 0), first);
      final changed = live.copyWith(
        locations: [
          for (final l in live.locations)
            l.id == 'demo-haifa-0'
                ? l.copyWith(
                    appearance: l.appearance.copyWith(
                      banner: !l.appearance.banner,
                    ),
                  )
                : l,
        ],
      );
      expect(SceneSignature(changed, 'haifa', 0), isNot(first));
      expect(
        SceneSignature(changed, null, 0),
        SceneSignature(initial, null, 0),
      );
      expect(
        SceneSignature(changed, 'eilat', 0),
        SceneSignature(initial, 'eilat', 0),
      );
    },
  );
  testWidgets(
    '100 activity replacements retain actual city picture and camera',
    (tester) async {
      tester.view.physicalSize = const Size(1280, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final source = SimulationWorldDataSource();
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WorldView(source: source, onIntent: source.handle),
          ),
        ),
      );
      await ready(tester);
      await tester.tap(find.byKey(const ValueKey('city-haifa')));
      await tester.pump();
      await tester.pump();
      final picture = tester
          .widget<AtlasCanvas>(find.byType(AtlasCanvas))
          .scene
          .picture;
      final camera = tester
          .widget<InteractiveViewer>(find.byType(InteractiveViewer))
          .transformationController!;
      final transform = camera.value.clone();
      for (var i = 0; i < 100; i++) {
        await source.handle(SetWorldStatus(SocialStatus.values[i % 8]));
        await tester.pump();
        expect(
          tester.widget<AtlasCanvas>(find.byType(AtlasCanvas)).scene.picture,
          same(picture),
        );
      }
      expect(camera.value, transform);
      await source.handle(
        const ApplyWorldAppearance(
          'demo-haifa-0',
          WorldAppearance(building: WorldBuilding.tower),
        ),
      );
      await tester.pump();
      expect(
        tester.widget<AtlasCanvas>(find.byType(AtlasCanvas)).scene.picture,
        isNot(same(picture)),
      );
      await tester.pumpWidget(const SizedBox());
      await source.dispose();
    },
  );
}
