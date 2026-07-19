import 'package:flutter_test/flutter_test.dart';
import 'package:neon_timeline_flutter/structured_planner.dart';

void main() {
  test('focused 6.x import exposes headless planner APIs', () {
    final adapter = TimelineEntryAdapter<String>(
      id: (value) => value,
      start: (_) => DateTime(2026, 7, 16, 9),
    );
    final engine = TimelinePlannerEngine<String>(
      adapter: TimelineSeriesAdapter<String>(entryAdapter: adapter),
    );
    final snapshot = engine.buildDay(
      values: const <String>['task'],
      selectedDate: DateTime(2026, 7, 16),
    );

    expect(snapshot.dayPlan.entries, hasLength(1));
  });
}
