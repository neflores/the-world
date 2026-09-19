import '../interaction/world_intent.dart';
import 'world_diagnostic.dart';

abstract interface class WorldHostBridge {
  Future<void> dispatch(WorldIntent intent);
  void diagnostic(WorldDiagnostic event);
}

class CallbackWorldHostBridge implements WorldHostBridge {
  const CallbackWorldHostBridge({required this.onIntent, this.onDiagnostic});
  final WorldIntentHandler onIntent;
  final void Function(WorldDiagnostic)? onDiagnostic;
  @override
  Future<void> dispatch(WorldIntent intent) => onIntent(intent);
  @override
  void diagnostic(WorldDiagnostic event) => onDiagnostic?.call(event);
}

class WorldActionUnavailable implements Exception {
  const WorldActionUnavailable();
}
