import 'package:flutter/foundation.dart';

/// A host may implement a server-aligned clock. Domain code only uses this API.
abstract interface class WorldClock {
  DateTime now();
}

class SystemWorldClock implements WorldClock {
  const SystemWorldClock();
  @override
  DateTime now() => DateTime.now().toUtc();
}

/// Replay/scenario clock. Changes refresh the mounted module immediately.
class ManualWorldClock extends ChangeNotifier implements WorldClock {
  ManualWorldClock(DateTime value) : _value = value.toUtc();
  DateTime _value;
  @override
  DateTime now() => _value;
  void advance(Duration duration) => set(_value.add(duration));
  void set(DateTime value) {
    _value = value.toUtc();
    notifyListeners();
  }
}
