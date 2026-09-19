import 'package:flutter/foundation.dart';
import '../model/world_snapshot.dart';

/// Exact value equality for renderer inputs. No presence, favorites, recruitment,
/// status or timestamps participate in static geometry invalidation.
class SceneSignature {
  SceneSignature(WorldSnapshot snapshot, String? cityId, int neighborhood)
    : key = cityId == null ? 'israel' : '$cityId/$neighborhood',
      values = List.unmodifiable(
        cityId == null
            ? (snapshot.cities.toList()..sort((a, b) => a.id.compareTo(b.id)))
                  .map((c) => (c.id, c.name, c.latitude, c.longitude))
            : (snapshot
                      .inCity(cityId)
                      .where((l) => l.neighborhood == neighborhood)
                      .toList()
                    ..sort((a, b) => a.id.compareTo(b.id)))
                  .map((l) => (l.id, l.name, l.district, l.plot, l.appearance)),
      );
  final String key;
  final List<Object> values;
  @override
  bool operator ==(Object other) =>
      other is SceneSignature &&
      key == other.key &&
      listEquals(values, other.values);
  @override
  int get hashCode => Object.hash(key, Object.hashAll(values));
}
