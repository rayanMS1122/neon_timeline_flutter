import 'package:flutter_test/flutter_test.dart';
import 'package:neon_timeline_flutter/src/v16/geometry/lane_allocator.dart';

void main() {
  test('assigns different lanes to overlapping intervals', () {
    const allocator = NeonPlannerLaneAllocator();
    final placements = allocator.allocate<String>(
      const <NeonPlannerLaneInterval<String>>[
        NeonPlannerLaneInterval<String>(
          value: 'a',
          startMicros: 0,
          endMicros: 100,
        ),
        NeonPlannerLaneInterval<String>(
          value: 'b',
          startMicros: 50,
          endMicros: 150,
        ),
        NeonPlannerLaneInterval<String>(
          value: 'c',
          startMicros: 150,
          endMicros: 200,
        ),
      ],
    );

    final byValue = <String, int>{
      for (final placement in placements) placement.value: placement.lane,
    };
    expect(byValue['a'], isNot(byValue['b']));
    expect(byValue['c'], anyOf(byValue['a'], byValue['b']));
  });
}
