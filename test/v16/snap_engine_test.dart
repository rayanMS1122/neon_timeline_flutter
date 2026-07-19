import 'package:flutter_test/flutter_test.dart';
import 'package:neon_timeline_flutter/timeline_v16.dart';

void main() {
  final origin = DateTime(2026, 7, 18, 10);

  test('prefers a high-priority neighboring boundary over the grid', () {
    final engine = NeonPlannerSnapEngine(
      interval: const Duration(minutes: 15),
    );
    final neighbor = origin.add(const Duration(minutes: 8));
    final result = engine.resolve(
      candidate: origin.add(const Duration(minutes: 7)),
      targets: <NeonPlannerSnapTarget>[
        NeonPlannerSnapTarget(
          time: neighbor,
          kind: NeonPlannerSnapTargetKind.entryStart,
          priority: 4,
          id: 'neighbor',
        ),
      ],
    );

    expect(result.didSnap, isTrue);
    expect(result.time, neighbor);
  });

  test('off strength returns the unsnapped candidate', () {
    final engine = NeonPlannerSnapEngine(
      interval: const Duration(minutes: 15),
      strength: NeonPlannerSnapStrength.off,
    );
    final candidate = origin.add(const Duration(minutes: 7));
    final result = engine.resolve(candidate: candidate);
    expect(result.didSnap, isFalse);
    expect(result.time, candidate);
  });
}
