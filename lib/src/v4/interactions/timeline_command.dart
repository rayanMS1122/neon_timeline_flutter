import 'dart:async';

import 'package:flutter/foundation.dart';

/// Reversible application command used by direct manipulation and shortcuts.
abstract interface class TimelineCommand {
  String get label;
  FutureOr<void> execute();
  FutureOr<void> undo();
}

/// Serial command history with guarded undo and redo.
class TimelineCommandHistory extends ChangeNotifier {
  final List<TimelineCommand> _undo = <TimelineCommand>[];
  final List<TimelineCommand> _redo = <TimelineCommand>[];
  bool _busy = false;
  bool _disposed = false;

  bool get isBusy => _busy;
  bool get canUndo => !_disposed && !_busy && _undo.isNotEmpty;
  bool get canRedo => !_disposed && !_busy && _redo.isNotEmpty;
  int get undoCount => _undo.length;
  int get redoCount => _redo.length;

  Future<void> run(TimelineCommand command) async {
    if (_disposed) {
      throw StateError('TimelineCommandHistory has been disposed.');
    }
    if (_busy) throw StateError('A timeline command is already running.');
    _busy = true;
    _emit();
    try {
      await command.execute();
      if (_disposed) return;
      _undo.add(command);
      _redo.clear();
    } finally {
      _busy = false;
      _emit();
    }
  }

  Future<void> undo() async {
    if (!canUndo) return;
    final command = _undo.removeLast();
    _busy = true;
    _emit();
    try {
      await command.undo();
      if (_disposed) return;
      _redo.add(command);
    } catch (_) {
      if (!_disposed) _undo.add(command);
      rethrow;
    } finally {
      _busy = false;
      _emit();
    }
  }

  Future<void> redo() async {
    if (!canRedo) return;
    final command = _redo.removeLast();
    _busy = true;
    _emit();
    try {
      await command.execute();
      if (_disposed) return;
      _undo.add(command);
    } catch (_) {
      if (!_disposed) _redo.add(command);
      rethrow;
    } finally {
      _busy = false;
      _emit();
    }
  }

  void _emit() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _undo.clear();
    _redo.clear();
    super.dispose();
  }

  void clear() {
    if (_busy || (_undo.isEmpty && _redo.isEmpty)) return;
    _undo.clear();
    _redo.clear();
    _emit();
  }
}
