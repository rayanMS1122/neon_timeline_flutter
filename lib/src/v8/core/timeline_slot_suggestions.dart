import 'package:flutter/foundation.dart';

import '../../v6/core/timeline_day_plan.dart';

@immutable
class TimelineSlotSuggestion<T> {
  const TimelineSlotSuggestion({
    required this.start,
    required this.end,
    required this.score,
    required this.gap,
    this.reasons = const <String>[],
  });

  final DateTime start;
  final DateTime end;
  final double score;
  final TimelineDayGap<T> gap;
  final List<String> reasons;

  Duration get duration => end.difference(start);
}

@immutable
class TimelineSlotSuggestionPolicy {
  const TimelineSlotSuggestionPolicy({
    this.snap = const Duration(minutes: 5),
    this.maximumSuggestions = 5,
    this.preferSooner = true,
    this.preferCurrentGap = true,
    this.preferredStart,
    this.earliest,
    this.latest,
  });

  final Duration snap;
  final int maximumSuggestions;
  final bool preferSooner;
  final bool preferCurrentGap;
  final DateTime? preferredStart;
  final DateTime? earliest;
  final DateTime? latest;
}

/// Finds ranked free slots from an already prepared day plan.
class TimelineSlotSuggestionEngine {
  const TimelineSlotSuggestionEngine._();

  static List<TimelineSlotSuggestion<T>> suggest<T>({
    required TimelineDayPlan<T> plan,
    required Duration requestedDuration,
    TimelineSlotSuggestionPolicy policy = const TimelineSlotSuggestionPolicy(),
  }) {
    _validate(requestedDuration, policy);
    final suggestions = <TimelineSlotSuggestion<T>>[];
    final now = plan.insight.now;

    for (final gap in plan.gaps) {
      var start = gap.start;
      var endLimit = gap.end;
      if (policy.earliest != null && start.isBefore(policy.earliest!)) {
        start = policy.earliest!;
      }
      if (policy.latest != null && endLimit.isAfter(policy.latest!)) {
        endLimit = policy.latest!;
      }
      start = _ceilToSnap(start, policy.snap);
      final end = start.add(requestedDuration);
      if (end.isAfter(endLimit)) continue;

      var score = 100.0;
      final reasons = <String>[];
      if (policy.preferCurrentGap && gap.containsNow) {
        score += 35;
        reasons.add('currentGap');
      }
      if (policy.preferSooner) {
        final distance = start.isAfter(now)
            ? start.difference(now).inMinutes
            : now.difference(start).inMinutes;
        score -= distance / 30;
        reasons.add('soon');
      }
      if (policy.preferredStart != null) {
        final distance = start
            .difference(policy.preferredStart!)
            .inMinutes
            .abs();
        score -= distance / 10;
        reasons.add('preferredStart');
      }
      final spareMinutes =
          endLimit.difference(start).inMinutes - requestedDuration.inMinutes;
      score += spareMinutes.clamp(0, 180) / 60;

      suggestions.add(
        TimelineSlotSuggestion<T>(
          start: start,
          end: end,
          score: score,
          gap: gap,
          reasons: List<String>.unmodifiable(reasons),
        ),
      );
    }

    suggestions.sort((left, right) {
      final byScore = right.score.compareTo(left.score);
      if (byScore != 0) return byScore;
      return left.start.compareTo(right.start);
    });
    if (suggestions.isEmpty) {
      return <TimelineSlotSuggestion<T>>[];
    }
    final maximum = policy.maximumSuggestions
        .clamp(1, suggestions.length)
        .toInt();
    return List<TimelineSlotSuggestion<T>>.unmodifiable(
      suggestions.take(maximum),
    );
  }

  static DateTime _ceilToSnap(DateTime value, Duration snap) {
    final step = snap.inMicroseconds;
    if (step <= 0) return value;
    final micros = value.microsecondsSinceEpoch;
    final remainder = micros.remainder(step);
    if (remainder == 0) return value;
    return DateTime.fromMicrosecondsSinceEpoch(
      micros + step - remainder,
      isUtc: value.isUtc,
    );
  }

  static void _validate(
    Duration requestedDuration,
    TimelineSlotSuggestionPolicy policy,
  ) {
    if (requestedDuration <= Duration.zero) {
      throw ArgumentError.value(requestedDuration, 'requestedDuration');
    }
    if (policy.snap <= Duration.zero) {
      throw ArgumentError.value(policy.snap, 'policy.snap');
    }
    if (policy.maximumSuggestions <= 0) {
      throw ArgumentError.value(
        policy.maximumSuggestions,
        'policy.maximumSuggestions',
      );
    }
    if (policy.earliest != null &&
        policy.latest != null &&
        !policy.latest!.isAfter(policy.earliest!)) {
      throw ArgumentError('policy.latest must be after policy.earliest');
    }
  }
}
