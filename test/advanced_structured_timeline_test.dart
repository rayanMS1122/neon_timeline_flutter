import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:neon_timeline_flutter/structured_planner.dart';

void main() {
  testWidgets('advanced timeline renders, selects and exposes resize handles', (
    tester,
  ) async {
    final entry = TimelineEntry<String>(
      id: 'a',
      value: 'Deep work',
      start: DateTime(2026, 7, 16, 9),
      duration: const Duration(minutes: 45),
      semanticLabel: 'Deep work',
      color: const Color(0xFFE11D48),
    );
    final plan = TimelineDayPlanBuilder.build<String>(
      entries: <TimelineEntry<String>>[entry],
      selectedDate: DateTime(2026, 7, 16),
      now: DateTime(2026, 7, 16, 8),
      config: const TimelineDayPlanConfig(includeBoundaryGaps: false),
    );
    final controller = StructuredTimelineController<String>();
    TimelineResizePreview<String>? resize;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AdvancedStructuredTimeline<String>(
            plan: plan,
            controller: controller,
            showInsightBanner: false,
            onResize: (context, details) {
              resize = details.preview;
            },
          ),
        ),
      ),
    );

    expect(find.text('Deep work'), findsOneWidget);
    await tester.tap(find.text('Deep work'));
    await tester.pump();
    expect(controller.selectedId, 'a');
    expect(find.bySemanticsLabel('Resize task start'), findsOneWidget);
    expect(find.bySemanticsLabel('Resize task end'), findsOneWidget);

    await tester.drag(
      find.bySemanticsLabel('Resize task end'),
      const Offset(0, 24),
    );
    await tester.pump();
    expect(resize, isNotNull);
    expect(resize!.duration, greaterThan(const Duration(minutes: 45)));

    await tester.pumpWidget(const SizedBox.shrink());
    controller.dispose();
  });

  testWidgets('advanced timeline can be controlled by jump and zoom commands', (
    tester,
  ) async {
    final entries = List<TimelineEntry<String>>.generate(
      8,
      (index) => TimelineEntry<String>(
        id: '$index',
        value: 'Task $index',
        start: DateTime(2026, 7, 16, 8 + index),
        duration: const Duration(minutes: 40),
        semanticLabel: 'Task $index',
      ),
    );
    final plan = TimelineDayPlanBuilder.build<String>(
      entries: entries,
      selectedDate: DateTime(2026, 7, 16),
      now: DateTime(2026, 7, 16, 11, 10),
      config: const TimelineDayPlanConfig(includeBoundaryGaps: false),
    );
    final controller = StructuredTimelineController<String>();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AdvancedStructuredTimeline<String>(
            plan: plan,
            controller: controller,
            showInsightBanner: false,
          ),
        ),
      ),
    );

    controller.zoomIn();
    controller.jumpToEntry('6', animated: false);
    await tester.pumpAndSettle();
    expect(controller.zoom, greaterThan(1));
    expect(controller.navigationRequest?.entryId, '6');

    await tester.pumpWidget(const SizedBox.shrink());
    controller.dispose();
  });
}
