import 'package:flutter/material.dart';
import '../data/world_data_source.dart';
import '../interaction/world_intent.dart';
import '../widgets/world_view.dart';
import 'world_diagnostic.dart';
import 'world_host_bridge.dart';
import 'world_host_capabilities.dart';
import 'world_host_context.dart';
import 'world_scope.dart';

/// Stable embedding boundary for Player App, MasterHub, ClubManager and review.
class WorldModule extends StatefulWidget {
  const WorldModule({
    required this.host,
    required this.capabilities,
    required this.bridge,
    required this.source,
    super.key,
  });
  final WorldHostContext host;
  final WorldHostCapabilities capabilities;
  final WorldHostBridge bridge;
  final WorldDataSource source;
  @override
  State<WorldModule> createState() => _WorldModuleState();
}

class _WorldModuleState extends State<WorldModule> {
  Future<void> _dispatch(WorldIntent intent) async {
    if (!widget.capabilities.allows(intent)) {
      throw const WorldActionUnavailable();
    }
    try {
      await widget.bridge.dispatch(intent);
    } catch (error) {
      widget.bridge.diagnostic(
        WorldDiagnostic(WorldDiagnosticCode.intent, cause: error),
      );
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) => WorldScope(
    host: widget.host,
    capabilities: widget.capabilities,
    bridge: widget.bridge,
    child: widget.capabilities.canView
        ? WorldView(
            source: widget.source,
            onIntent: _dispatch,
            onDiagnostic: widget.bridge.diagnostic,
            capabilities: widget.capabilities,
            canCreateClub: widget.capabilities.canCreateOrganization,
            canEditAppearance: (_) => widget.capabilities.canEditAppearance,
          )
        : const Center(child: Text('World is not available in this context.')),
  );
}
