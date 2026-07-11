/// Internal duration normalization helpers.
///
/// Duration property getters such as `isNegative` and `inMicroseconds` are not
/// valid in const-constructor assertions on every Dart SDK supported by this
/// package. Validation therefore happens at runtime, immediately before a
/// duration is passed to an animation API.
Duration neonPositiveDuration(
  Duration value, {
  required Duration fallback,
  String debugLabel = 'duration',
}) {
  assert(
    value.inMicroseconds > 0,
    '$debugLabel must be greater than Duration.zero.',
  );
  return value.inMicroseconds > 0 ? value : fallback;
}

/// Returns [Duration.zero] for invalid negative transition durations.
Duration neonNonNegativeDuration(
  Duration value, {
  String debugLabel = 'duration',
}) {
  assert(
    value.inMicroseconds >= 0,
    '$debugLabel must not be negative.',
  );
  return value.inMicroseconds >= 0 ? value : Duration.zero;
}
