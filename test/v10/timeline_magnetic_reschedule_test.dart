import 'package:flutter_test/flutter_test.dart';
import 'package:neon_timeline_flutter/timeline_v10.dart';

void main() {
  group('TimelineMagneticRescheduleEngine', () {
    test('magnetizes to the end of a nearby entry', () {
      final day = DateTime(2026, 7, 17);
      final moving = TimelineEntry<String>(
        id: 'moving',
        value: 'moving',
        start: day.add(const Duration(hours: 9)),
        duration: const Duration(minutes: 30),
      );
      final neighbor = TimelineEntry<String>(
        id: 'neighbor',
        value: 'neighbor',
        start: day.add(const Duration(hours: 10)),
        duration: const Duration(hours: 1),
      );
      final engine = TimelineMagneticRescheduleEngine<String>(
        entry: moving,
        bounds: TimelineDateRange(day, day.add(const Duration(days: 1))),
        candidates: <TimelineEntry<String>>[moving, neighbor],
        policy: const TimelineReschedulePolicy(
          snap: Duration(minutes: 1),
          pixelsPerMinute: 1,
        ),
        magnetDistance: const Duration(minutes: 8),
      );

      final preview = engine.previewForDelta(const Duration(minutes: 116));

      expect(preview.magnetized, isTrue);
      expect(preview.kind, TimelineMagnetKind.afterEntry);
      expect(preview.preview.start, day.add(const Duration(hours: 11)));
      expect(preview.anchorEntry?.id, 'neighbor');
    });

    test('does not magnetize beyond the configured distance', () {
      final day = DateTime(2026, 7, 17);
      final moving = TimelineEntry<String>(
        id: 'moving',
        value: 'moving',
        start: day.add(const Duration(hours: 9)),
        duration: const Duration(minutes: 30),
      );
      final neighbor = TimelineEntry<String>(
        id: 'neighbor',
        value: 'neighbor',
        start: day.add(const Duration(hours: 12)),
        duration: const Duration(hours: 1),
      );
      final engine = TimelineMagneticRescheduleEngine<String>(
        entry: moving,
        bounds: TimelineDateRange(day, day.add(const Duration(days: 1))),
        candidates: <TimelineEntry<String>>[moving, neighbor],
        magnetDistance: const Duration(minutes: 5),
      );

      final preview = engine.previewForDelta(const Duration(minutes: 90));

      expect(preview.magnetized, isFalse);
      expect(preview.kind, TimelineMagnetKind.none);
    });
  });

  test('delight experience exposes responsive drag defaults', () {
    const experience = StructuredTimelineExperience.delight();
    expect(experience.showSnapGuide, isTrue);
    expect(experience.showDropSlot, isTrue);
    expect(experience.magnetizeToNeighbors, isTrue);
    expect(
      experience.edgeScrollFrameInterval,
      const Duration(milliseconds: 16),
    );
  });
}
