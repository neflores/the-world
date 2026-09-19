import 'dart:async';
import 'package:flutter/widgets.dart';
import 'world_clock.dart';
import 'world_render_policy.dart';

/// Refreshes expiry without asking a host to resend unchanged projections.
class WorldRuntime extends StatefulWidget {
  const WorldRuntime({
    required this.clock,
    required this.policy,
    required this.child,
    this.viewerId,
    super.key,
  });
  final WorldClock clock;
  final WorldRenderPolicy policy;
  final String? viewerId;
  final Widget child;
  @override
  State<WorldRuntime> createState() => _WorldRuntimeState();
}

class _WorldRuntimeState extends State<WorldRuntime> {
  Timer? _timer;
  void _refresh() {
    if (mounted) setState(() {});
  }

  void _listen(WorldClock clock, bool add) {
    if (clock is Listenable) {
      add
          ? (clock as Listenable).addListener(_refresh)
          : (clock as Listenable).removeListener(_refresh);
    }
  }

  @override
  void initState() {
    super.initState();
    _listen(widget.clock, true);
    _timer = Timer.periodic(const Duration(seconds: 5), (_) => _refresh());
  }

  @override
  void didUpdateWidget(WorldRuntime old) {
    super.didUpdateWidget(old);
    if (old.clock != widget.clock) {
      _listen(old.clock, false);
      _listen(widget.clock, true);
    }
  }

  @override
  void dispose() {
    _listen(widget.clock, false);
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => WorldRuntimeData(
    now: widget.clock.now(),
    clock: widget.clock,
    policy: widget.policy,
    viewerId: widget.viewerId,
    child: widget.child,
  );
}

class WorldRuntimeData extends InheritedWidget {
  const WorldRuntimeData({
    required this.now,
    required this.clock,
    required this.policy,
    this.viewerId,
    required super.child,
    super.key,
  });
  final DateTime now;
  final WorldClock clock;
  final WorldRenderPolicy policy;
  final String? viewerId;
  static WorldRuntimeData? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<WorldRuntimeData>();
  static DateTime timeOf(BuildContext context) =>
      maybeOf(context)?.now ?? const SystemWorldClock().now();
  @override
  bool updateShouldNotify(WorldRuntimeData old) =>
      now != old.now || policy != old.policy || viewerId != old.viewerId;
}
