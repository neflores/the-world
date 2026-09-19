import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import '../layout/city_layout.dart';
import '../model/world_appearance.dart';
import '../model/world_city.dart';
import '../model/world_snapshot.dart';
import '../runtime/walk_route.dart';
import 'appearance_renderer.dart';
import 'atlas_assets.dart';
import 'atlas_scene.dart';
import 'drawing.dart';
import 'scene_pin.dart';

AtlasScene buildCityScene(
  AtlasAssets assets,
  WorldSnapshot snapshot,
  WorldCity city,
  int neighborhood,
) {
  final pins = <ScenePin>[
    const ScenePin(
      id: 'central-square',
      name: 'Central Square',
      kind: ScenePinKind.square,
      anchor: CityLayout.centralSquare,
      position: CityLayout.centralSquare,
      height: 115,
      appearance: WorldAppearance(
        building: WorldBuilding.guildHall,
        banner: true,
      ),
    ),
    const ScenePin(
      id: 'favorites-square',
      name: 'Favorites Square',
      kind: ScenePinKind.favorites,
      anchor: CityLayout.favorites,
      position: CityLayout.favorites,
      height: 115,
      appearance: WorldAppearance(
        building: WorldBuilding.cottage,
        plants: true,
      ),
    ),
    const ScenePin(
      id: 'online-portal',
      name: 'Online Portal',
      kind: ScenePinKind.portal,
      anchor: CityLayout.portal,
      position: CityLayout.portal,
      height: 130,
      appearance: WorldAppearance(
        building: WorldBuilding.tower,
        festival: true,
      ),
    ),
    const ScenePin(
      id: 'craft-district',
      name: 'Craft District',
      kind: ScenePinKind.craft,
      anchor: CityLayout.craft,
      position: CityLayout.craft,
      height: 100,
      appearance: WorldAppearance(
        building: WorldBuilding.cottage,
        banner: true,
      ),
    ),
    for (final location
        in snapshot
            .inCity(city.id)
            .where((l) => l.neighborhood == neighborhood))
      ScenePin(
        id: location.id,
        name: location.name,
        kind: ScenePinKind.location,
        anchor: CityLayout.position(location),
        position: CityLayout.position(location),
        appearance: location.appearance,
      ),
  ];
  final rec = ui.PictureRecorder(), rect = Offset.zero & CityLayout.size;
  final canvas = Canvas(rec);
  drawTexture(canvas, assets, 0, rect);
  canvas.drawRect(rect, Paint()..color = const Color(0x44384627));
  final routes = CityLayout.walkRoutes.map(WalkRoute.new).toList();
  // A fictional connected street plan with explicit walk corridors.
  for (final route in routes) {
    final path = Path()..addPolygon(route.points, false);
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 32
        ..strokeCap = StrokeCap.round
        ..color = const Color(0xAA735A3B),
    );
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 25
        ..strokeCap = StrokeCap.round
        ..color = const Color(0xFFD5BB82),
    );
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 17
        ..strokeCap = StrokeCap.round
        ..color = const Color(0xAAE2CE9D),
    );
  }
  canvas.drawOval(
    const Rect.fromLTWH(660, 530, 600, 520),
    Paint()..color = const Color(0x88736344),
  );
  canvas.drawOval(
    const Rect.fromLTWH(672, 542, 576, 496),
    Paint()..color = const Color(0xAADEC692),
  );
  final rng = math.Random(
    city.id.codeUnits.fold<int>(0, (a, b) => a * 31 + b) & 0x7fffffff,
  );
  for (var i = 0; i < 130; i++) {
    final p = Offset(
      35 + rng.nextDouble() * 1850,
      90 + rng.nextDouble() * 1410,
    );
    if (pins.any((pin) => pin.hitRect.inflate(42).contains(p))) continue;
    if (routes.any(
      (r) => r.points[0].dx == r.points[1].dx
          ? (p.dx - r.points[0].dx).abs() < 55
          : (p.dy - r.points[0].dy).abs() < 60,
    )) {
      continue;
    }
    // Minor homes/trees are scenery; only named buildings are interactive.
    drawSprite(
      canvas,
      assets,
      i % 3 == 0 ? 3 : 4,
      p,
      40 + rng.nextDouble() * 40,
    );
  }
  drawLabel(
    canvas,
    'N O R T H',
    const Offset(960, 65),
    25,
    const Color(0xFFE6D3A2),
  );
  drawLabel(
    canvas,
    'S O U T H',
    const Offset(960, 1580),
    20,
    const Color(0xFFE6D3A2),
  );
  drawCompass(canvas, const Offset(80, 670), 38);
  return AtlasScene(
    key: '${city.id}/$neighborhood',
    size: CityLayout.size,
    assets: assets,
    pins: pins,
    routes: routes,
    picture: rec.endRecording(),
  );
}
