import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../model/world_presence.dart';
import 'atlas_assets.dart';
import 'atlas_scene.dart';

class NpcLayer extends StatefulWidget {
  const NpcLayer({
    required this.scene,
    required this.people,
    required this.onPerson,
    this.quiet = false,
    super.key,
  });
  final AtlasScene scene;
  final List<WorldPresence> people;
  final ValueChanged<WorldPresence> onPerson;
  final bool quiet;
  @override
  State<NpcLayer> createState() => _NpcLayerState();
}

class _NpcLayerState extends State<NpcLayer>
    with SingleTickerProviderStateMixin {
  late final _clock = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 120),
  );
  Timer? _expiry;
  bool _still = false;
  @override
  void initState() {
    super.initState();
    _expiry = Timer.periodic(const Duration(seconds: 10), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _configureClock();
  }

  @override
  void didUpdateWidget(NpcLayer old) {
    super.didUpdateWidget(old);
    _configureClock();
  }

  void _configureClock() {
    _still =
        widget.quiet ||
        MediaQuery.disableAnimationsOf(context) ||
        !TickerMode.valuesOf(context).enabled;
    if (_still) {
      _clock.stop();
    } else if (!_clock.isAnimating) {
      _clock.repeat();
    }
  }

  @override
  void dispose() {
    _expiry?.cancel();
    _clock.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.quiet || widget.scene.routes.isEmpty) {
      return const SizedBox.shrink();
    }
    final people = widget.people
        .where((p) => p.opacityAt(DateTime.now()) > 0)
        .take(14)
        .toList();
    return AnimatedBuilder(
      animation: _clock,
      builder: (context, _) {
        final seconds = _still ? 0.0 : _clock.value * 120;
        return Stack(
          children: [
            for (var i = 0; i < people.length; i++)
              _person(people[i], i, seconds),
          ],
        );
      },
    );
  }

  Widget _person(WorldPresence person, int i, double seconds) {
    final route = widget.scene.routes[i % widget.scene.routes.length];
    final phase = (seconds * 12 / math.max(route.length, 1) + i * .21) % 2;
    final t = phase <= 1 ? phase : 2 - phase;
    final p = route.at(t);
    final next = route.at((t + (phase <= 1 ? .01 : -.01)).clamp(0, 1));
    return Positioned(
      left: p.dx - 25,
      top: p.dy - 61,
      width: 50,
      height: 75,
      child: Semantics(
        button: true,
        label: '${person.name}, ${person.status.label}',
        child: Tooltip(
          message: '${person.name} · ${person.status.label}',
          child: GestureDetector(
            onTap: () => widget.onPerson(person),
            child: Opacity(
              opacity: person.opacityAt(DateTime.now()),
              child: CustomPaint(
                painter: AvatarPainter(
                  widget.scene.assets,
                  i % 2,
                  _still ? 0 : (seconds * 6).floor() % 4,
                  next.dx < p.dx,
                  person.status,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class AvatarPainter extends CustomPainter {
  AvatarPainter(
    this.assets,
    this.character,
    this.frame,
    this.mirrored,
    this.status,
  );
  final AtlasAssets assets;
  final int character, frame;
  final bool mirrored;
  final SocialStatus status;
  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawOval(
      Rect.fromLTWH(10, 60, 30, 10),
      Paint()..color = const Color(0x553C3329),
    );
    canvas.save();
    if (mirrored) {
      canvas.translate(size.width, 0);
      canvas.scale(-1, 1);
    }
    canvas.drawImageRect(
      assets.adventurers,
      Rect.fromLTWH(frame * 384.0, character * 512.0, 384, 512),
      const Rect.fromLTWH(0, 0, 50, 67),
      Paint()..filterQuality = FilterQuality.low,
    );
    canvas.restore();
    canvas.drawCircle(
      const Offset(40, 10),
      5,
      Paint()
        ..color = status == SocialStatus.doNotDisturb
            ? const Color(0xFFCE8861)
            : const Color(0xFF9CD2A1),
    );
  }

  @override
  bool shouldRepaint(AvatarPainter old) =>
      old.frame != frame ||
      old.character != character ||
      old.mirrored != mirrored ||
      old.status != status ||
      old.assets != assets;
}
