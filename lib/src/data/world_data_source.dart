import '../model/world_snapshot.dart';

/// Each subscription must emit the current snapshot followed by replacements,
/// in order, without a gap between initial state and live updates.
/// Transport DTOs, credentials, reconnection and permissions remain host-owned.
abstract interface class WorldDataSource {
  Stream<WorldSnapshot> watch();
}
