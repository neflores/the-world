import 'dart:convert';
import 'dart:ui' as ui;
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';

class GeoPoint {
  const GeoPoint(this.latitude, this.longitude);
  final double latitude, longitude;
}

class AtlasAssets {
  const AtlasAssets(
    this.environments,
    this.adventurers,
    this.terrain,
    this.boundary,
  );
  void dispose() {
    environments.dispose();
    adventurers.dispose();
    terrain.dispose();
  }

  final ui.Image environments, adventurers, terrain;
  final List<List<GeoPoint>> boundary;
  static Future<ByteData> bytes(String path) async {
    try {
      return await rootBundle.load('packages/world/$path');
    } on FlutterError {
      return rootBundle.load(path);
    }
  }

  static Future<String> string(String path) async =>
      utf8.decode((await bytes(path)).buffer.asUint8List());
  static Future<AtlasAssets> load() async {
    Future<ui.Image> image(String file) async {
      final data = await bytes('assets/art/$file.png');
      final codec = await ui.instantiateImageCodec(data.buffer.asUint8List());
      final frame = await codec.getNextFrame();
      codec.dispose();
      return frame.image;
    }

    final images = await Future.wait(
      ['environments', 'adventurers', 'terrain'].map(image),
    );
    final region =
        jsonDecode(await string('assets/geography/region.json'))
            as Map<String, dynamic>;
    final rings = <List<GeoPoint>>[];
    for (final feature in region['features'] as List) {
      final geometry = feature['geometry'];
      final polygons = geometry['type'] == 'Polygon'
          ? [geometry['coordinates']]
          : geometry['coordinates'];
      for (final polygon in polygons) {
        for (final ring in polygon) {
          rings.add([
            for (final point in ring)
              GeoPoint(
                (point[1] as num).toDouble(),
                (point[0] as num).toDouble(),
              ),
          ]);
        }
      }
    }
    return AtlasAssets(images[0], images[1], images[2], rings);
  }
}
