import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:world/world.dart';
import 'package:world/world_simulation.dart';
import 'package:world/src/widgets/club_form.dart';

Future<void> ready(WidgetTester tester) async {
  for (var i = 0; i < 60; i++) {
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 50)),
    );
    await tester.pump();
    if (find.byKey(const ValueKey('atlas-viewer')).evaluate().isNotEmpty) {
      await tester.pump();
      return;
    }
  }
  fail('Artwork did not load');
}

void main() {
  testWidgets(
    'Map and club hit targets follow camera; back navigation and form work',
    (tester) async {
      tester.view.physicalSize = const Size(1280, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final source = SimulationWorldDataSource();
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WorldView(
              source: source,
              onIntent: source.handle,
              canCreateClub: true,
            ),
          ),
        ),
      );
      await ready(tester);
      expect(tester.takeException(), isNull);
      final viewerFinder = find.byKey(const ValueKey('atlas-viewer'));
      var viewer = tester.widget<InteractiveViewer>(viewerFinder);
      final viewport = tester.getSize(viewerFinder);
      // Use the actual transformed target, then pan and zoom it to the viewport center.
      final pinFinder = find.byKey(const ValueKey('pin-haifa'));
      final oldCenter =
          tester.getCenter(pinFinder) - tester.getTopLeft(viewerFinder);
      final target = viewer.transformationController!.toScene(oldCenter);
      final scale = viewer.minScale * 2;
      viewer.transformationController!.value = Matrix4.identity()
        ..translateByDouble(
          viewport.width / 2 - target.dx * scale,
          viewport.height / 2 - target.dy * scale,
          0,
          1,
        )
        ..scaleByDouble(scale, scale, 1, 1);
      await tester.pump();
      await tester.tapAt(
        tester.getTopLeft(viewerFinder) + viewport.center(Offset.zero),
      );
      await tester.pump();
      await tester.pump();
      expect(find.byKey(const ValueKey('map-back')), findsOneWidget);
      expect(find.byKey(const ValueKey('pin-demo-haifa-0')), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('zoom-in')));
      await tester.pump();
      viewer = tester.widget<InteractiveViewer>(viewerFinder);
      final clubFinder = find.byKey(const ValueKey('pin-demo-haifa-0'));
      final clubScene = viewer.transformationController!.toScene(
        tester.getCenter(clubFinder) - tester.getTopLeft(viewerFinder),
      );
      final clubScale = viewer.minScale * 2;
      viewer.transformationController!.value = Matrix4.identity()
        ..translateByDouble(
          viewport.width / 2 - clubScene.dx * clubScale,
          viewport.height / 2 - clubScene.dy * clubScale,
          0,
          1,
        )
        ..scaleByDouble(clubScale, clubScale, 1, 1);
      await tester.pump();
      await tester.tapAt(
        tester.getTopLeft(viewerFinder) + viewport.center(Offset.zero),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text('Enter'), findsOneWidget);
      await tester.tap(find.text('Enter'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text('Official game board'), findsOneWidget);
      await tester.tap(find.byTooltip('Back to city'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      await tester.tap(find.byKey(const ValueKey('add-club')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      await tester.enterText(
        find.byKey(const ValueKey('club-name')),
        'My new club',
      );
      await tester.enterText(
        find.byKey(const ValueKey('club-address')),
        '42 Example Street',
      );
      await tester.tap(find.byKey(const ValueKey('save-club')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(
        source.snapshot.inCity('haifa').any((l) => l.name == 'My new club'),
        isTrue,
      );
      await tester.tap(find.byKey(const ValueKey('map-back')));
      await tester.pump();
      await tester.pump();
      expect(find.byKey(const ValueKey('pin-haifa')), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
      await source.dispose();
    },
  );
  testWidgets('Invalid club form stays open and never dispatches', (
    tester,
  ) async {
    var dispatched = false;
    await tester.pumpWidget(
      MaterialApp(
        home: ClubForm(
          cities: demoCities,
          onIntent: (_) async {
            dispatched = true;
          },
        ),
      ),
    );
    await tester.tap(find.byKey(const ValueKey('save-club')));
    await tester.pump();
    expect(dispatched, isFalse);
    expect(find.text('Enter a club name (1–60 characters).'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
  });
  testWidgets(
    'Narrow large-text layout has a usable list with reduced motion',
    (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final source = SimulationWorldDataSource();
      await tester.pumpWidget(
        MaterialApp(
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context).copyWith(
              disableAnimations: true,
              textScaler: const TextScaler.linear(1.5),
            ),
            child: child!,
          ),
          home: Scaffold(
            body: WorldView(
              source: source,
              onIntent: source.handle,
              canCreateClub: true,
            ),
          ),
        ),
      );
      await ready(tester);
      await tester.tap(find.byTooltip('List view'));
      await tester.pump();
      await tester.tap(find.byKey(const ValueKey('city-haifa')));
      await tester.pump();
      expect(
        find.byKey(const ValueKey('location-demo-haifa-0')),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
      await source.dispose();
    },
  );
}
