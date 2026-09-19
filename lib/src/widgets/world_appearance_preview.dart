import 'package:flutter/material.dart';
import '../model/world_appearance.dart';
import '../renderer/appearance_renderer.dart';
import '../renderer/atlas_assets.dart';

/// The same drawAppearance function as the Player App map; no editor-only art.
class WorldAppearancePreview extends StatefulWidget {
  const WorldAppearancePreview({required this.appearance, super.key});
  final WorldAppearance appearance;
  @override
  State<WorldAppearancePreview> createState() => _WorldAppearancePreviewState();
}

class _WorldAppearancePreviewState extends State<WorldAppearancePreview> {
  late final Future<AtlasAssets> _loading = AtlasAssets.load();
  AtlasAssets? _assets;
  @override
  void initState() {
    super.initState();
    _loading.then((assets) {
      if (mounted) {
        _assets = assets;
      } else {
        assets.dispose();
      }
    }, onError: (Object _) {});
  }

  @override
  void dispose() {
    _assets?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => FutureBuilder<AtlasAssets>(
    future: _loading,
    builder: (context, snapshot) {
      if (snapshot.hasError) {
        return const Center(child: Text('Artwork unavailable'));
      }
      if (!snapshot.hasData) {
        return const Center(child: CircularProgressIndicator());
      }
      return CustomPaint(
        painter: _PreviewPainter(snapshot.requireData, widget.appearance),
        size: const Size(280, 230),
      );
    },
  );
}

class _PreviewPainter extends CustomPainter {
  _PreviewPainter(this.assets, this.appearance);
  final AtlasAssets assets;
  final WorldAppearance appearance;
  @override
  void paint(Canvas canvas, Size size) => drawAppearance(
    canvas,
    assets,
    appearance,
    Offset(size.width / 2, size.height - 12),
    size.shortestSide * .85,
  );
  @override
  bool shouldRepaint(_PreviewPainter old) =>
      old.appearance != appearance || old.assets != assets;
}
