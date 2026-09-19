import 'city_glory.dart';

class WorldCity {
  const WorldCity({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    this.glory = const CityGlory(),
  });
  final String id, name;
  final double latitude, longitude;
  final CityGlory glory;
}
