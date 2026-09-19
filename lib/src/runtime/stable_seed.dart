/// Stable across processes and Dart targets (unlike Object.hashCode).
int stableSeed(String value) {
  var result = 2166136261;
  for (final unit in value.codeUnits) {
    result = ((result ^ unit) * 16777619) & 0x7fffffff;
  }
  return result;
}
