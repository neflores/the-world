import 'package:flutter/painting.dart';
import '../model/city_district.dart';
import '../model/world_location.dart';

/// Fixed fictional geometry. Real addresses never become scene coordinates.
class CityLayout {
  static const size = Size(1920, 1600);
  static const centralSquare = Offset(960, 675);
  static const favorites = Offset(690, 850);
  static const portal = Offset(1230, 850);
  static const craft = Offset(960, 1040);
  static const _sectors = {
    CityDistrict.northWest: Offset(0, 0),
    CityDistrict.north: Offset(640, 0),
    CityDistrict.northEast: Offset(1280, 0),
    CityDistrict.west: Offset(0, 530),
    CityDistrict.east: Offset(1280, 530),
    CityDistrict.southWest: Offset(0, 1060),
    CityDistrict.south: Offset(640, 1060),
    CityDistrict.southEast: Offset(1280, 1060),
  };
  static Offset position(WorldLocation location) {
    final slot = location.plot % location.district.plotsPerNeighborhood;
    if (location.district == CityDistrict.center) {
      return Offset(850 + slot * 220, 900);
    }
    return _sectors[location.district]! +
        Offset(115 + (slot % 3) * 205, 230 + (slot ~/ 3) * 220);
  }

  /// Streets form separate walk corridors below building entrances.
  static List<List<Offset>> get walkRoutes => [
    for (final y in [270.0, 490.0, 1330.0, 1550.0])
      [Offset(70, y), Offset(1840, y)],
    for (final x in [630.0, 1280.0]) [Offset(x, 80), Offset(x, 1530)],
    [const Offset(70, 1020), const Offset(550, 1020)],
    [const Offset(1380, 1020), const Offset(1840, 1020)],
    [const Offset(780, 715), const Offset(1140, 715)],
  ];
}
