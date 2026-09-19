import 'package:flutter/material.dart';
import 'appearance_renderer.dart';
import 'atlas_scene.dart';
import 'drawing.dart';

class PinPainter extends CustomPainter {
  PinPainter(this.scene, this.selected, this.hovered);
  final AtlasScene scene;
  final String? selected, hovered;
  @override
  void paint(Canvas canvas, Size size) {
    for (final pin in scene.pins) {
      if (pin.anchor != pin.position) {
        canvas.drawLine(
          pin.anchor,
          pin.position,
          Paint()
            ..color = const Color(0xFFDBC690)
            ..strokeWidth = 2,
        );
        canvas.drawCircle(
          pin.anchor,
          5,
          Paint()..color = const Color(0xFFDEC887),
        );
        canvas.drawCircle(
          pin.anchor,
          2,
          Paint()..color = const Color(0xFF513C28),
        );
      }
      final active = selected == pin.id || hovered == pin.id;
      if (active) {
        canvas.drawOval(
          pin.artRect.inflate(10),
          Paint()
            ..color = const Color(0x66FFD777)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 18),
        );
      }
      drawAppearance(
        canvas,
        scene.assets,
        pin.appearance,
        pin.position,
        pin.height,
      );
      final rect = pin.labelRect;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          rect.shift(const Offset(2, 3)),
          const Radius.circular(3),
        ),
        Paint()..color = const Color(0x88352A20),
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, const Radius.circular(3)),
        Paint()
          ..color = active ? const Color(0xFFFFE3A0) : const Color(0xFFE5D4AA),
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, const Radius.circular(3)),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = active ? 3 : 1.5
          ..color = const Color(0xFF7E6440),
      );
      drawLabel(
        canvas,
        pin.name.length > 25 ? '${pin.name.substring(0, 23)}…' : pin.name,
        rect.center,
        15,
        const Color(0xFF463524),
      );
    }
  }

  @override
  bool shouldRepaint(PinPainter old) =>
      old.scene != scene || old.selected != selected || old.hovered != hovered;
}
