// ignore_for_file: avoid_print

import 'package:neon_timeline_flutter/src/v16/viewport/interval_index.dart';

void main() {
  for (final count in <int>[100, 1000, 10000]) {
    final intervals = List<_Interval>.generate(
      count,
      (index) => _Interval(index * 300000000, index * 300000000 + 180000000),
      growable: false,
    );
    final buildWatch = Stopwatch()..start();
    final index = NeonPlannerIntervalIndex<_Interval>(intervals);
    buildWatch.stop();

    final queryWatch = Stopwatch()..start();
    var hits = 0;
    for (var iteration = 0; iteration < 1000; iteration += 1) {
      final start = (iteration % count) * 300000000;
      hits += index.query(start, start + 900000000).length;
    }
    queryWatch.stop();

    print(
      '$count entries: build=${buildWatch.elapsedMicroseconds}µs, '
      '1000 queries=${queryWatch.elapsedMicroseconds}µs, hits=$hits',
    );
  }
}

final class _Interval implements NeonPlannerInterval {
  const _Interval(this.startMicros, this.endMicros);

  @override
  final int startMicros;

  @override
  final int endMicros;
}
