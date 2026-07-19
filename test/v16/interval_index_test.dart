import 'package:flutter_test/flutter_test.dart';
import 'package:neon_timeline_flutter/src/v16/viewport/interval_index.dart';

void main() {
  test('finds a long interval behind non-overlapping short intervals', () {
    final index = NeonPlannerIntervalIndex<_Interval>(<_Interval>[
      const _Interval('long', 0, 1000),
      const _Interval('short-a', 100, 150),
      const _Interval('short-b', 200, 250),
      const _Interval('target', 800, 850),
    ]);

    final result = index.query(700, 900).map((item) => item.id).toSet();
    expect(result, containsAll(<String>['long', 'target']));
  });

  test('queries 10,000 intervals without materializing unrelated entries', () {
    final index = NeonPlannerIntervalIndex<_Interval>(
      List<_Interval>.generate(
        10000,
        (i) => _Interval('$i', i * 100, i * 100 + 50),
      ),
    );
    final result = index.query(500000, 500300);
    expect(result.length, lessThanOrEqualTo(4));
    expect(result.map((item) => item.id), contains('5000'));
  });

  test('supports negative interval coordinates without integer sentinels', () {
    final index = NeonPlannerIntervalIndex<_Interval>(const <_Interval>[
      _Interval('earlier', -5000, -4000),
      _Interval('target', -2500, -1500),
    ]);

    expect(index.query(-2000, -1000).map((item) => item.id), <String>['target']);
  });
}

class _Interval implements NeonPlannerInterval {
  const _Interval(this.id, this.startMicros, this.endMicros);

  final String id;

  @override
  final int startMicros;

  @override
  final int endMicros;
}
