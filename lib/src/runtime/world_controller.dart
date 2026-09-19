import 'dart:async';
import 'package:flutter/foundation.dart';
import '../data/world_data_source.dart';
import '../model/world_snapshot.dart';

class WorldController extends ChangeNotifier {
  WorldController(WorldDataSource source) {
    _subscription = source.watch().listen(
      (value) {
        snapshot = value;
        error = null;
        notifyListeners();
      },
      onError: (Object value) {
        error = value;
        notifyListeners();
      },
    );
  }
  late final StreamSubscription<WorldSnapshot> _subscription;
  WorldSnapshot? snapshot;
  Object? error;
  @override
  void dispose() {
    unawaited(_subscription.cancel());
    super.dispose();
  }
}
