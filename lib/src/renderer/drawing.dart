import 'dart:math' as math;
import 'package:flutter/material.dart';

void drawLabel(
  Canvas canvas,
  String text,
  Offset point,
  double fontSize,
  Color color, {
  double angle = 0,
}) {
  final painter = TextPainter(
    text: TextSpan(
      text: text,
      style: TextStyle(
        fontFamily: 'Georgia',
        fontSize: fontSize,
        color: color,
        fontWeight: FontWeight.w600,
      ),
    ),
    textDirection: TextDirection.ltr,
  )..layout();
  canvas.save();
  canvas.translate(point.dx, point.dy);
  canvas.rotate(angle);
  painter.paint(canvas, Offset(-painter.width / 2, -painter.height / 2));
  canvas.restore();
}

void drawCompass(Canvas canvas, Offset p, double radius) {
  final ink = Paint()
    ..color = const Color(0xBBCAB377)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1.4;
  canvas.drawCircle(p, radius, ink);
  canvas.drawCircle(p, radius * .84, ink);
  for (var i = 0; i < 16; i++) {
    final a = i * math.pi / 8;
    final tip =
        p + Offset(math.sin(a), math.cos(a)) * radius * (i.isEven ? .8 : .55);
    final left = p + Offset(math.sin(a - .5), math.cos(a - .5)) * radius * .14;
    canvas.drawPath(
      Path()
        ..moveTo(p.dx, p.dy)
        ..lineTo(left.dx, left.dy)
        ..lineTo(tip.dx, tip.dy)
        ..close(),
      Paint()..color = const Color(0x99CAB377),
    );
  }
  drawLabel(
    canvas,
    'N',
    p.translate(0, -radius - 18),
    20,
    const Color(0xFFE1CE96),
  );
}
