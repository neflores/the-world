enum WorldHairstyle { short, long }

class WorldAvatar {
  const WorldAvatar({
    this.hairstyle = WorldHairstyle.short,
    this.hairColor = 0xFFB36C35,
    this.eyeColor = 0xFF5C948E,
    this.clothingColor = 0xFF537EA1,
  });
  final WorldHairstyle hairstyle;
  final int hairColor, eyeColor, clothingColor;
  WorldAvatar copyWith({
    WorldHairstyle? hairstyle,
    int? hairColor,
    int? eyeColor,
    int? clothingColor,
  }) => WorldAvatar(
    hairstyle: hairstyle ?? this.hairstyle,
    hairColor: hairColor ?? this.hairColor,
    eyeColor: eyeColor ?? this.eyeColor,
    clothingColor: clothingColor ?? this.clothingColor,
  );
  Map<String, Object> toJson() => {
    'hairstyle': hairstyle.name,
    'hairColor': hairColor,
    'eyeColor': eyeColor,
    'clothingColor': clothingColor,
  };
  factory WorldAvatar.fromJson(Map<String, dynamic> json) => WorldAvatar(
    hairstyle: WorldHairstyle.values.byName(json['hairstyle'] as String),
    hairColor: json['hairColor'] as int,
    eyeColor: json['eyeColor'] as int,
    clothingColor: json['clothingColor'] as int,
  );
  @override
  bool operator ==(Object other) =>
      other is WorldAvatar &&
      hairstyle == other.hairstyle &&
      hairColor == other.hairColor &&
      eyeColor == other.eyeColor &&
      clothingColor == other.clothingColor;
  @override
  int get hashCode =>
      Object.hash(hairstyle, hairColor, eyeColor, clothingColor);
}
