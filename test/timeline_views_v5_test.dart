import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:neon_timeline_flutter/neon_timeline_flutter.dart';

void main() {
  final day = DateTime(2026, 4, 1);
  final entries = <TimelineEntry<String>>[
    TimelineEntry(
      id: 'a',
      value: 'Architecture',
      start: day.add(const Duration(hours: 9)),
      duration: const Duration(hours: 1),
      status: TimelineStatus.active,
      resourceIds: const <Object>{'engineering'},
    ),
    TimelineEntry(
      id: 'b',
      value: 'Release',
      start: day.add(const Duration(hours: 11)),
      duration: const Duration(hours: 1),
      status: TimelineStatus.pending,
      resourceIds: const <Object>{'release'},
    ),
  ];

  testWidgets('board view renders grouped entries', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: TimelineTheme(
          data: TimelineThemeData.horizon(),
          child: Scaffold(
            body: SizedBox(
              height: 600,
              child: TimelineBoardView<String>(
                entries: entries,
                groupBy: (entry) => entry.status,
                groupLabel: (group) => (group as TimelineStatus).name,
                titleBuilder: (entry) => entry.value,
              ),
            ),
          ),
        ),
      ),
    );

    expect(find.text('Architecture'), findsOneWidget);
    expect(find.text('Release'), findsOneWidget);
  });

  testWidgets('matrix and overview render without timers', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: TimelineTheme(
          data: TimelineThemeData.signal(),
          child: Scaffold(
            body: Column(
              children: <Widget>[
                TimelineOverviewStrip<String>(
                  entries: entries,
                  rangeStart: day.add(const Duration(hours: 8)),
                  rangeEnd: day.add(const Duration(hours: 14)),
                ),
                Expanded(
                  child: TimelineMatrixView<String>(
                    entries: entries,
                    resources: const <TimelineResource>[
                      TimelineResource(id: 'engineering', label: 'Engineering'),
                      TimelineResource(id: 'release', label: 'Release'),
                    ],
                    rangeStart: day.add(const Duration(hours: 8)),
                    rangeEnd: day.add(const Duration(hours: 14)),
                    titleBuilder: (entry) => entry.value,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    expect(find.text('Engineering'), findsOneWidget);
    expect(find.text('Architecture'), findsOneWidget);
  });
}
