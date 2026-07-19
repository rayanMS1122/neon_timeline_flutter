import 'dart:async';

import 'package:flutter/foundation.dart';

/// Reversible timeline operation used for drag, resize and batch updates.
abstract interface class StructuredTimelineOperation {
  Object get id;
  FutureOr<void> apply();
  FutureOr<void> revert();
}

/// Bounded, async-safe undo/redo history.
class StructuredTimelineInteractionHistory extends ChangeNotifier {
  StructuredTimelineInteractionHistory({this.capacity = 50})
    : assert(capacity > 0);

  final int capacity;
  final List<StructuredTimelineOperation> _undo = [];
  final List<StructuredTimelineOperation> _redo = [];
  bool _busy = false;
  bool _disposed = false;

  bool get canUndo => _undo.isNotEmpty && !_busy;
  bool get canRedo => _redo.isNotEmpty && !_busy;
  bool get busy => _busy;

  Future<void> execute(StructuredTimelineOperation operation) async {
    if (_busy) throw StateError('A timeline operation is already running.');
    _busy = true;
    _emit();
    try {
      await operation.apply();
      if (_disposed) return;
      _undo.add(operation);
      if (_undo.length > capacity) _undo.removeAt(0);
      _redo.clear();
    } finally {
      _busy = false;
      _emit();
    }
  }

  Future<void> undo() async {
    if (!canUndo) return;
    final operation = _undo.removeLast();
    _busy = true;
    _emit();
    try {
      await operation.revert();
      if (!_disposed) _redo.add(operation);
    } catch (_) {
      if (!_disposed) _undo.add(operation);
      rethrow;
    } finally {
      _busy = false;
      _emit();
    }
  }

  Future<void> redo() async {
    if (!canRedo) return;
    final operation = _redo.removeLast();
    _busy = true;
    _emit();
    try {
      await operation.apply();
      if (!_disposed) _undo.add(operation);
    } catch (_) {
      if (!_disposed) _redo.add(operation);
      rethrow;
    } finally {
      _busy = false;
      _emit();
    }
  }

  void clear() {
    _undo.clear();
    _redo.clear();
    _emit();
  }

  void _emit() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
