import 'package:flutter_test/flutter_test.dart';
import 'package:neon_timeline_flutter/timeline_v11.dart';

void main() {
  test('selection supports range and toggle', () {
    final c = StructuredTimelineSelectionController();
    c.select('b');
    c.selectRange(['a', 'b', 'c', 'd'], 'd');
    expect(c.selected, {'b', 'c', 'd'});
    c.toggle('c');
    expect(c.selected, {'b', 'd'});
    c.dispose();
  });

  test('work constraints reject outside hours', () {
    final constraints = TimelineWorkConstraints();
    final result = constraints.validate(
      DateTime(2026, 7, 17, 7),
      DateTime(2026, 7, 17, 8),
    );
    expect(result.isValid, isFalse);
  });

  test('semantic zoom presets remain immutable', () {
    const config = StructuredTimelineV11Config.production();
    expect(config.zoom, StructuredTimelineSemanticZoom.comfortable);
    expect(config.copyWith(reducedMotion: true).reducedMotion, isTrue);
  });
}
