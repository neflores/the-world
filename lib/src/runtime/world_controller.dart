import 'dart:async';
import 'package:flutter/foundation.dart';
import '../data/world_data_source.dart';
import '../model/world_snapshot.dart';
import '../module/world_diagnostic.dart';
import '../module/world_module_state.dart';

class WorldController extends ChangeNotifier {
  WorldController(WorldDataSource source, {this.onDiagnostic}) {
    try {
      _subscription = source.watch().listen(
        (value) {
          if (_disposed) return;
          snapshot = value;
          error = null;
          notifyListeners();
        },
        onError: _failed,
        onDone: () {
          if (!_disposed && snapshot == null) {
            _failed(StateError('Empty source'));
          }
        },
      );
    } catch (error) {
      _failed(error);
    }
  }
  final void Function(WorldDiagnostic)? onDiagnostic;
  StreamSubscription<WorldSnapshot>? _subscription;
  bool _disposed = false;
  WorldSnapshot? snapshot;
  Object? error;
  WorldModuleState get state => error != null
      ? (snapshot == null ? WorldModuleState.error : WorldModuleState.stale)
      : snapshot == null
      ? WorldModuleState.loading
      : snapshot!.cities.isEmpty
      ? WorldModuleState.empty
      : WorldModuleState.ready;
  void _failed(Object value) {
    if (_disposed) return;
    error = value;
    onDiagnostic?.call(
      WorldDiagnostic(WorldDiagnosticCode.source, cause: value),
    );
    notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    unawaited(_subscription?.cancel());
    super.dispose();
  }
}
