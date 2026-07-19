import 'package:flutter_test/flutter_test.dart';
import 'package:neon_timeline_flutter/timeline_core.dart';

void main() {
  test('dependency engine orders work and computes a critical chain', () {
    final start = DateTime(2026, 7, 13, 9);
    final entries = <TimelineEntry<String>>[
      TimelineEntry<String>(
        id: 'design',
        value: 'Design',
        start: start,
        duration: const Duration(hours: 2),
      ),
      TimelineEntry<String>(
        id: 'build',
        value: 'Build',
        start: start,
        duration: const Duration(hours: 3),
      ),
      TimelineEntry<String>(
        id: 'launch',
        value: 'Launch',
        start: start,
        duration: const Duration(hours: 1),
      ),
    ];
    final analysis = TimelineDependencyEngine.analyze<String>(
      entries: entries,
      dependencies: const <TimelineDependency>[
        TimelineDependency(
          id: 'd-b',
          predecessorId: 'design',
          successorId: 'build',
        ),
        TimelineDependency(
          id: 'b-l',
          predecessorId: 'build',
          successorId: 'launch',
        ),
      ],
    );

    expect(analysis.isValid, isTrue);
    expect(analysis.topologicalEntries.map((entry) => entry.id), <Object>[
      'design',
      'build',
      'launch',
    ]);
    expect(
      analysis.earliestStartById['build'],
      start.add(const Duration(hours: 2)),
    );
    expect(
      analysis.earliestStartById['launch'],
      start.add(const Duration(hours: 5)),
    );
    expect(analysis.criticalPath.map((entry) => entry.id), <Object>[
      'design',
      'build',
      'launch',
    ]);
    expect(analysis.projectEnd, start.add(const Duration(hours: 6)));
    expect(analysis.latestStartById['design'], start);
    expect(analysis.slackById['build'], Duration.zero);
    expect(analysis.criticalDependencyIds, <Object>{'d-b', 'b-l'});
    expect(analysis.criticalEntryIds, <Object>{'design', 'build', 'launch'});
  });

  test('dependency engine exposes slack for non-critical work', () {
    final start = DateTime(2026, 7, 13, 9);
    final analysis = TimelineDependencyEngine.analyze<String>(
      entries: <TimelineEntry<String>>[
        TimelineEntry<String>(
          id: 'critical-start',
          value: 'Critical start',
          start: start,
          duration: const Duration(hours: 2),
        ),
        TimelineEntry<String>(
          id: 'critical-end',
          value: 'Critical end',
          start: start,
          duration: const Duration(hours: 1),
        ),
        TimelineEntry<String>(
          id: 'parallel',
          value: 'Parallel',
          start: start,
          duration: const Duration(hours: 1),
        ),
      ],
      dependencies: const <TimelineDependency>[
        TimelineDependency(
          id: 'critical',
          predecessorId: 'critical-start',
          successorId: 'critical-end',
        ),
      ],
    );

    expect(analysis.projectEnd, start.add(const Duration(hours: 3)));
    expect(analysis.slackById['parallel'], const Duration(hours: 2));
    expect(analysis.criticalEntryIds, isNot(contains('parallel')));
    expect(
      analysis.criticalEntryIds,
      containsAll(<Object>['critical-start', 'critical-end']),
    );
  });

  test('dependency engine rejects duplicate entry and edge IDs', () {
    final start = DateTime(2026, 7, 13, 9);
    final analysis = TimelineDependencyEngine.analyze<String>(
      entries: <TimelineEntry<String>>[
        TimelineEntry<String>(id: 'same', value: 'First', start: start),
        TimelineEntry<String>(id: 'same', value: 'Second', start: start),
        TimelineEntry<String>(id: 'target', value: 'Target', start: start),
      ],
      dependencies: const <TimelineDependency>[
        TimelineDependency(
          id: 'edge',
          predecessorId: 'same',
          successorId: 'target',
        ),
        TimelineDependency(
          id: 'edge',
          predecessorId: 'target',
          successorId: 'same',
        ),
      ],
    );

    expect(analysis.isValid, isFalse);
    expect(
      analysis.issues.map((issue) => issue.type),
      containsAll(<TimelineDependencyIssueType>[
        TimelineDependencyIssueType.duplicateEntryId,
        TimelineDependencyIssueType.duplicateDependencyId,
      ]),
    );
  });

  test('dependency engine reports cycles', () {
    final entries = <TimelineEntry<String>>[
      TimelineEntry<String>(id: 'a', value: 'A', start: DateTime(2026)),
      TimelineEntry<String>(id: 'b', value: 'B', start: DateTime(2026)),
    ];
    final analysis = TimelineDependencyEngine.analyze<String>(
      entries: entries,
      dependencies: const <TimelineDependency>[
        TimelineDependency(id: 'a-b', predecessorId: 'a', successorId: 'b'),
        TimelineDependency(id: 'b-a', predecessorId: 'b', successorId: 'a'),
      ],
    );

    expect(analysis.hasCycle, isTrue);
    expect(analysis.topologicalEntries, isEmpty);
  });

  test('capacity engine emits only the overbooked interval', () {
    final entries = <TimelineEntry<String>>[
      TimelineEntry<String>(
        id: 'one',
        value: 'One',
        start: DateTime(2026, 7, 13, 9),
        duration: const Duration(hours: 2),
        resourceIds: const <Object>{'room'},
      ),
      TimelineEntry<String>(
        id: 'two',
        value: 'Two',
        start: DateTime(2026, 7, 13, 10),
        duration: const Duration(hours: 2),
        resourceIds: const <Object>{'room'},
      ),
    ];
    final conflicts = TimelineCapacityEngine.analyze<String>(
      entries: entries,
      resources: const <TimelineResourceCapacity>[
        TimelineResourceCapacity(id: 'room'),
      ],
    );

    expect(conflicts, hasLength(1));
    expect(conflicts.single.start, DateTime(2026, 7, 13, 10));
    expect(conflicts.single.end, DateTime(2026, 7, 13, 11));
    expect(conflicts.single.load, 2);
    expect(conflicts.single.overload, 1);
  });

  test('capacity engine keeps entries with duplicate IDs independent', () {
    final entries = <TimelineEntry<String>>[
      TimelineEntry<String>(
        id: 'duplicate',
        value: 'One',
        start: DateTime(2026, 7, 13, 9),
        duration: const Duration(hours: 2),
        resourceIds: const <Object>{'room'},
      ),
      TimelineEntry<String>(
        id: 'duplicate',
        value: 'Two',
        start: DateTime(2026, 7, 13, 10),
        duration: const Duration(hours: 2),
        resourceIds: const <Object>{'room'},
      ),
    ];

    final conflicts = TimelineCapacityEngine.analyze<String>(
      entries: entries,
      resources: const <TimelineResourceCapacity>[
        TimelineResourceCapacity(id: 'room'),
      ],
    );

    expect(conflicts, hasLength(1));
    expect(conflicts.single.entries, hasLength(2));
  });
}
