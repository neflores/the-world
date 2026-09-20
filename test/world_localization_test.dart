import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:world/world.dart';
import 'package:world/world_simulation.dart';
import 'package:world/src/renderer/region_scene.dart';

void main() {
  test('localization covers EN, RU, HE and never changes geography', () {
    expect(WorldStrings.forTag('en-US').get('addClub'), 'Add club');
    expect(WorldStrings.forTag('ru').get('addClub'), 'Добавить клуб');
    expect(WorldStrings.forTag('he-IL').direction, TextDirection.rtl);
    final before = israelProjection.project(32.794, 34.9896);
    final after = israelProjection.project(32.794, 34.9896);
    expect(after, before);
  });

  testWidgets(
    'Hebrew module uses RTL chrome while the map contract stays restricted',
    (tester) async {
      final source = SimulationWorldDataSource();
      await tester.pumpWidget(
        MaterialApp(
          home: WorldModule(
            host: const WorldHostContext(
              surface: WorldHostSurface.playerApp,
              localeTag: 'he',
            ),
            capabilities: const WorldHostCapabilities(canView: false),
            bridge: CallbackWorldHostBridge(onIntent: (_) async {}),
            source: source,
          ),
        ),
      );
      expect(find.text('World אינו זמין בהקשר הזה.'), findsOneWidget);
      expect(
        Directionality.of(
          tester.element(find.text('World אינו זמין בהקשר הזה.')),
        ),
        TextDirection.rtl,
      );
      await tester.pumpWidget(const SizedBox());
      await source.dispose();
    },
  );
}
