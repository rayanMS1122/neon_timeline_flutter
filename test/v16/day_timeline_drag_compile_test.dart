import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:neon_timeline_flutter/timeline_v16.dart';

void main() {
  testWidgets('compact drag feedback compiles with explicit foundation types', (
    tester,
  ) async {
    final day = DateTime(2026, 7, 3);
    final entries = <_DragEntry>[
      _DragEntry(
        id: 'a',
        start: day.add(const Duration(hours: 8)),
        end: day.add(const Duration(hours: 8, minutes: 15)),
      ),
      _DragEntry(
        id: 'b',
        start: day.add(const Duration(hours: 10)),
        end: day.add(const Duration(hours: 10, minutes: 15)),
      ),
    ];

    await tester.pumpWidget(
      MaterialApp(
        home: SizedBox(
          width: 700,
          height: 900,
          child: NeonPlannerDayTimeline<_DragEntry>(
            entries: entries,
            adapter: const _DragAdapter(),
            selectedDate: day,
            dragActivation: NeonPlannerDragActivation.immediate,
            onEntryMove: (_) =>
                const NeonPlannerMutationResult.accepted(),
          ),
        ),
      ),
    );

    await tester.pump();
    expect(find.text('Termin'), findsNWidgets(2));
    expect(tester.takeException(), isNull);
  });
}

@immutable
class _DragEntry {
  const _DragEntry({
    required this.id,
    required this.start,
    required this.end,
  });

  final String id;
  final DateTime start;
  final DateTime end;
}

class _DragAdapter extends NeonPlannerEntryAdapter<_DragEntry> {
  const _DragAdapter();

  @override
  Object idOf(_DragEntry entry) => entry.id;

  @override
  DateTime startOf(_DragEntry entry) => entry.start;

  @override
  DateTime endOf(_DragEntry entry) => entry.end;

  @override
  NeonPlannerEntryPresentation presentationOf(_DragEntry entry) {
    return const NeonPlannerEntryPresentation(
      title: 'Termin',
      icon: Icons.event_rounded,
      kind: NeonPlannerEntryKind.appointment,
    );
  }
}
