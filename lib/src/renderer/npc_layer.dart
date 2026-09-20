import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../model/world_avatar.dart';
import '../model/world_presence.dart';
import 'atlas_assets.dart';
import 'atlas_scene.dart';
import '../runtime/world_runtime.dart';
import '../runtime/world_render_policy.dart';
import '../runtime/stable_seed.dart';
import '../localization/world_strings.dart';

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

class _NpcLayerState extends State<NpcLayer> {
  Timer? _clock;
  double _seconds = 0;
  int _fps = 0;
  bool _still = false;

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
    final policy = WorldRuntimeData.maybeOf(context)?.policy;
    _still =
        widget.quiet ||
        (policy?.quiet ?? false) ||
        (policy?.reduceMotion ?? false) ||
        MediaQuery.disableAnimationsOf(context) ||
        !TickerMode.valuesOf(context).enabled;
    if (_still) {
      _clock?.cancel();
      _clock = null;
      _fps = 0;
    } else {
      final nextFps = (policy?.framesPerSecond ?? 30).clamp(1, 60);
      if (_clock != null && _fps == nextFps) return;
      _clock?.cancel();
      _fps = nextFps;
      final tick = Duration(microseconds: 1000000 ~/ nextFps);
      _clock = Timer.periodic(tick, (_) {
        if (!mounted) return;
        setState(() => _seconds = (_seconds + 1 / nextFps) % 120);
      });
    }
  }

  @override
  void dispose() {
    _clock?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final runtime = WorldRuntimeData.maybeOf(context);
    if (widget.quiet ||
        (runtime?.policy.quiet ?? false) ||
        widget.scene.routes.isEmpty) {
      return const SizedBox.shrink();
    }
    final people = (runtime?.policy ?? const WorldRenderPolicy()).sample(
      widget.people,
      WorldRuntimeData.timeOf(context),
      viewerId: runtime?.viewerId,
    );
    final seconds = _still ? 0.0 : _seconds;
    return Stack(
      children: [
        for (var i = 0; i < people.length; i++)
          _person(people[i], stableSeed(people[i].id), seconds),
      ],
    );
  }

  Widget _person(WorldPresence person, int i, double seconds) {
    final statusLabel = WorldLocalization.of(context).status(person.status);
    final route = widget.scene.routes[i % widget.scene.routes.length];
    // Presentation behavior is deterministic and remains client-side.
    final behaviorTime = (seconds + i % 17) % 22;
    final idle = behaviorTime >= 15;
    final travelSeconds = seconds - math.max(0, behaviorTime - 15);
    final phase =
        (travelSeconds * 12 / math.max(route.length, 1) + i * .21) % 2;
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
        label: '${person.name}, $statusLabel',
        child: Tooltip(
          message: '${person.name} · $statusLabel',
          child: GestureDetector(
            onTap: () => widget.onPerson(person),
            child: Opacity(
              opacity: person.opacityAt(WorldRuntimeData.timeOf(context)),
              child: CustomPaint(
                painter: AvatarPainter(
                  widget.scene.assets,
                  i % 2,
                  _still || idle
                      ? ((i ~/ 7) % 2) * 3
                      : (seconds * 6).floor() % 4,
                  next.dx < p.dx,
                  person.status,
                  person.avatar,
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
    this.avatar,
  );
  final AtlasAssets assets;
  final int character, frame;
  final bool mirrored;
  final SocialStatus status;
  final WorldAvatar avatar;
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
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(14, 35, 22, 25),
        const Radius.circular(6),
      ),
      Paint()..color = Color(avatar.clothingColor).withValues(alpha: .5),
    );
    canvas.drawArc(
      Rect.fromLTWH(
        15,
        avatar.hairstyle == WorldHairstyle.long ? 5 : 8,
        20,
        avatar.hairstyle == WorldHairstyle.long ? 25 : 16,
      ),
      math.pi,
      math.pi,
      true,
      Paint()..color = Color(avatar.hairColor).withValues(alpha: .7),
    );
    canvas.restore();
    _drawStatus(canvas, const Offset(40, 10));
  }

  void _drawStatus(Canvas canvas, Offset center) {
    final color = status == SocialStatus.doNotDisturb
        ? const Color(0xFFCE8861)
        : const Color(0xFF457B65);
    canvas.drawCircle(center, 7, Paint()..color = const Color(0xFFE9D6AC));
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    switch (status) {
      case SocialStatus.lookingForGame:
        canvas.drawRect(
          Rect.fromCenter(center: center, width: 7, height: 7),
          paint,
        );
        break;
      case SocialStatus.openToMeet:
        canvas.drawCircle(center.translate(-2, 0), 3, paint);
        canvas.drawCircle(center.translate(2, 0), 3, paint);
        break;
      case SocialStatus.waitingForParty:
        canvas.drawLine(
          center.translate(-4, 3),
          center.translate(0, -4),
          paint,
        );
        canvas.drawLine(center.translate(0, -4), center.translate(4, 3), paint);
        break;
      case SocialStatus.browsing:
        canvas.drawCircle(center, 3.5, paint);
        canvas.drawLine(center.translate(3, 3), center.translate(6, 6), paint);
        break;
      case SocialStatus.newSystem:
        canvas.drawLine(center.translate(-4, 0), center.translate(4, 0), paint);
        canvas.drawLine(center.translate(0, -4), center.translate(0, 4), paint);
        break;
      case SocialStatus.online:
        canvas.drawArc(
          Rect.fromCircle(center: center, radius: 4),
          math.pi * 1.15,
          math.pi * .7,
          false,
          paint,
        );
        break;
      case SocialStatus.doNotDisturb:
        canvas.drawLine(
          center.translate(-4, 4),
          center.translate(4, -4),
          paint,
        );
        break;
      case SocialStatus.hidden:
        canvas.drawLine(center.translate(-4, 0), center.translate(4, 0), paint);
        break;
    }
  }

  @override
  bool shouldRepaint(AvatarPainter old) =>
      old.frame != frame ||
      old.character != character ||
      old.mirrored != mirrored ||
      old.status != status ||
      old.avatar != avatar ||
      old.assets != assets;
}
