import 'package:flutter/widgets.dart';
import 'world_host_capabilities.dart';
import 'world_host_context.dart';
import 'world_host_bridge.dart';

class WorldScope extends InheritedWidget {
  const WorldScope({
    required this.host,
    required this.capabilities,
    required this.bridge,
    required super.child,
    super.key,
  });
  final WorldHostContext host;
  final WorldHostCapabilities capabilities;
  final WorldHostBridge bridge;
  static WorldScope? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<WorldScope>();
  @override
  bool updateShouldNotify(WorldScope oldWidget) =>
      host != oldWidget.host ||
      capabilities != oldWidget.capabilities ||
      bridge != oldWidget.bridge;
}
