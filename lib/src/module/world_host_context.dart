enum WorldHostSurface { playerApp, masterHub, clubManager, playground }

class WorldHostContext {
  const WorldHostContext({
    required this.surface,
    this.viewerId,
    this.professionalId,
    this.organizationId,
    this.environment = 'production',
  });
  final WorldHostSurface surface;

  /// Ecosystem identity, never a Fluxer identity/token.
  final String? viewerId, professionalId, organizationId;
  final String environment;
}
