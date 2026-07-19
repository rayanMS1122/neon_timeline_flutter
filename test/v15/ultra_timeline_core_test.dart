import 'package:flutter_test/flutter_test.dart';
import 'package:neon_timeline_flutter/timeline_v15.dart';

void main() {
  group('UltraTimelineCoordinateMap', () {
    test('round-trips time and offset', () {
      final start = DateTime(2026, 7, 18, 8);
      final map = UltraTimelineCoordinateMap(
        rangeStart: start,
        rangeEnd: start.add(const Duration(hours: 12)),
        pixelsPerMinute: 2,
      );
      final target = start.add(const Duration(hours: 2, minutes: 15));
      expect(map.dateAtOffset(map.offsetFor(target)), target);
      expect(map.extent, 1440);
    });
  });

  group('UltraTimelineViewportIndex', () {
    test('finds an early long interval through prefix end index', () {
      final day = DateTime(2026, 7, 18);
      final index = UltraTimelineViewportIndex<String>(
        <UltraTimelineIndexedInterval<String>>[
          UltraTimelineIndexedInterval<String>(
            value: 'long',
            range: UltraTimeRange(
              start: day.add(const Duration(hours: 8)),
              end: day.add(const Duration(hours: 18)),
            ),
          ),
          UltraTimelineIndexedInterval<String>(
            value: 'short',
            range: UltraTimeRange(
              start: day.add(const Duration(hours: 9)),
              end: day.add(const Duration(hours: 10)),
            ),
          ),
        ],
      );
      final result = index.query(
        UltraTimeRange(
          start: day.add(const Duration(hours: 16)),
          end: day.add(const Duration(hours: 17)),
        ),
      );
      expect(result.map((item) => item.value), contains('long'));
    });
  });

  group('UltraMagneticSnapEngine', () {
    test('prefers a close high-priority target', () {
      final raw = DateTime(2026, 7, 18, 9, 7);
      final result = const UltraMagneticSnapEngine().resolve(
        raw: raw,
        strength: UltraTimelineSnapStrength.balanced,
        targets: <UltraTimelineSnapTarget>[
          UltraTimelineSnapTarget(
            id: 'neighbor',
            time: DateTime(2026, 7, 18, 9, 8),
            priority: 2,
          ),
        ],
      );
      expect(result.snapped, isTrue);
      expect(result.target?.id, 'neighbor');
      expect(result.time.minute, 8);
    });

    test('returns raw time when snapping is disabled', () {
      final raw = DateTime(2026, 7, 18, 9, 7);
      final result = const UltraMagneticSnapEngine().resolve(
        raw: raw,
        strength: UltraTimelineSnapStrength.off,
      );
      expect(result.snapped, isFalse);
      expect(result.time, raw);
    });
  });

  test('continuous zoom updates semantic level only at thresholds', () {
    final controller = UltraTimelineController();
    addTearDown(controller.dispose);
    var semanticChanges = 0;
    controller.zoomLevel.addListener(() => semanticChanges += 1);

    controller.setZoomPosition(0.43);
    controller.setZoomPosition(0.45);
    controller.setZoomPosition(0.47);

    expect(controller.zoomPosition.value, 0.47);
    expect(semanticChanges, lessThan(3));
  });

  test('range editor state is isolated from zoom and snap notifiers', () {
    final controller = UltraTimelineController();
    addTearDown(controller.dispose);
    var zoomChanges = 0;
    var snapChanges = 0;
    controller.zoomLevel.addListener(() => zoomChanges += 1);
    controller.snapStrength.addListener(() => snapChanges += 1);

    final day = DateTime(2026, 7, 18);
    controller.showTimeRangeEditor(
      range: UltraTimeRange(
        start: day.add(const Duration(hours: 9)),
        end: day.add(const Duration(hours: 10)),
      ),
      bounds: UltraTimeRange(
        start: day.add(const Duration(hours: 6)),
        end: day.add(const Duration(hours: 22)),
      ),
    );
    controller.updateTimeRange(
      UltraTimeRange(
        start: day.add(const Duration(hours: 9, minutes: 15)),
        end: day.add(const Duration(hours: 10, minutes: 15)),
      ),
    );

    expect(controller.rangeEditor.value.visible, isTrue);
    expect(zoomChanges, 0);
    expect(snapChanges, 0);
  });
}
