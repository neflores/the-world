import 'package:shared_preferences/shared_preferences.dart';
import 'package:world/world_simulation.dart';

/// Example-only persistence. The embeddable World package never owns storage.
class PlaygroundStore {
  static const key = 'world.playground.v1';
  static Future<SimulationWorldDataSource> open() async {
    final preferences = SharedPreferencesAsync();
    final saved = await preferences.getString(key);
    return SimulationWorldDataSource(
      savedState: saved,
      persist: (value) => preferences.setString(key, value),
    );
  }
}
