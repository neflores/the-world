enum WorldBuilding { tavern, tower, guildHall, cottage }

/// Host-authorized visual configuration, shared by runtime and editor preview.
/// Prices, ownership and unlock rules belong to the host application.
class WorldAppearance {
  const WorldAppearance({
    this.building = WorldBuilding.tavern,
    this.banner = false,
    this.plants = false,
    this.festival = false,
  });
  final WorldBuilding building;
  final bool banner, plants, festival;

  @override
  bool operator ==(Object other) =>
      other is WorldAppearance &&
      building == other.building &&
      banner == other.banner &&
      plants == other.plants &&
      festival == other.festival;
  @override
  int get hashCode => Object.hash(building, banner, plants, festival);

  WorldAppearance copyWith({
    WorldBuilding? building,
    bool? banner,
    bool? plants,
    bool? festival,
  }) => WorldAppearance(
    building: building ?? this.building,
    banner: banner ?? this.banner,
    plants: plants ?? this.plants,
    festival: festival ?? this.festival,
  );

  Map<String, Object> toJson() => {
    'building': building.name,
    'banner': banner,
    'plants': plants,
    'festival': festival,
  };
  factory WorldAppearance.fromJson(Map<String, dynamic> json) =>
      WorldAppearance(
        building: WorldBuilding.values.byName(json['building'] as String),
        banner: json['banner'] as bool? ?? false,
        plants: json['plants'] as bool? ?? false,
        festival: json['festival'] as bool? ?? false,
      );
}
