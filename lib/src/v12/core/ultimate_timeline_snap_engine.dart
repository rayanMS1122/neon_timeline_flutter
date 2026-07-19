import 'dart:math' as math;

import 'package:flutter/foundation.dart';

import '../../v11/core/timeline_work_constraints.dart';
import '../../v4/core/timeline_controller.dart';
import '../../v4/models/timeline_entry.dart';

/// Kind of temporal anchor considered by [UltimateTimelineSnapEngine].
enum UltimateTimelineSnapKind {
  grid,
  previousEnd,
  nextStart,
  freeSlotStart,
  freeSlotEnd,
  workingStart,
  workingEnd,
  marker,
  currentTime,
  dayStart,
  dayEnd,
  focusTime,
  resourceBoundary,
}

/// Direction of the active pointer in timeline time.
enum UltimateTimelinePointerDirection { backward, stationary, forward }

/// A host- or engine-provided temporal snap anchor.
@immutable
class UltimateTimelineSnapTarget<T> {
  const UltimateTimelineSnapTarget({
    required this.time,
    required this.kind,
    this.label,
    this.entry,
    this.priority,
    this.blocked = false,
  });

  final DateTime time;
  final UltimateTimelineSnapKind kind;
  final String? label;
  final TimelineEntry<T>? entry;
  final int? priority;
  final bool blocked;
}

/// Immutable tuning for weighted snapping and anti-flicker hysteresis.
@immutable
class UltimateTimelineSnapConfig {
  const UltimateTimelineSnapConfig({
    this.grid = const Duration(minutes: 5),
    this.magnetDistance = const Duration(minutes: 12),
    this.hysteresis = const Duration(minutes: 2),
    this.minimumSeparation = Duration.zero,
    this.preferConflictFree = true,
    this.includeCurrentTime = false,
  });

  final Duration grid;
  final Duration magnetDistance;
  final Duration hysteresis;
  final Duration minimumSeparation;
  final bool preferConflictFree;
  final bool includeCurrentTime;
}

/// Complete input to one deterministic snap calculation.
@immutable
class UltimateTimelineSnapRequest<T> {
  const UltimateTimelineSnapRequest({
    required this.entry,
    required this.rawStart,
    required this.bounds,
    required this.entries,
    this.direction = UltimateTimelinePointerDirection.stationary,
    this.velocity = 0,
    this.constraints,
    this.customTargets = const [],
    this.currentTime,
    this.previousResult,
  });

  final TimelineEntry<T> entry;
  final DateTime rawStart;
  final TimelineDateRange bounds;
  final List<TimelineEntry<T>> entries;
  final UltimateTimelinePointerDirection direction;
  final double velocity;
  final TimelineWorkConstraints? constraints;
  final List<UltimateTimelineSnapTarget<T>> customTargets;
  final DateTime? currentTime;
  final UltimateTimelineSnapResult<T>? previousResult;
}

/// Selected snap position with enough state for UI and haptic decisions.
@immutable
class UltimateTimelineSnapResult<T> {
  const UltimateTimelineSnapResult({
    required this.start,
    required this.end,
    required this.target,
    required this.conflicts,
    required this.allowed,
    required this.score,
    this.retainedByHysteresis = false,
    this.blockReason,
  });

  final DateTime start;
  final DateTime end;
  final UltimateTimelineSnapTarget<T> target;
  final List<TimelineEntry<T>> conflicts;
  final bool allowed;
  final double score;
  final bool retainedByHysteresis;
  final String? blockReason;

  bool get changedFromRaw =>
      start != target.time || target.kind != UltimateTimelineSnapKind.grid;
}

/// Weighted, conflict-aware and hysteresis-stable temporal snap engine.
class UltimateTimelineSnapEngine<T> {
  const UltimateTimelineSnapEngine({
    this.config = const UltimateTimelineSnapConfig(),
  });

  final UltimateTimelineSnapConfig config;

