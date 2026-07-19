import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:neon_timeline_flutter/timeline_v10.dart';

void main() {
  testWidgets('snap guide renders blocked and magnetic states', (tester) async {
    final style = StructuredTimelineStyle.delight();
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Column(
            children: <Widget>[
              StructuredTimelineSnapGuide(
                label: '10:00–10:45',
                style: style,
                magnetized: true,
              ),
              StructuredTimelineSnapGuide(
                label: '11:00–11:45',
                style: style,
                blocked: true,
                conflictCount: 2,
              ),
            ],
          ),
        ),
      ),
    );

    expect(find.text('10:00–10:45'), findsOneWidget);
    expect(find.text('11:00–11:45'), findsOneWidget);
    expect(find.byIcon(Icons.auto_fix_high_rounded), findsOneWidget);
    expect(find.byIcon(Icons.block_rounded), findsOneWidget);
  });

  testWidgets('compact entry card does not overflow at short height', (
    tester,
  ) async {
    final start = DateTime(2026, 7, 17, 9);
    final entry = TimelineEntry<String>(
      id: 'entry',
      value: 'value',
      start: start,
      duration: const Duration(minutes: 30),
      semanticLabel: 'A deliberately long task title that must truncate',
    );
    final normalized = TimelineNormalizedEntry<String>(
      entry: entry,
      originalIndex: 0,
      start: start,
      end: start.add(const Duration(minutes: 30)),
      originalStart: start,
      originalEnd: start.add(const Duration(minutes: 30)),
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
      style: StructuredTimelineStyle.delight(),
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
        home: Scaffold(
          body: SizedBox(
            width: 260,
            height: 62,
            child: StructuredTimelineEntryCard<String>(
              details: details,
              title: entry.semanticLabel!,
              subtitle: 'A subtitle that should disappear when compact',
              timeFormatter: (value) => '${value.hour}:${value.minute}',
              durationFormatter: (value) => '${value.inMinutes}m',
            ),
          ),
        ),
      ),
    );

    expect(tester.takeException(), isNull);
  });
}
