import 'dart:math' as math;
import 'package:flutter/painting.dart';
import '../model/world_appearance.dart';

enum ScenePinKind { city, location, square, favorites, portal, craft }

class ScenePin {
  const ScenePin({
    required this.id,
    required this.name,
    required this.kind,
    required this.anchor,
    required this.position,
    this.height = 150,
    this.appearance = const WorldAppearance(),
  });
  final String id, name;
  final ScenePinKind kind;
  final Offset anchor, position;
  final double height;
  final WorldAppearance appearance;
  Rect get artRect => Rect.fromLTWH(
    position.dx - height / 2,
    position.dy - height,
    height,
    height,
  );
  Rect get labelRect => Rect.fromCenter(
    center: position.translate(0, 13),
    width: math.min(220, math.max(110, name.length * 8.0 + 20)),
    height: 32,
  );
  Rect get hitRect => artRect.expandToInclude(labelRect).inflate(6);
}
