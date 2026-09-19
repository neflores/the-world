import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import '../layout/atlas_projection.dart';
import '../model/world_appearance.dart';
import '../model/world_snapshot.dart';
import 'appearance_renderer.dart';
import 'atlas_assets.dart';
import 'atlas_scene.dart';
import 'drawing.dart';
import 'scene_pin.dart';

final israelProjection = AtlasProjection(
  west: 33.4,
  south: 29.35,
  east: 36.05,
  north: 33.4,
  width: 1100,
);
const _offsets = {
  'haifa': Offset(-95, -24),
  'netanya': Offset(-164, 0),
  'tel-aviv': Offset(-168, 45),
  'ramat-gan': Offset(174, 42),
  'petah-tikva': Offset(244, -95),
  'rishon-lezion': Offset(-176, 110),
  'rehovot': Offset(150, 176),
  'jerusalem': Offset(122, 52),
  'ashdod': Offset(-156, 175),
  'modiin': Offset(226, 112),
  'beer-sheva': Offset(74, 30),
  'eilat': Offset(84, 0),
};
AtlasScene buildRegionScene(AtlasAssets assets, WorldSnapshot snapshot) {
  final projection = israelProjection;
  final pins = [
    for (final city in snapshot.cities)
      ScenePin(
        id: city.id,
        name: city.name,
        kind: ScenePinKind.city,
        anchor: projection.project(city.latitude, city.longitude),
        position:
            projection.project(city.latitude, city.longitude) +
            (_offsets[city.id] ?? Offset.zero),
        height: city.id == 'jerusalem' ? 114 : 92,
        appearance: WorldAppearance(
          building: city.id == 'jerusalem'
              ? WorldBuilding.guildHall
              : WorldBuilding.tavern,
        ),
      ),
  ];
  final boundary = Path()..fillType = PathFillType.evenOdd;
  for (final ring in assets.boundary) {
    boundary.addPolygon(
      ring.map((p) => projection.project(p.latitude, p.longitude)).toList(),
      true,
    );
  }
  final rec = ui.PictureRecorder();
  final canvas = Canvas(rec), rect = Offset.zero & projection.size;
  drawTexture(canvas, assets, 2, rect);
  canvas.drawRect(rect, Paint()..color = const Color(0x5536504D));
  canvas.drawPath(
    boundary.shift(const Offset(10, 14)),
    Paint()..color = const Color(0xCC283832),
  );
  canvas.drawPath(
    boundary,
    Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10
      ..color = const Color(0xBBE2CF91),
  );
  canvas.save();
  canvas.clipPath(boundary);
  drawTexture(canvas, assets, 1, rect);
  canvas.saveLayer(rect, Paint());
  drawTexture(canvas, assets, 0, rect);
  canvas.drawRect(
    rect,
    Paint()
      ..blendMode = BlendMode.dstIn
      ..shader = ui.Gradient.linear(
        Offset.zero,
        Offset(0, projection.height),
        [Colors.white, Colors.white, Colors.transparent],
        [0, .38, .72],
      ),
  );
  canvas.restore();
  final rng = math.Random(281);
  for (var i = 0; i < 150; i++) {
    final lat = 29.6 + rng.nextDouble() * 3.65,
        lon = 34.28 + rng.nextDouble() * 1.48;
    final p = projection.project(lat, lon);
    if (!boundary.contains(p) ||
        pins.any((pin) => pin.hitRect.inflate(15).contains(p))) {
      continue;
    }
    drawSprite(
      canvas,
      assets,
      lat > 31.5 ? 4 : 5,
      p,
      38 + rng.nextDouble() * 40,
    );
  }
  canvas.restore();
  canvas.drawPath(
    boundary,
    Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..color = const Color(0xAA524A2C),
  );
  drawLabel(
    canvas,
    'M E D I T E R R A N E A N',
    const Offset(100, 360),
    22,
    const Color(0xA6E4D7A9),
    angle: -math.pi / 2,
  );
  drawLabel(
    canvas,
    'N E G E V',
    projection.project(30.65, 34.85),
    28,
    const Color(0xA064522F),
  );
  drawLabel(
    canvas,
    'G A L I L E E',
    projection.project(32.94, 35.32),
    17,
    const Color(0xBBE9DABC),
  );
  drawCompass(canvas, Offset(210, projection.height - 320), 85);
  return AtlasScene(
    key: 'israel',
    size: projection.size,
    assets: assets,
    pins: pins,
    picture: rec.endRecording(),
  );
}
