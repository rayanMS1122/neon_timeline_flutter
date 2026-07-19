import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:neon_timeline_flutter/timeline_core.dart';
import 'package:neon_timeline_flutter/timeline_extensions.dart';
import 'package:neon_timeline_flutter/timeline_interactions.dart';

void main() {
  test('list data source publishes immutable revisions', () {
    final source = ListTimelineDataSource<String>();
    var notifications = 0;
    source.addListener(() => notifications++);

    source.replaceAll(<TimelineEntry<String>>[
      TimelineEntry<String>(
        id: 'one',
        value: 'One',
        start: DateTime(2026, 7, 13),
      ),
    ]);

    expect(source.revision, 1);
    expect(source.entries, hasLength(1));
    expect(notifications, 1);
    expect(
      () => source.entries.add(
        TimelineEntry<String>(
          id: 'two',
          value: 'Two',
          start: DateTime(2026, 7, 13),
        ),
      ),
      throwsUnsupportedError,
    );
  });

  test('command history serializes run, undo, and redo', () async {
    final state = <String>[];
    final history = TimelineCommandHistory();
    final command = _ListCommand(state, 'entry');

    await history.run(command);
    expect(state, <String>['entry']);
    expect(history.canUndo, isTrue);

    await history.undo();
    expect(state, isEmpty);
    expect(history.canRedo, isTrue);

    await history.redo();
    expect(state, <String>['entry']);
  });

  test('command history ignores late notifications after dispose', () async {
    final completer = Completer<void>();
    final history = TimelineCommandHistory();
    final run = history.run(_DeferredCommand(completer));

    history.dispose();
    completer.complete();

    await expectLater(run, completes);
    expect(history.canUndo, isFalse);
    expect(history.canRedo, isFalse);
  });

  test('plugin registry rejects accidental replacement', () {
    final registry = TimelinePluginRegistry();
    const plugin = _TestPlugin('renderer');

    registry.register(plugin);
    expect(
      registry.supporting(TimelinePluginCapability.renderer),
      <TimelinePlugin>[plugin],
    );
    expect(() => registry.register(plugin), throwsStateError);
    expect(registry.unregister(plugin.id), isTrue);
  });
}

class _ListCommand implements TimelineCommand {
  _ListCommand(this.target, this.value);

  final List<String> target;
  final String value;

  @override
  String get label => 'Add $value';

  @override
  FutureOr<void> execute() {
    target.add(value);
  }

  @override
  FutureOr<void> undo() {
    target.remove(value);
  }
}

class _TestPlugin implements TimelinePlugin {
  const _TestPlugin(this.id);

  @override
  final String id;

  @override
  String get version => '1.0.0';

  @override
  Set<TimelinePluginCapability> get capabilities =>
      const <TimelinePluginCapability>{TimelinePluginCapability.renderer};
}

class _DeferredCommand implements TimelineCommand {
  _DeferredCommand(this.completer);

  final Completer<void> completer;

  @override
  String get label => 'Deferred';

  @override
  Future<void> execute() => completer.future;

  @override
  void undo() {}
}
