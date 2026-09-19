import 'city_district.dart';
import 'world_appearance.dart';

enum WorldLocationKind { physicalClub, community, master, craft }

class WorldLocation {
  const WorldLocation({
    required this.id,
    required this.cityId,
    required this.name,
    required this.district,
    required this.plot,
    this.address = '',
    this.description = '',
    this.kind = WorldLocationKind.physicalClub,
    this.appearance = const WorldAppearance(),
    this.isDemo = false,
    this.isFavorite = false,
  });

  /// Stable ecosystem organization/professional ID. Never a list index or Fluxer ID.
  final String id, cityId, name, address, description;
  final CityDistrict district;

  /// Persisted logical plot in a district. Allocation belongs to the provider.
  /// Extra plots create additional neighborhoods, without relocating existing clubs.
  final int plot;
  final WorldLocationKind kind;
  final WorldAppearance appearance;
  final bool isDemo, isFavorite;
  int get neighborhood => plot ~/ district.plotsPerNeighborhood;

  WorldLocation copyWith({WorldAppearance? appearance, bool? isFavorite}) =>
      WorldLocation(
        id: id,
        cityId: cityId,
        name: name,
        district: district,
        plot: plot,
        address: address,
        description: description,
        kind: kind,
        appearance: appearance ?? this.appearance,
        isDemo: isDemo,
        isFavorite: isFavorite ?? this.isFavorite,
      );

  Map<String, Object> toJson() => {
    'id': id,
    'cityId': cityId,
    'name': name,
    'district': district.name,
    'plot': plot,
    'address': address,
    'description': description,
    'kind': kind.name,
    'appearance': appearance.toJson(),
    'isDemo': isDemo,
    'isFavorite': isFavorite,
  };
  factory WorldLocation.fromJson(Map<String, dynamic> json) => WorldLocation(
    id: json['id'] as String,
    cityId: json['cityId'] as String,
    name: json['name'] as String,
    district: CityDistrict.values.byName(json['district'] as String),
    plot: json['plot'] as int,
    address: json['address'] as String? ?? '',
    description: json['description'] as String? ?? '',
    kind: WorldLocationKind.values.byName(json['kind'] as String),
    appearance: WorldAppearance.fromJson(
      json['appearance'] as Map<String, dynamic>,
    ),
    isDemo: json['isDemo'] as bool? ?? false,
    isFavorite: json['isFavorite'] as bool? ?? false,
  );
}
