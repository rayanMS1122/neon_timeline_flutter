// Public constructor parameter names intentionally stay free of private-field
// prefixes for source compatibility.
// ignore_for_file: prefer_initializing_formals

import 'package:flutter/foundation.dart';

import '../models/timeline_types.dart';

@immutable
class TimelineDateRange {
  TimelineDateRange(this.start, this.end)
    : assert(end.isAfter(start), 'end must be after start');

  final DateTime start;
  final DateTime end;

  Duration get duration => end.difference(start);

  bool contains(DateTime value) {
    return !value.isBefore(start) && value.isBefore(end);
  }

  bool intersects(TimelineDateRange other) {
    return start.isBefore(other.end) && end.isAfter(other.start);
  }

  TimelineDateRange shift(Duration offset) {
    return TimelineDateRange(start.add(offset), end.add(offset));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is TimelineDateRange && other.start == start && other.end == end;
  }

  @override
  int get hashCode => Object.hash(start, end);
}

/// Host-owned controller for selection, zoom, focus, and visible-range state.
class TimelineController<T> extends ChangeNotifier {
  TimelineController({
    Iterable<Object> selectedIds = const <Object>[],
    double zoom = 1,
    TimelineDateRange? visibleRange,
    Object? focusedId,
  }) : _selectedIds = Set<Object>.of(selectedIds),
       _zoom = _safeZoom(zoom),
       _visibleRange = visibleRange,
       _focusedId = focusedId;

  Set<Object> _selectedIds;
  double _zoom;
  TimelineDateRange? _visibleRange;
  Object? _focusedId;
  int _batchDepth = 0;
  bool _notificationPending = false;

  Set<Object> get selectedIds => Set<Object>.unmodifiable(_selectedIds);
  double get zoom => _zoom;
  TimelineDateRange? get visibleRange => _visibleRange;
  Object? get focusedId => _focusedId;
  bool get hasSelection => _selectedIds.isNotEmpty;

  bool isSelected(Object id) => _selectedIds.contains(id);
  bool isFocused(Object id) => _focusedId == id;

  void select(
    Object id, {
    TimelineSelectionMode mode = TimelineSelectionMode.single,
  }) {
    if (mode == TimelineSelectionMode.none) return;
    final next = mode == TimelineSelectionMode.single
        ? <Object>{id}
        : <Object>{..._selectedIds, id};
    _replaceSelection(next);
  }

  void selectOnly(Object id) => _replaceSelection(<Object>{id});

  void toggle(Object id) {
    final next = Set<Object>.of(_selectedIds);
    if (!next.add(id)) next.remove(id);
    _replaceSelection(next);
  }

  void setSelection(Iterable<Object> ids) {
    _replaceSelection(Set<Object>.of(ids));
  }

  void selectRange({
    required List<Object> orderedIds,
    required Object startId,
    required Object endId,
    bool addToSelection = false,
  }) {
    final start = orderedIds.indexOf(startId);
    final end = orderedIds.indexOf(endId);
    if (start < 0 || end < 0) return;
    final lower = start < end ? start : end;
    final upper = start < end ? end : start;
    final next = addToSelection ? Set<Object>.of(_selectedIds) : <Object>{};
    next.addAll(orderedIds.getRange(lower, upper + 1));
    _replaceSelection(next);
  }

  void clearSelection() => _replaceSelection(<Object>{});

  void setFocusedId(Object? id) {
    if (id == _focusedId) return;
    _focusedId = id;
    _notify();
  }

  void setZoom(double value) {
    final next = _safeZoom(value);
    if (next == _zoom) return;
    _zoom = next;
    _notify();
  }

  void zoomBy(double factor) {
    if (!factor.isFinite || factor <= 0) return;
    setZoom(_zoom * factor);
  }

  void setVisibleRange(TimelineDateRange? range) {
    if (range == _visibleRange) return;
    _visibleRange = range;
    _notify();
  }

  void panVisibleRange(Duration offset) {
    final range = _visibleRange;
    if (range == null || offset == Duration.zero) return;
    setVisibleRange(range.shift(offset));
  }

  /// Coalesces multiple changes into one notification.
  void batch(VoidCallback updates) {
    _batchDepth++;
    try {
      updates();
    } finally {
      _batchDepth--;
      if (_batchDepth == 0 && _notificationPending) {
        _notificationPending = false;
        notifyListeners();
      }
    }
  }

  void _replaceSelection(Set<Object> value) {
    if (setEquals(value, _selectedIds)) return;
    _selectedIds = value;
    _notify();
  }

  void _notify() {
    if (_batchDepth > 0) {
      _notificationPending = true;
      return;
    }
    notifyListeners();
  }

  static double _safeZoom(double value) {
    if (!value.isFinite) return 1;
    return value.clamp(0.25, 8).toDouble();
  }
}
