import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:neon_timeline_flutter/neon_timeline_flutter.dart';

void main() {
  testWidgets('schedule sorts entries and computes current state',
      (tester) async {
    final day = DateTime(2026, 7, 11);
    final entries = <NeonScheduleEntry<_Task>>[
      NeonScheduleEntry<_Task>(
        id: 'later',
        value: const _Task('Later'),
        start: DateTime(2026, 7, 11, 11),
      ),
      NeonScheduleEntry<_Task>(
        id: 'current',
        value: const _Task('Current'),
        start: DateTime(2026, 7, 11, 9),
        duration: const Duration(hours: 1),
      ),
    ];

    final seen = <String>[];
    await tester.pumpWidget(
      _host(
        NeonScheduleTimeline<_Task>(
          entries: entries,
          selectedDate: day,
          now: DateTime(2026, 7, 11, 9, 30),
          motionEnabled: false,
          itemBuilder: (context, details) {
            seen.add(details.entry.value.title);
            return Text(details.entry.value.title);
          },
        ),
      ),
    );
    await tester.pump();

    expect(seen.take(2), <String>['Current', 'Later']);
    expect(find.text('Current'), findsOneWidget);
    expect(find.text('Later'), findsOneWidget);
    final indicators = tester.widgetList<NeonTimelineIndicator>(
      find.byType(NeonTimelineIndicator),
    );
    expect(
      indicators.any((indicator) => indicator.status == NeonTimelineStatus.active),
      isTrue,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('detects in-place entry-list replacement safely', (tester) async {
    final day = DateTime(2026, 7, 11);
    final entries = <NeonScheduleEntry<_Task>>[
      NeonScheduleEntry<_Task>(
        id: 'task',
        value: const _Task('Before'),
        start: DateTime(2026, 7, 11, 9),
      ),
    ];

    Widget buildTimeline() {
      return _host(
        NeonScheduleTimeline<_Task>(
          entries: entries,
          selectedDate: day,
          now: day.subtract(const Duration(days: 1)),
          motionEnabled: false,
          itemBuilder: (context, details) =>
              Text(details.entry.value.title),
        ),
      );
    }

    await tester.pumpWidget(buildTimeline());
    expect(find.text('Before'), findsOneWidget);

    entries[0] = NeonScheduleEntry<_Task>(
      id: 'task',
      value: const _Task('After'),
      start: DateTime(2026, 7, 11, 10),
    );
    await tester.pumpWidget(buildTimeline());
    await tester.pump();

    expect(find.text('Before'), findsNothing);
    expect(find.text('After'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('long press movement is snapped and reported', (tester) async {
    final day = DateTime(2026, 7, 11);
    DateTime? movedTo;

    await tester.pumpWidget(
      _host(
        NeonScheduleTimeline<_Task>(
          entries: <NeonScheduleEntry<_Task>>[
            NeonScheduleEntry<_Task>(
              id: 'move',
              value: const _Task('Move me'),
              start: DateTime(2026, 7, 11, 10),
            ),
          ],
          selectedDate: day,
          now: DateTime(2026, 7, 10),
          motionEnabled: false,
          enableDragHaptics: false,
          style: const NeonScheduleTimelineStyle(
            pixelsPerMinute: 1,
            snapMinutes: 5,
          ),
          itemBuilder: (context, details) =>
              Text(details.entry.value.title),
          onEntryMoved: (context, details, newStart) {
            movedTo = newStart;
          },
        ),
      ),
    );
    await tester.pump();

    final target = find.text('Move me');
    final gesture = await tester.startGesture(tester.getCenter(target));
    await tester.pump(kLongPressTimeout + const Duration(milliseconds: 50));
    await gesture.moveBy(const Offset(0, 23));
    await tester.pump();
    await gesture.up();
    await tester.pumpAndSettle();

    expect(movedTo, DateTime(2026, 7, 11, 10, 25));
    expect(tester.takeException(), isNull);
  });
}

class _Task {
  const _Task(this.title);

  final String title;
}

Widget _host(Widget child) {
  return MaterialApp(
    theme: ThemeData.dark().copyWith(
      extensions: <ThemeExtension<dynamic>>[
        NeonTimelineThemeData.spectral(),
      ],
    ),
    home: Scaffold(body: SizedBox(width: 430, height: 760, child: child)),
  );
}
