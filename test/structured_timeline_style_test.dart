import 'package:flutter_test/flutter_test.dart';
import 'package:neon_timeline_flutter/structured_planner.dart';

void main() {
  test('StructuredTimelineStyle presets expose valid layout budgets', () {
    final light = StructuredTimelineStyle.light();
    final dark = StructuredTimelineStyle.dark();

    expect(light.pixelsPerMinute, greaterThan(0));
    expect(
      light.maximumEntryExtent,
      greaterThanOrEqualTo(light.minimumEntryExtent),
    );
    expect(dark.backgroundColor, isNot(light.backgroundColor));
    expect(light.primaryColor, isNot(light.accentColor));
  });
}
