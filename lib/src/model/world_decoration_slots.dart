/// Logical slots with controlled positions defined by the shared renderer.
class WorldDecorationSlots {
  const WorldDecorationSlots({
    this.lighting = false,
    this.trophy = false,
    this.mascot = false,
    this.wall = false,
    this.floor = false,
  });
  final bool lighting, trophy, mascot, wall, floor;
  WorldDecorationSlots copyWith({
    bool? lighting,
    bool? trophy,
    bool? mascot,
    bool? wall,
    bool? floor,
  }) => WorldDecorationSlots(
    lighting: lighting ?? this.lighting,
    trophy: trophy ?? this.trophy,
    mascot: mascot ?? this.mascot,
    wall: wall ?? this.wall,
    floor: floor ?? this.floor,
  );
  @override
  bool operator ==(Object other) =>
      other is WorldDecorationSlots &&
      lighting == other.lighting &&
      trophy == other.trophy &&
      mascot == other.mascot &&
      wall == other.wall &&
      floor == other.floor;
  @override
  int get hashCode => Object.hash(lighting, trophy, mascot, wall, floor);
  Map<String, Object> toJson() => {
    'lighting': lighting,
    'trophy': trophy,
    'mascot': mascot,
    'wall': wall,
    'floor': floor,
  };
  factory WorldDecorationSlots.fromJson(Map<String, dynamic> json) =>
      WorldDecorationSlots(
        lighting: json['lighting'] == true,
        trophy: json['trophy'] == true,
        mascot: json['mascot'] == true,
        wall: json['wall'] == true,
        floor: json['floor'] == true,
      );
}
