import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:neon_timeline_flutter/neon_timeline_flutter.dart';

void main() {
  testWidgets('neutral TimelineView renders modern cards lazily', (
    tester,
  ) async {
    final controller = TimelineController<String>();
    final theme = TimelineThemeData.modern();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 420,
            height: 700,
            child: TimelineTheme(
              data: theme,
              child: TimelineView<String>(
                entries: <TimelineEntry<String>>[
                  TimelineEntry<String>(
                    id: 'a',
                    value: 'Architecture',
                    start: DateTime(2026, 7, 13, 9),
                    status: TimelineStatus.active,
                  ),
                  TimelineEntry<String>(
                    id: 'b',
                    value: 'Performance',
                    start: DateTime(2026, 7, 13, 10),
                  ),
                ],
                timelineController: controller,
                motion: const TimelineMotionConfig.disabled(),
                itemBuilder: (context, details) => TimelineCard(
                  title: details.entry.value,
                  status: details.entry.status,
                  selected: controller.isSelected(details.entry.id),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('Architecture'), findsOneWidget);
    expect(find.text('Performance'), findsOneWidget);
    expect(tester.takeException(), isNull);
    controller.dispose();
  });

  testWidgets('PlannerView maps neutral entries to schedule details', (
    tester,
  ) async {
    final day = DateTime(2026, 7, 13);
    TimelineEntryDetails<String>? seen;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 430,
            height: 760,
            child: PlannerView<String>(
              entries: <TimelineEntry<String>>[
                TimelineEntry<String>(
                  id: 'planner',
                  value: 'Planner task',
                  start: DateTime(2026, 7, 13, 9),
                  duration: const Duration(hours: 1),
                ),
              ],
              selectedDate: day,
              now: DateTime(2026, 7, 13, 9, 30),
              itemBuilder: (context, details) {
                seen = details;
                return Text(details.entry.value);
              },
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('Planner task'), findsOneWidget);
    expect(seen?.isCurrent, isTrue);
    expect(tester.takeException(), isNull);
  });
}
