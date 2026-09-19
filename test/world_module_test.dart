import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:world/world.dart';
import 'package:world/world_simulation.dart';
import 'package:world/src/runtime/world_controller.dart';

class TestSource implements WorldDataSource {
  final events = StreamController<WorldSnapshot>.broadcast();
  @override
  Stream<WorldSnapshot> watch() => events.stream;
}

void main() {
  test(
    'source failure retains last state; recovery and disposal are safe',
    () async {
      final source = TestSource();
      final diagnostics = <WorldDiagnostic>[];
      final controller = WorldController(source, onDiagnostic: diagnostics.add);
      expect(controller.state, WorldModuleState.loading);
      source.events.addError(StateError('private host detail'));
      await Future<void>.delayed(Duration.zero);
      expect(controller.state, WorldModuleState.error);
      source.events.add(createDemoSnapshot());
      await Future<void>.delayed(Duration.zero);
      expect(controller.state, WorldModuleState.ready);
      final previous = controller.snapshot;
      source.events.addError(StateError('offline'));
      await Future<void>.delayed(Duration.zero);
      expect(controller.state, WorldModuleState.stale);
      expect(controller.snapshot, same(previous));
      expect(diagnostics.length, 2);
      controller.dispose();
      source.events.add(createDemoSnapshot());
      await source.events.close();
    },
  );

  testWidgets(
    'capability changes fail closed even for an older dialog callback',
    (tester) async {
      final source = TestSource();
      final delivered = <WorldIntent>[];
      final diagnostics = <WorldDiagnostic>[];
      final bridge = CallbackWorldHostBridge(
        onIntent: (intent) async => delivered.add(intent),
        onDiagnostic: diagnostics.add,
      );
      Widget app(WorldHostCapabilities capabilities) => MaterialApp(
        home: Scaffold(
          body: WorldModule(
            source: source,
            host: const WorldHostContext(surface: WorldHostSurface.playerApp),
            capabilities: capabilities,
            bridge: bridge,
          ),
        ),
      );
      await tester.pumpWidget(app(const WorldHostCapabilities.playground()));
      final oldAction = tester
          .widget<WorldView>(find.byType(WorldView))
          .onIntent;
      await oldAction(const SetWorldStatus(SocialStatus.hidden));
      expect(delivered.length, 1);
      await tester.pumpWidget(app(const WorldHostCapabilities()));
      await expectLater(
        oldAction(const SetWorldStatus(SocialStatus.hidden)),
        throwsA(isA<WorldActionUnavailable>()),
      );
      expect(delivered.length, 1);
      await tester.pumpWidget(app(const WorldHostCapabilities(canView: false)));
      expect(find.byType(WorldView), findsNothing);
      expect(
        find.text('World is not available in this context.'),
        findsOneWidget,
      );
      await tester.pumpWidget(const SizedBox());
      await source.events.close();
    },
  );
}
