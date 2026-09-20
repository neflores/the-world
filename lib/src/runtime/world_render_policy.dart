import '../model/world_presence.dart';
import 'stable_seed.dart';

class WorldRenderPolicy {
  const WorldRenderPolicy({
    this.maxAvatars = 24,
    this.framesPerSecond = 30,
    this.reduceMotion = false,
    this.quiet = false,
    this.simplifiedBackground = false,
  });
  final int maxAvatars, framesPerSecond;
  final bool reduceMotion, quiet, simplifiedBackground;

  /// Deterministic, input-order independent and self-first. Visibility is also
  /// checked here as defense in depth; the host must omit hidden users upstream.
  List<WorldPresence> sample(
    Iterable<WorldPresence> people,
    DateTime now, {
    String? viewerId,
  }) {
    final visible = people.where((p) => p.opacityAt(now) > 0).toList();
    visible.sort((a, b) {
      if (a.id == viewerId && b.id != viewerId) return -1;
      if (b.id == viewerId && a.id != viewerId) return 1;
      final order = stableSeed(a.id).compareTo(stableSeed(b.id));
      return order == 0 ? a.id.compareTo(b.id) : order;
    });
    return visible.take(maxAvatars.clamp(0, 200)).toList(growable: false);
  }
}
