import 'package:flutter/material.dart';
import '../model/world_appearance.dart';
import 'atlas_assets.dart';
import 'prop_renderer.dart';

const spriteSources = [
  Rect.fromLTWH(0, 0, 536, 557),
  Rect.fromLTWH(548, 0, 445, 552),
  Rect.fromLTWH(994, 0, 542, 565),
  Rect.fromLTWH(0, 557, 516, 467),
  Rect.fromLTWH(518, 554, 480, 470),
  Rect.fromLTWH(998, 552, 538, 472),
];

void drawSprite(
  Canvas canvas,
  AtlasAssets assets,
  int index,
  Offset base,
  double height,
) {
  final src = spriteSources[index];
  final width = height * src.width / src.height;
  canvas.drawImageRect(
    assets.environments,
    src,
    Rect.fromLTWH(base.dx - width / 2, base.dy - height, width, height),
    Paint()..filterQuality = FilterQuality.medium,
  );
}

/// The only building composition implementation, used in map and previews.
void drawAppearance(
  Canvas canvas,
  AtlasAssets assets,
  WorldAppearance appearance,
  Offset base,
  double height,
) {
  if (appearance.festival) {
    canvas.drawOval(
      Rect.fromCenter(
        center: base.translate(0, -height * .35),
        width: height * 1.2,
        height: height,
      ),
      Paint()
        ..color = const Color(0x44FFC456)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 20),
    );
  }
  canvas.saveLayer(
    Rect.fromCenter(
      center: base.translate(0, -height / 2),
      width: height * 2,
      height: height * 2,
    ),
    Paint()
      ..colorFilter = switch (appearance.theme) {
        WorldTheme.hearth => null,
        WorldTheme.moonlit => const ColorFilter.mode(
          Color(0x555E98C9),
          BlendMode.srcATop,
        ),
        WorldTheme.woodland => const ColorFilter.mode(
          Color(0x44577D44),
          BlendMode.srcATop,
        ),
      },
  );
  if (appearance.tier == WorldTier.stall) {
    drawProp(
      canvas,
      assets,
      WorldProp.stall,
      Rect.fromLTWH(
        base.dx - height * .375,
        base.dy - height,
        height * .75,
        height,
      ),
    );
  } else {
    final scale = switch (appearance.tier) {
      WorldTier.shop => .8,
      WorldTier.landmark => 1.12,
      _ => 1.0,
    };
    drawSprite(canvas, assets, appearance.building.index, base, height * scale);
  }
  canvas.restore();
  void prop(WorldProp type, double x, double y, double scale) => drawProp(
    canvas,
    assets,
    type,
    Rect.fromLTWH(
      base.dx + height * x,
      base.dy + height * y - height * scale,
      height * scale * .75,
      height * scale,
    ),
  );
  if (appearance.slots.lighting) prop(WorldProp.lantern, -.48, .05, .5);
  if (appearance.slots.trophy) prop(WorldProp.trophy, .18, .07, .42);
  if (appearance.slots.mascot) prop(WorldProp.mascot, -.22, .08, .35);
  if (appearance.slots.wall) prop(WorldProp.board, .25, -.15, .5);
  if (appearance.slots.floor) prop(WorldProp.table, -.5, .12, .4);
  if (appearance.plants) {
    drawSprite(canvas, assets, 4, base.translate(height * .32, 3), height * .3);
  }
  if (appearance.banner) {
    final x = base.dx - height * .33, y = base.dy - height * .7;
    canvas.drawLine(
      Offset(x, y - 10),
      Offset(x, base.dy),
      Paint()
        ..color = const Color(0xFF795538)
        ..strokeWidth = 3,
    );
    canvas.drawPath(
      Path()
        ..moveTo(x, y)
        ..lineTo(x + height * .25, y + 5)
        ..lineTo(x + height * .19, y + height * .22)
        ..lineTo(x, y + height * .2)
        ..close(),
      Paint()..color = const Color(0xFF8E4536),
    );
    canvas.drawCircle(
      Offset(x + height * .1, y + height * .1),
      height * .025,
      Paint()..color = const Color(0xFFE9CD7C),
    );
  }
}

void drawTexture(
  Canvas canvas,
  AtlasAssets assets,
  int band,
  Rect rect, {
  double opacity = 1,
}) {
  canvas.drawImageRect(
    assets.terrain,
    Rect.fromLTWH(band * 512.0, 0, 512, 1024),
    rect,
    Paint()
      ..color = Colors.white.withValues(alpha: opacity)
      ..filterQuality = FilterQuality.medium,
  );
}
