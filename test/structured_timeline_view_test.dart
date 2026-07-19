import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:neon_timeline_flutter/structured_planner.dart';

void main() {
  testWidgets('StructuredTimelineView renders entries and gaps', (
    tester,
  ) async {
    final day = DateTime(2026, 7, 16);
    final entries = <TimelineEntry<_Task>>[
      TimelineEntry<_Task>(
        id: 'a',
        value: const _Task('Deep work'),
        start: DateTime(2026, 7, 16, 9),
        duration: const Duration(minutes: 30),
        semanticLabel: 'Deep work',
        color: const Color(0xFFE11D48),
      ),
      TimelineEntry<_Task>(
        id: 'b',
        value: const _Task('Review'),
        start: DateTime(2026, 7, 16, 11),
        duration: const Duration(minutes: 30),
        semanticLabel: 'Review',
        color: const Color(0xFF8B5CF6),
      ),
    ];
    final plan = TimelineDayPlanBuilder.build<_Task>(
      entries: entries,
      selectedDate: day,
      now: DateTime(2026, 7, 16, 9, 10),
      config: const TimelineDayPlanConfig(includeBoundaryGaps: false),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: StructuredTimelineView<_Task>(
            plan: plan,
            showInsightBanner: false,
            onInsert: (_, __) {},
          ),
        ),
      ),
    );

    expect(find.text('Deep work'), findsOneWidget);
    expect(find.text('Review'), findsOneWidget);
    expect(find.text('Add task'), findsOneWidget);
  });

  testWidgets('active drag shuts down cleanly when the view is removed', (
    tester,
  ) async {
    final day = DateTime(2026, 7, 16);
    final entries = List<TimelineEntry<_Task>>.generate(10, (index) {
      return TimelineEntry<_Task>(
        id: 'task-$index',
        value: _Task('Task $index'),
        start: day.add(Duration(hours: 7 + index)),
        duration: const Duration(minutes: 50),
        semanticLabel: 'Task $index',
      );
    });
    final plan = TimelineDayPlanBuilder.build<_Task>(
      entries: entries,
      selectedDate: day,
      now: day.add(const Duration(hours: 6)),
      config: const TimelineDayPlanConfig(includeBoundaryGaps: false),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Align(
            alignment: Alignment.topCenter,
            child: SizedBox(
              height: 240,
              child: StructuredTimelineView<_Task>(
                plan: plan,
                showInsightBanner: false,
                initialScroll: StructuredTimelineInitialScroll.none,
                dragActivationDelay: const Duration(milliseconds: 10),
                autoScrollFrameInterval: const Duration(milliseconds: 16),
                onMove: (_, __) {},
              ),
            ),
          ),
        ),
      ),
    );

    final gesture = await tester.startGesture(
      tester.getCenter(find.text('Task 0')),
    );
    await tester.pump(const Duration(milliseconds: 20));
    await gesture.moveTo(const Offset(400, 238));
    await tester.pump(const Duration(milliseconds: 40));

    await tester.pumpWidget(const MaterialApp(home: SizedBox.shrink()));
    await tester.pump(const Duration(milliseconds: 80));
    await gesture.up();

    expect(tester.takeException(), isNull);
  });

  testWidgets('StructuredTimelineView exposes completion action', (
    tester,
  ) async {
    var completed = false;
    final entry = TimelineEntry<_Task>(
      id: 'a',
      value: const _Task('Deep work'),
      start: DateTime(2026, 7, 16, 9),
      duration: const Duration(minutes: 30),
      semanticLabel: 'Deep work',
    );
    final plan = TimelineDayPlanBuilder.build<_Task>(
      entries: <TimelineEntry<_Task>>[entry],
      selectedDate: DateTime(2026, 7, 16),
      now: DateTime(2026, 7, 16, 8),
      config: const TimelineDayPlanConfig(includeBoundaryGaps: false),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: StructuredTimelineView<_Task>(
            plan: plan,
            showInsightBanner: false,
            onComplete: (_, __) {
              completed = true;
            },
          ),
        ),
      ),
    );

    await tester.tap(
      find.byKey(const ValueKey<String>('structured_complete_a')),
    );
    await tester.pump();
    expect(completed, isTrue);
  });
}

class _Task {
  const _Task(this.title);

  final String title;

  @override
  String toString() => title;
}
