import 'world_appearance.dart';

/// Host-owned catalog projection. No price, balance, or unlock rule in World.
class WorldAppearanceOption {
  const WorldAppearanceOption({
    required this.id,
    required this.label,
    required this.appearance,
    this.available = false,
  });
  final String id, label;
  final WorldAppearance appearance;
  final bool available;
}
