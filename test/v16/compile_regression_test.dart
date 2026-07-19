import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:neon_timeline_flutter/timeline_v16.dart';

const _productionConfig = NeonPlannerTimelineConfig.production();

const _segments = <NeonPlannerTimeRangeSegment>[
  NeonPlannerTimeRangeSegment(
    start: Duration(hours: 12),
    end: Duration(hours: 13),
  ),
];

void main() {
  test('const public API regression cases compile', () {
    const adapter = _Adapter();

    expect(_productionConfig.visibleEnd, const Duration(hours: 24));
    expect(_segments.single.start, const Duration(hours: 12));
    expect(adapter, isA<NeonPlannerEntryAdapter<_Entry>>());
  });

  test('production config passes runtime validation', () {
    expect(_productionConfig.validate, returnsNormally);
  });

  test('invalid duration config fails before timeline use', () {
    const config = NeonPlannerTimelineConfig(
      visibleStart: Duration(hours: 12),
      visibleEnd: Duration(hours: 8),
    );

    expect(config.validate, throwsArgumentError);
  });
}

@immutable
class _Entry {
  const _Entry({required this.start, required this.end});

  final DateTime start;
  final DateTime end;
}

class _Adapter extends NeonPlannerEntryAdapter<_Entry> {
  const _Adapter();

  @override
  Object idOf(_Entry entry) => entry.start;

  @override
  DateTime startOf(_Entry entry) => entry.start;

  @override
  DateTime endOf(_Entry entry) => entry.end;

  @override
  NeonPlannerEntryPresentation presentationOf(_Entry entry) {
    return const NeonPlannerEntryPresentation(
      title: 'Compile regression',
      icon: Icons.event_rounded,
    );
  }
}