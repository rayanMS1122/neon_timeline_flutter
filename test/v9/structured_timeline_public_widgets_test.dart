import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:neon_timeline_flutter/timeline_v9.dart';

void main() {
  testWidgets('public header fits a narrow viewport', (tester) async {
    await tester.binding.setSurfaceSize(const Size(320, 640));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: StructuredTimelineDayHeader(
            date: DateTime(2026, 7, 16),
            style: StructuredTimelineStyle.light(),
            metrics: const StructuredTimelineMetrics(
              entries: 4,
              conflicts: 1,
              busy: Duration(hours: 3),
              free: Duration(hours: 8),
              utilization: 0.27,
            ),
          ),
        ),
      ),
    );

    expect(tester.takeException(), isNull);
    expect(find.text('16.7.2026'), findsOneWidget);
  });

  testWidgets('public states are independently usable', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: StructuredTimelineEmptyState(
            style: StructuredTimelineStyle.light(),
          ),
        ),
      ),
    );

    expect(find.text('No tasks'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('entry card does not overflow at 200 percent text scale', (
    tester,
  ) async {
    final start = DateTime(2026, 7, 16, 14, 20);
    final entry = TimelineEntry<String>(
      id: 'entry',
      value: 'entry',
      start: start,
      duration: const Duration(minutes: 45),
      semanticLabel: 'A deliberately long production task title',
      metadata: const <String, Object?>{
        'structured.subtitle': 'A long subtitle that must never overflow',
      },
    );
    final normalized = TimelineNormalizedEntry<String>(
      entry: entry,
      originalIndex: 0,
      start: start,
      end: start.add(const Duration(minutes: 45)),
      originalStart: start,
      originalEnd: start.add(const Duration(minutes: 45)),
      invalidRange: false,
      isCurrent: false,
    );
    final item = TimelineDayEntry<String>(
      normalized: normalized,
      index: 0,
      conflictType: TimelineConflictType.none,
    );
    final base = StructuredTimelineEntryDetails<String>(
      item: item,
      style: StructuredTimelineStyle.light(),
      isDragging: false,
      isBusy: false,
    );
    final details = AdvancedStructuredTimelineEntryDetails<String>(
      base: base,
      selected: false,
      focused: false,
      busy: false,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: MediaQuery(
          data: const MediaQueryData(textScaler: TextScaler.linear(2)),
          child: Scaffold(
            body: Center(
              child: SizedBox(
                width: 300,
                height: 128,
                child: StructuredTimelineEntryCard<String>(
                  details: details,
                  title: 'A deliberately long production task title',
                  subtitle: 'A long subtitle that must never overflow',
                  progress: 0.6,
                  timeFormatter: (value) =>
                      '${value.hour}:${value.minute.toString().padLeft(2, '0')}',
                  durationFormatter: (value) => '${value.inMinutes}m',
                ),
              ),
            ),
          ),
        ),
      ),
    );

    expect(tester.takeException(), isNull);
  });
}
