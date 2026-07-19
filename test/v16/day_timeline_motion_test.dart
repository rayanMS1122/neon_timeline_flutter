import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:neon_timeline_flutter/timeline_v16.dart';

void main() {
  testWidgets('time drag shows a time lens and animated confirmation', (
    tester,
  ) async {
    final day = DateTime(2026, 7, 3);
    var entries = <_MotionEntry>[
      _MotionEntry(
        id: 'move',
        title: 'Move me',
        start: day.add(const Duration(hours: 9)),
        end: day.add(const Duration(hours: 9, minutes: 30)),
      ),
    ];
    late StateSetter updateHost;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: StatefulBuilder(
            builder: (context, setState) {
              updateHost = setState;
              return SizedBox(
                width: 420,
                height: 720,
                child: NeonPlannerDayTimeline<_MotionEntry>(
                  entries: entries,
                  adapter: const _MotionAdapter(),
                  selectedDate: day,
                  showHeader: false,
                  showMetrics: false,
                  showGrabber: false,
                  dragActivation: NeonPlannerDragActivation.immediate,
                  dragMinutesPerPixel: 1,
                  fit: NeonPlannerDayFit.scroll,
                  onEntryMove: (proposal) {
                    updateHost(() {
                      entries = <_MotionEntry>[
                        proposal.entry.data.copyWith(
                          start: proposal.proposedStart,
                          end: proposal.proposedEnd,
                        ),
                      ];
                    });
                    return const NeonPlannerMutationResult.accepted();
                  },
                ),
              );
            },
          ),
        ),
      ),
    );

    await tester.pump();
    final gesture = await tester.startGesture(
      tester.getCenter(find.text('Move me')),
    );
    await gesture.moveBy(const Offset(0, 64));
    await tester.pump();

    expect(
      find.byKey(const ValueKey<String>('neon-adaptive-time-lens')),
      findsOneWidget,
    );

    await gesture.up();
    await tester.pump();

    expect(
      find.byKey(const ValueKey<String>('neon-move-confirmation')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey<String>('neon-settled-move')),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);

    await tester.pump(const Duration(seconds: 2));
    expect(
      find.byKey(const ValueKey<String>('neon-move-confirmation')),
      findsNothing,
    );
  });

  testWidgets('drag feedback stays inside a narrow viewport', (tester) async {
    final day = DateTime(2026, 7, 3);
    final entry = _MotionEntry(
      id: 'narrow',
      title: 'A very long appointment title on a narrow screen',
      start: day.add(const Duration(hours: 10)),
      end: day.add(const Duration(hours: 10, minutes: 30)),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 320,
            height: 640,
            child: NeonPlannerDayTimeline<_MotionEntry>(
              entries: <_MotionEntry>[entry],
              adapter: const _MotionAdapter(),
              selectedDate: day,
              showHeader: false,
              showMetrics: false,
              showGrabber: false,
              padding: const EdgeInsets.all(10),
              dragActivation: NeonPlannerDragActivation.immediate,
              onEntryMove: (_) =>
                  const NeonPlannerMutationResult.accepted(),
            ),
          ),
        ),
      ),
    );

    await tester.pump();
    final gesture = await tester.startGesture(
      tester.getCenter(find.textContaining('A very long')),
    );
    await gesture.moveBy(const Offset(0, 36));
    await tester.pump();

    expect(tester.takeException(), isNull);
    await gesture.up();
    await tester.pump();
    expect(tester.takeException(), isNull);
  });
}

@immutable
class _MotionEntry {
  const _MotionEntry({
    required this.id,
    required this.title,
    required this.start,
    required this.end,
  });

  final String id;
  final String title;
  final DateTime start;
  final DateTime end;

  _MotionEntry copyWith({DateTime? start, DateTime? end}) {
    return _MotionEntry(
      id: id,
      title: title,
      start: start ?? this.start,
      end: end ?? this.end,
    );
  }
}

class _MotionAdapter extends NeonPlannerEntryAdapter<_MotionEntry> {
  const _MotionAdapter();

  @override
  Object idOf(_MotionEntry entry) => entry.id;

  @override
  DateTime startOf(_MotionEntry entry) => entry.start;

  @override
  DateTime endOf(_MotionEntry entry) => entry.end;

  @override
  NeonPlannerEntryPresentation presentationOf(_MotionEntry entry) {
    return NeonPlannerEntryPresentation(
      title: entry.title,
      icon: Icons.event_rounded,
      kind: NeonPlannerEntryKind.appointment,
    );
  }
}
