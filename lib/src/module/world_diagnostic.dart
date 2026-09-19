enum WorldDiagnosticCode {
  source,
  invalidProjection,
  assets,
  intent,
  unsupported,
  renderer,
}

enum WorldDiagnosticSeverity { information, warning, error }

class WorldDiagnostic {
  const WorldDiagnostic(
    this.code, {
    this.severity = WorldDiagnosticSeverity.error,
    this.cause,
  });
  final WorldDiagnosticCode code;
  final WorldDiagnosticSeverity severity;

  /// For host diagnostics only; never shown directly to an end user.
  final Object? cause;
}
