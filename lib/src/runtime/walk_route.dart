import 'package:flutter/painting.dart';

class WalkRoute {
  WalkRoute(this.points) {
    cumulative = [0];
    for (var i = 1; i < points.length; i++) {
      cumulative.add(cumulative.last + (points[i] - points[i - 1]).distance);
    }
  }
  final List<Offset> points;
  late final List<double> cumulative;
  double get length => cumulative.last;
  Offset at(double t) {
    final distance = t.clamp(0, 1) * length;
    for (var i = 1; i < points.length; i++) {
      if (cumulative[i] >= distance) {
        final segment = cumulative[i] - cumulative[i - 1];
        return Offset.lerp(
          points[i - 1],
          points[i],
          segment == 0 ? 0 : (distance - cumulative[i - 1]) / segment,
        )!;
      }
    }
    return points.last;
  }
}
