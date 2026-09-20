import 'package:flutter/material.dart';
import '../module/world_scope.dart';
import '../runtime/world_runtime.dart';
import '../localization/world_strings.dart';

/// Dialog routes are outside the embedding subtree. Carry World's context over
/// the Navigator boundary, including the same live clock and host identity.
Future<T?> showWorldDialog<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  bool barrierDismissible = true,
}) {
  final runtime = WorldRuntimeData.maybeOf(context);
  final scope = WorldScope.maybeOf(context);
  final localization = WorldLocalization.maybeOf(context);
  return showDialog<T>(
    context: context,
    barrierDismissible: barrierDismissible,
    builder: (_) {
      Widget child = Builder(builder: builder);
      if (runtime != null) {
        child = WorldRuntime(
          clock: runtime.clock,
          policy: runtime.policy,
          viewerId: runtime.viewerId,
          child: child,
        );
      }
      if (scope != null) {
        child = WorldScope(
          host: scope.host,
          capabilities: scope.capabilities,
          bridge: scope.bridge,
          child: child,
        );
      }
      if (localization != null) {
        child = Directionality(
          textDirection: localization.strings.direction,
          child: WorldLocalization(strings: localization.strings, child: child),
        );
      }
      return child;
    },
  );
}
