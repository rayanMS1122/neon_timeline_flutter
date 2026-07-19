import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:neon_timeline_flutter/neon_timeline_flutter.dart';

void main() {
  test('activity index and week lanes share deterministic day plans', () {
    final entries = <TimelineEntry<String>>[
      TimelineEntry<String>(
        id: 'a',
        value: 'a',
        start: DateTime(2026, 7, 13, 9),
        duration: const Duration(hours: 2),
        color: Colors.pink,
      ),
      TimelineEntry<String>(
        id: 'b',
        value: 'b',
        start: DateTime(2026, 7, 15, 12),
        duration: const Duration(hours: 1),
        status: TimelineStatus.completed,
        color: Colors.blue,
      ),
    ];

    final activity = TimelineActivityIndex<String>.build(
      entries: entries,
      startDate: DateTime(2026, 7, 13),
      endDate: DateTime(2026, 7, 19),
    );
    final week = TimelineWeekPlanBuilder.build<String>(
      entries: entries,
      selectedDate: DateTime(2026, 7, 16),
    );

    expect(activity.activityFor(DateTime(2026, 7, 13))?.entryCount, 1);
    expect(activity.activityFor(DateTime(2026, 7, 14))?.entryCount, 0);
    expect(week.lanes, hasLength(7));
    expect(week.laneFor(DateTime(2026, 7, 15))?.layoutItems, hasLength(1));
    expect(week.completedDuration, const Duration(hours: 1));
  });

  test('extended planner day includes after-midnight entries', () {
    final entry = TimelineEntry<String>(
      id: 'night',
      value: 'night',
      start: DateTime(2026, 7, 17, 2),
      duration: const Duration(minutes: 30),
    );
    const config = TimelineDayPlanConfig(
      dayStartOffset: Duration(hours: -5),
      dayEndOffset: Duration(hours: 29),
    );
    final activity = TimelineActivityIndex<String>.build(
      entries: <TimelineEntry<String>>[entry],
      startDate: DateTime(2026, 7, 16),
      endDate: DateTime(2026, 7, 16),
      dayConfig: config,
    );
    final week = TimelineWeekPlanBuilder.build<String>(
      entries: <TimelineEntry<String>>[entry],
      selectedDate: DateTime(2026, 7, 16),
      dayConfig: config,
    );

    expect(activity.activityFor(DateTime(2026, 7, 16))?.entryCount, 1);
    expect(week.laneFor(DateTime(2026, 7, 16))?.dayPlan.entries, hasLength(1));
  });
}
