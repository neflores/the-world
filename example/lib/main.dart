import 'dart:async';
import 'package:flutter/material.dart';
import 'package:world/world.dart';
import 'package:world/world_simulation.dart';
import 'playground_store.dart';
import 'playground_destination.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    final source = await PlaygroundStore.open();
    runApp(MainApp(source: source));
  } catch (_) {
    runApp(
      const MaterialApp(
        home: Scaffold(
          body: Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Text(
                'Could not read the saved Playground. Your data has not been overwritten. Please restart and try again.',
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class MainApp extends StatefulWidget {
  const MainApp({required this.source, super.key});
  final SimulationWorldDataSource source;
  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  @override
  void dispose() {
    unawaited(widget.source.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false,
    title: 'World · Playground',
    theme: ThemeData(
      useMaterial3: true,
      fontFamily: 'Georgia',
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF725132),
        surface: const Color(0xFFF0E2C2),
        primary: const Color(0xFF8A5B2D),
      ),
      tooltipTheme: const TooltipThemeData(
        waitDuration: Duration(milliseconds: 400),
      ),
    ),
    home: Builder(
      builder: (context) => Scaffold(
        body: WorldModule(
          source: widget.source,
          clock: widget.source.clock,
          host: const WorldHostContext(
            surface: WorldHostSurface.playground,
            viewerId: 'local-player',
            environment: 'local',
          ),
          capabilities: const WorldHostCapabilities.playground(),
          bridge: CallbackWorldHostBridge(
            onIntent: (intent) async {
              if (intent is OpenWorldDestination) {
                await showPlaygroundDestination(
                  context,
                  widget.source.snapshot,
                  intent,
                  clock: widget.source.clock,
                );
              } else {
                await widget.source.handle(intent);
              }
            },
            onDiagnostic: (event) => debugPrint('World: ${event.code.name}'),
          ),
        ),
      ),
    ),
  );
}
