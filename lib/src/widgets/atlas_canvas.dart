import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../model/world_presence.dart';
import '../renderer/atlas_scene.dart';
import '../renderer/npc_layer.dart';
import '../renderer/pin_painter.dart';
import '../renderer/scene_pin.dart';

class AtlasCanvas extends StatefulWidget {
  const AtlasCanvas({
    required this.scene,
    required this.onSelect,
    required this.onPerson,
    required this.people,
    this.selected,
    this.quiet = false,
    super.key,
  });
  final AtlasScene scene;
  final ValueChanged<ScenePin> onSelect;
  final ValueChanged<WorldPresence> onPerson;
  final List<WorldPresence> people;
  final String? selected;
  final bool quiet;
  @override
  State<AtlasCanvas> createState() => AtlasCanvasState();
}

class AtlasCanvasState extends State<AtlasCanvas> {
  final _camera = TransformationController();
  Size _viewport = Size.zero;
  double _fit = 1;
  bool _pendingReset = true;
  String? _hovered;
  @override
  void didUpdateWidget(AtlasCanvas oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.scene.key != widget.scene.key) _pendingReset = true;
  }

  @override
  void dispose() {
    _camera.dispose();
    super.dispose();
  }

  void reset() => _setCamera(_fit, widget.scene.size.center(Offset.zero));
  void zoomBy(double factor) => _setCamera(
    (_camera.value.getMaxScaleOnAxis() * factor).clamp(_fit, _fit * 6),
    _camera.toScene(_viewport.center(Offset.zero)),
  );
  void focusPin(String id) {
    final matches = widget.scene.pins.where((p) => p.id == id);
    if (matches.isNotEmpty) _setCamera(_fit * 2, matches.first.position);
  }

  void _setCamera(double scale, Offset center) {
    if (_viewport.isEmpty) return;
    double translation(double viewport, double scene, double target) =>
        scene * scale <= viewport
        ? (viewport - scene * scale) / 2
        : (viewport / 2 - target * scale).clamp(viewport - scene * scale, 0);
    _camera.value = Matrix4.identity()
      ..translateByDouble(
        translation(_viewport.width, widget.scene.size.width, center.dx),
        translation(_viewport.height, widget.scene.size.height, center.dy),
        0,
        1,
      )
      ..scaleByDouble(scale, scale, 1, 1);
  }

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, box) {
      if (_pendingReset || box.biggest != _viewport) {
        _viewport = box.biggest;
        _pendingReset = false;
        _fit = math.min(
          _viewport.width / widget.scene.size.width,
          _viewport.height / widget.scene.size.height,
        );
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) reset();
        });
      }
      final size = widget.scene.size;
      return ColoredBox(
        color: const Color(0xFF314743),
        child: InteractiveViewer(
          key: const ValueKey('atlas-viewer'),
          transformationController: _camera,
          constrained: false,
          alignment: Alignment.topLeft,
          minScale: _fit,
          maxScale: _fit * 6,
          boundaryMargin: EdgeInsets.symmetric(
            horizontal: math.max(0, (_viewport.width / _fit - size.width) / 2),
            vertical: math.max(0, (_viewport.height / _fit - size.height) / 2),
          ),
          child: SizedBox(
            key: const ValueKey('atlas-scene'),
            width: size.width,
            height: size.height,
            child: Stack(
              children: [
                Positioned.fill(
                  child: RepaintBoundary(
                    child: CustomPaint(painter: _GroundPainter(widget.scene)),
                  ),
                ),
                Positioned.fill(
                  child: RepaintBoundary(
                    child: CustomPaint(
                      painter: PinPainter(
                        widget.scene,
                        widget.selected,
                        _hovered,
                      ),
                    ),
                  ),
                ),
                // Hit targets live inside the same transform as their artwork.
                for (final pin in widget.scene.pins)
                  Positioned.fromRect(
                    rect: pin.hitRect,
                    child: Semantics(
                      button: true,
                      label: pin.name,
                      child: Tooltip(
                        message: pin.name,
                        child: Material(
                          type: MaterialType.transparency,
                          child: InkWell(
                            key: ValueKey('pin-${pin.id}'),
                            onTap: () => widget.onSelect(pin),
                            onHover: (hover) => setState(
                              () => _hovered = hover ? pin.id : null,
                            ),
                            onFocusChange: (focus) => setState(
                              () => _hovered = focus ? pin.id : null,
                            ),
                            hoverColor: Colors.transparent,
                            focusColor: Colors.white12,
                          ),
                        ),
                      ),
                    ),
                  ),
                Positioned.fill(
                  child: NpcLayer(
                    scene: widget.scene,
                    people: widget.people,
                    quiet: widget.quiet,
                    onPerson: widget.onPerson,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}

class _GroundPainter extends CustomPainter {
  _GroundPainter(this.scene);
  final AtlasScene scene;
  @override
  void paint(Canvas canvas, Size size) => canvas.drawPicture(scene.picture);
  @override
  bool shouldRepaint(_GroundPainter old) => old.scene.picture != scene.picture;
}
