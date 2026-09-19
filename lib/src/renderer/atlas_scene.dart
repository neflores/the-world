import 'dart:ui' as ui;
import 'package:flutter/painting.dart';
import '../runtime/walk_route.dart';
import 'atlas_assets.dart';
import 'scene_pin.dart';

class AtlasScene {
  const AtlasScene({
    required this.key,
    required this.size,
    required this.assets,
    required this.pins,
    required this.picture,
    this.routes = const [],
  });
  final String key;
  final Size size;
  final AtlasAssets assets;
  final List<ScenePin> pins;
  final ui.Picture picture;
  final List<WalkRoute> routes;
  void dispose() => picture.dispose();
}
