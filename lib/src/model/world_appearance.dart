import 'world_decoration_slots.dart';

enum WorldBuilding { tavern, tower, guildHall, cottage }

enum WorldTheme { hearth, moonlit, woodland }

enum WorldTier { stall, shop, workshop, landmark }

/// Host-authorized visual configuration, shared by runtime and editor preview.
/// Prices, ownership and unlock rules belong to the host application.
class WorldAppearance {
  const WorldAppearance({
    this.building = WorldBuilding.tavern,
    this.banner = false,
    this.plants = false,
    this.festival = false,
    this.theme = WorldTheme.hearth,
    this.tier = WorldTier.workshop,
    this.slots = const WorldDecorationSlots(),
  });
  final WorldBuilding building;
  final bool banner, plants, festival;
  final WorldTheme theme;
  final WorldTier tier;
  final WorldDecorationSlots slots;

  @override
  bool operator ==(Object other) =>
      other is WorldAppearance &&
      building == other.building &&
      banner == other.banner &&
      plants == other.plants &&
      festival == other.festival &&
      theme == other.theme &&
      tier == other.tier &&
      slots == other.slots;
  @override
  int get hashCode =>
      Object.hash(building, banner, plants, festival, theme, tier, slots);

  WorldAppearance copyWith({
    WorldBuilding? building,
    bool? banner,
    bool? plants,
    bool? festival,
    WorldTheme? theme,
    WorldTier? tier,
    WorldDecorationSlots? slots,
  }) => WorldAppearance(
    building: building ?? this.building,
    banner: banner ?? this.banner,
    plants: plants ?? this.plants,
    festival: festival ?? this.festival,
    theme: theme ?? this.theme,
    tier: tier ?? this.tier,
    slots: slots ?? this.slots,
  );

  Map<String, Object> toJson() => {
    'building': building.name,
    'banner': banner,
    'plants': plants,
    'festival': festival,
    'schemaVersion': 2,
    'theme': theme.name,
    'tier': tier.name,
    'slots': slots.toJson(),
  };
  factory WorldAppearance.fromJson(Map<String, dynamic> json) {
    final version = json['schemaVersion'] ?? 1;
    if (version != 1 && version != 2) {
      throw const FormatException('Unsupported appearance schema');
    }
    return WorldAppearance(
      building: WorldBuilding.values.byName(json['building'] as String),
      banner: json['banner'] as bool? ?? false,
      plants: json['plants'] as bool? ?? false,
      festival: json['festival'] as bool? ?? false,
      theme: WorldTheme.values.byName(json['theme'] as String? ?? 'hearth'),
      tier: WorldTier.values.byName(json['tier'] as String? ?? 'workshop'),
      slots: WorldDecorationSlots.fromJson(
        json['slots'] as Map<String, dynamic>? ?? {},
      ),
    );
  }
}