  UltimateTimelineSnapResult<T> resolve(
    UltimateTimelineSnapRequest<T> request,
  ) {
    final duration = request.entry.rawDuration > Duration.zero
        ? request.entry.rawDuration
        : config.grid;
    final previous = request.previousResult;
    if (previous != null &&
        request.rawStart.difference(previous.start).abs() <=
            config.hysteresis &&
        _insideBounds(previous.start, previous.end, request.bounds)) {
      return UltimateTimelineSnapResult<T>(
        start: previous.start,
        end: previous.end,
        target: previous.target,
        conflicts: previous.conflicts,
        allowed: previous.allowed,
        score: previous.score,
        retainedByHysteresis: true,
        blockReason: previous.blockReason,
      );
    }

    final targets = _collectTargets(request, duration);
    UltimateTimelineSnapResult<T>? best;
    for (final target in targets) {
      final start = target.time;
      final end = start.add(duration);
      if (!_insideBounds(start, end, request.bounds)) continue;
      final conflicts = _conflicts(request.entry, start, end, request.entries);
      final constraint = request.constraints?.validate(start, end);
      final allowed =
          !target.blocked &&
          (constraint?.isValid ?? true) &&
          (!config.preferConflictFree || conflicts.isEmpty);
      final distance = start
          .difference(request.rawStart)
          .inMicroseconds
          .abs()
          .toDouble();
      final priority = target.priority ?? _priority(target.kind);
      final directionPenalty = _directionPenalty(
        request.rawStart,
        start,
        request.direction,
        request.velocity,
      );
      final score =
          (allowed ? 0 : 1e15) +
          conflicts.length * 1e13 +
          priority * 1e10 +
          distance +
          directionPenalty;
      final result = UltimateTimelineSnapResult<T>(
        start: start,
        end: end,
        target: target,
        conflicts: List<TimelineEntry<T>>.unmodifiable(conflicts),
        allowed: allowed,
        score: score,
        blockReason: target.blocked
            ? 'blockedTarget'
            : constraint?.isValid == false
            ? constraint?.reason
            : conflicts.isNotEmpty
            ? 'conflict'
            : null,
      );
      if (best == null || result.score < best.score) best = result;
    }

    if (best != null) return best;
    final fallbackStart = _clampStart(
      _snapToGrid(request.rawStart, config.grid),
      duration,
      request.bounds,
    );
    final fallbackTarget = UltimateTimelineSnapTarget<T>(
      time: fallbackStart,
      kind: UltimateTimelineSnapKind.grid,
      label: 'Grid',
    );
    return UltimateTimelineSnapResult<T>(
      start: fallbackStart,
      end: fallbackStart.add(duration),
      target: fallbackTarget,
      conflicts: const [],
      allowed: true,
      score: double.infinity,
    );
  }

  List<UltimateTimelineSnapTarget<T>> _collectTargets(
    UltimateTimelineSnapRequest<T> request,
    Duration duration,
  ) {
    final maxDistance = math.max(0, config.magnetDistance.inMicroseconds);
    final result = <UltimateTimelineSnapTarget<T>>[
      UltimateTimelineSnapTarget<T>(
        time: _snapToGrid(request.rawStart, config.grid),
        kind: UltimateTimelineSnapKind.grid,
        label: 'Grid',
      ),
      UltimateTimelineSnapTarget<T>(
        time: request.bounds.start,
        kind: UltimateTimelineSnapKind.dayStart,
        label: 'Day start',
      ),
      UltimateTimelineSnapTarget<T>(
        time: request.bounds.end.subtract(duration),
        kind: UltimateTimelineSnapKind.dayEnd,
        label: 'Day end',
      ),
      ...request.customTargets,
    ];

    final constraints = request.constraints;
    if (constraints != null) {
      final day = DateTime(
        request.rawStart.year,
        request.rawStart.month,
        request.rawStart.day,
      );
      result
        ..add(
          UltimateTimelineSnapTarget<T>(
            time: day.add(constraints.dayStart),
            kind: UltimateTimelineSnapKind.workingStart,
            label: 'Working day start',
          ),
        )
        ..add(
          UltimateTimelineSnapTarget<T>(
            time: day.add(constraints.dayEnd).subtract(duration),
            kind: UltimateTimelineSnapKind.workingEnd,
            label: 'Working day end',
          ),
        );
    }

    if (config.includeCurrentTime && request.currentTime != null) {
      result.add(
        UltimateTimelineSnapTarget<T>(
          time: request.currentTime!,
          kind: UltimateTimelineSnapKind.currentTime,
          label: 'Current time',
        ),
      );
    }

    for (final candidate in request.entries) {
      if (candidate.id == request.entry.id || !candidate.hasValidRange) {
        continue;
      }
      result
        ..add(
          UltimateTimelineSnapTarget<T>(
            time: candidate.rawEnd.add(config.minimumSeparation),
            kind: UltimateTimelineSnapKind.previousEnd,
            label: 'After ${candidate.semanticLabel ?? candidate.id}',
            entry: candidate,
          ),
        )
        ..add(
          UltimateTimelineSnapTarget<T>(
            time: candidate.start
                .subtract(duration)
                .subtract(config.minimumSeparation),
            kind: UltimateTimelineSnapKind.nextStart,
            label: 'Before ${candidate.semanticLabel ?? candidate.id}',
            entry: candidate,
          ),
        );
    }

    return List<UltimateTimelineSnapTarget<T>>.unmodifiable(
      result.where((target) {
        final distance = target.time
            .difference(request.rawStart)
            .inMicroseconds
            .abs();
        if (target.kind != UltimateTimelineSnapKind.grid &&
            distance > maxDistance) {
          return false;
        }
        return true;
      }),
    );
  }

