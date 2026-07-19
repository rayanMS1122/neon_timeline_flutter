import 'package:flutter_test/flutter_test.dart';
import 'package:neon_timeline_flutter/timeline_v16.dart';

void main() {
  group('NeonPlannerTimeScale', () {
    final origin = DateTime(2026, 7, 18);

    test('maps time and pixels bidirectionally', () {
      final scale = NeonPlannerTimeScale(
        origin: origin,
        pixelsPerMinute: 2,
      );
      final time = origin.add(const Duration(hours: 3, minutes: 15));
      final pixels = scale.timeToPixels(time);
      expect(pixels, 390);
      expect(scale.pixelsToTime(pixels), time);
    });

    test('maps duration and pixels bidirectionally', () {
      final scale = NeonPlannerTimeScale(
        origin: origin,
        pixelsPerMinute: 2.5,
      );
      const duration = Duration(minutes: 90);
      expect(scale.durationToPixels(duration), 225);
      expect(scale.pixelsToDuration(225), duration);
    });
  });
}
