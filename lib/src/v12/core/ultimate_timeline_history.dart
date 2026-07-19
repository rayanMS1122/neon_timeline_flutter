import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../v11/core/timeline_interaction_history.dart';
import '../../v4/models/timeline_entry.dart';

/// Host-owned mutation invoked by reversible 12.x commands.
typedef UltimateTimelineMutation<T> =
    FutureOr<void> Function(
      TimelineEntry<T> entry,
      DateTime start,
      DateTime end,
    );

/// Typed reversible command for the 12.x timeline.
abstract class UltimateTimelineCommand<T>
    implements StructuredTimelineOperation {
  const UltimateTimelineCommand();
}

/// Reversible move command. Persistence remains owned by the host callback.
@immutable
class UltimateTimelineMoveCommand<T> extends UltimateTimelineCommand<T> {
  const UltimateTimelineMoveCommand({
    required this.entry,
    required this.fromStart,
    required this.fromEnd,
    required this.toStart,
    required this.toEnd,
    required this.mutate,
  });

  final TimelineEntry<T> entry;
  final DateTime fromStart;
  final DateTime fromEnd;
  final DateTime toStart;
  final DateTime toEnd;
  final UltimateTimelineMutation<T> mutate;

  @override
  Object get id => 'move:${entry.id}:$toStart';

  @override
  FutureOr<void> apply() => mutate(entry, toStart, toEnd);

  @override
  FutureOr<void> revert() => mutate(entry, fromStart, fromEnd);
}

/// Reversible resize command with the same host-owned mutation contract.
@immutable
class UltimateTimelineResizeCommand<T> extends UltimateTimelineCommand<T> {
  const UltimateTimelineResizeCommand({
    required this.entry,
    required this.fromStart,
    required this.fromEnd,
    required this.toStart,
    required this.toEnd,
    required this.mutate,
  });

  final TimelineEntry<T> entry;
  final DateTime fromStart;
  final DateTime fromEnd;
  final DateTime toStart;
  final DateTime toEnd;
  final UltimateTimelineMutation<T> mutate;

  @override
  Object get id => 'resize:${entry.id}:$toStart:$toEnd';

  @override
  FutureOr<void> apply() => mutate(entry, toStart, toEnd);

  @override
  FutureOr<void> revert() => mutate(entry, fromStart, fromEnd);
}

/// Applies a group move in order and reverts it in reverse order.
class UltimateTimelineBatchMoveCommand<T> extends UltimateTimelineCommand<T> {
  UltimateTimelineBatchMoveCommand({
    required Iterable<UltimateTimelineMoveCommand<T>> commands,
    Object? id,
  }) : commands = List<UltimateTimelineMoveCommand<T>>.unmodifiable(commands),
       _id = id ?? Object();

  final List<UltimateTimelineMoveCommand<T>> commands;
  final Object _id;

  @override
  Object get id => _id;

  @override
  Future<void> apply() async {
    for (final command in commands) {
      await command.apply();
    }
  }

  @override
  Future<void> revert() async {
    for (final command in commands.reversed) {
      await command.revert();
    }
  }
}

/// Typed facade over the bounded, async-safe 11.x history implementation.
class UltimateTimelineHistoryController<T>
    extends StructuredTimelineInteractionHistory {
  UltimateTimelineHistoryController({super.capacity = 50});

  Future<void> executeCommand(UltimateTimelineCommand<T> command) =>
      execute(command);
}
