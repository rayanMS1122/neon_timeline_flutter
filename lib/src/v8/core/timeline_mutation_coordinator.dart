import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../v4/models/timeline_entry.dart';

enum TimelineMutationType { move, resize, delete, complete, custom }

@immutable
class TimelineMutationRequest<T> {
  const TimelineMutationRequest({
    required this.type,
    required this.entry,
    this.proposedStart,
    this.proposedEnd,
    this.metadata = const <String, Object?>{},
  });

  final TimelineMutationType type;
  final TimelineEntry<T> entry;
  final DateTime? proposedStart;
  final DateTime? proposedEnd;
  final Map<String, Object?> metadata;
}

enum TimelineMutationDisposition { committed, rejectedBusy, failed, rolledBack }

@immutable
class TimelineMutationResult<T> {
  const TimelineMutationResult({
    required this.request,
    required this.disposition,
    this.error,
    this.stackTrace,
  });

  final TimelineMutationRequest<T> request;
  final TimelineMutationDisposition disposition;
  final Object? error;
  final StackTrace? stackTrace;

  bool get succeeded => disposition == TimelineMutationDisposition.committed;
}

typedef TimelineMutationCommit<T> =
    FutureOr<void> Function(TimelineMutationRequest<T> request);

typedef TimelineMutationRollback<T> =
    FutureOr<void> Function(
      TimelineMutationRequest<T> request,
      Object error,
      StackTrace stackTrace,
    );

/// Coordinates asynchronous timeline mutations without owning app data.
///
/// A single entry can have at most one active mutation. Late completions after
/// disposal never notify listeners.
class TimelineMutationCoordinator<T> extends ChangeNotifier {
  final Set<Object> _busyIds = <Object>{};
  bool _disposed = false;

  Set<Object> get busyIds => Set<Object>.unmodifiable(_busyIds);
  bool get hasBusyEntries => _busyIds.isNotEmpty;
  bool isBusy(Object id) => _busyIds.contains(id);

  Future<TimelineMutationResult<T>> execute({
    required TimelineMutationRequest<T> request,
    required TimelineMutationCommit<T> commit,
    TimelineMutationRollback<T>? rollback,
  }) async {
    final id = request.entry.id;
    if (_disposed || _busyIds.contains(id)) {
      return TimelineMutationResult<T>(
        request: request,
        disposition: TimelineMutationDisposition.rejectedBusy,
      );
    }

    _busyIds.add(id);
    _safeNotify();
    try {
      await Future<void>.sync(() => commit(request));
      return TimelineMutationResult<T>(
        request: request,
        disposition: TimelineMutationDisposition.committed,
      );
    } catch (error, stackTrace) {
      if (rollback != null) {
        try {
          await Future<void>.sync(() => rollback(request, error, stackTrace));
          return TimelineMutationResult<T>(
            request: request,
            disposition: TimelineMutationDisposition.rolledBack,
            error: error,
            stackTrace: stackTrace,
          );
        } catch (_) {
          // The original error remains the useful failure signal.
        }
      }
      return TimelineMutationResult<T>(
        request: request,
        disposition: TimelineMutationDisposition.failed,
        error: error,
        stackTrace: stackTrace,
      );
    } finally {
      _busyIds.remove(id);
      _safeNotify();
    }
  }

  void _safeNotify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _busyIds.clear();
    super.dispose();
  }
}
