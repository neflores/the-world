import 'dart:math' as math;
import 'package:flutter/painting.dart';

/// The geographical and hit-test layers share this single projection.
class AtlasProjection {
  AtlasProjection({
    required this.west,
    required this.south,
    required this.east,
    required this.north,
    this.width = 1800,
  });
  final double west, south, east, north, width;
  double _mercator(double lat) =>
      math.log(math.tan(math.pi / 4 + lat * math.pi / 360));
  double get height =>
      width *
      (_mercator(north) - _mercator(south)) /
      ((east - west) * math.pi / 180);
  Size get size => Size(width, height);
  Offset project(double latitude, double longitude) => Offset(
    (longitude - west) / (east - west) * width,
    (_mercator(north) - _mercator(latitude)) /
        (_mercator(north) - _mercator(south)) *
        height,
  );
}