  static List<TimelineEntry<T>> _conflicts<T>(
    TimelineEntry<T> moving,
    DateTime start,
    DateTime end,
    Iterable<TimelineEntry<T>> entries,
  ) {
    return entries
        .where(
          (entry) =>
              entry.id != moving.id &&
              entry.hasValidRange &&
              start.isBefore(entry.rawEnd) &&
              end.isAfter(entry.start),
        )
        .toList(growable: false);
  }

  static int _priority(UltimateTimelineSnapKind kind) {
    return switch (kind) {
      UltimateTimelineSnapKind.previousEnd ||
      UltimateTimelineSnapKind.nextStart ||
      UltimateTimelineSnapKind.freeSlotStart ||
      UltimateTimelineSnapKind.freeSlotEnd => 0,
      UltimateTimelineSnapKind.workingStart ||
      UltimateTimelineSnapKind.workingEnd => 1,
      UltimateTimelineSnapKind.marker ||
      UltimateTimelineSnapKind.focusTime ||
      UltimateTimelineSnapKind.resourceBoundary => 2,
      UltimateTimelineSnapKind.dayStart ||
      UltimateTimelineSnapKind.dayEnd ||
      UltimateTimelineSnapKind.currentTime => 3,
      UltimateTimelineSnapKind.grid => 4,
    };
  }

  static double _directionPenalty(
    DateTime raw,
    DateTime target,
    UltimateTimelinePointerDirection direction,
    double velocity,
  ) {
    if (direction == UltimateTimelinePointerDirection.stationary ||
        !velocity.isFinite) {
      return 0;
    }
    final targetDirection = target.compareTo(raw);
    final opposite = direction == UltimateTimelinePointerDirection.forward
        ? targetDirection < 0
        : targetDirection > 0;
    return opposite ? math.min(velocity.abs(), 5000) * 100000 : 0;
  }

  static DateTime _snapToGrid(DateTime value, Duration grid) {
    final step = grid.inMicroseconds;
    final snapped = (value.microsecondsSinceEpoch / step).round() * step;
    return DateTime.fromMicrosecondsSinceEpoch(snapped, isUtc: value.isUtc);
  }

  static DateTime _clampStart(
    DateTime value,
    Duration duration,
    TimelineDateRange bounds,
  ) {
    if (value.isBefore(bounds.start)) return bounds.start;
    final latest = bounds.end.subtract(duration);
    if (value.isAfter(latest)) return latest;
    return value;
  }

  static bool _insideBounds(
    DateTime start,
    DateTime end,
    TimelineDateRange bounds,
  ) {
    return !start.isBefore(bounds.start) && !end.isAfter(bounds.end);
  }
}
