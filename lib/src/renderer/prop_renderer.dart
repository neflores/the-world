import 'package:flutter/painting.dart';
import 'atlas_assets.dart';

enum WorldProp { table, board, stall, portal, lantern, trophy, chair, mascot }

void drawProp(Canvas canvas, AtlasAssets assets, WorldProp prop, Rect target) {
  canvas.drawImageRect(
    assets.props,
    Rect.fromLTWH((prop.index % 4) * 384, (prop.index ~/ 4) * 512, 384, 512),
    target,
    Paint()..filterQuality = FilterQuality.medium,
  );
}
