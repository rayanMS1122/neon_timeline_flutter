// Public constructor parameter names intentionally stay free of private-field
// prefixes for source compatibility.
// ignore_for_file: prefer_initializing_formals

import 'package:flutter/foundation.dart';

import '../../v4/core/timeline_controller.dart';

enum StructuredTimelineNavigationKind { now, entry, ensureVisible }

@immutable
class StructuredTimelineNavigationRequest {
  const StructuredTimelineNavigationRequest({
    required this.revision,
    required this.kind,
    this.entryId,
    this.animated = true,
  });

  final int revision;
  final StructuredTimelineNavigationKind kind;
  final Object? entryId;
  final bool animated;
}

@immutable
class StructuredTimelineNudgeRequest {
  const StructuredTimelineNudgeRequest({
    required this.revision,
    required this.entryId,
    required this.delta,
  });

  final int revision;
  final Object entryId;
  final Duration delta;
}

@immutable
class StructuredTimelineInvalidation {
  const StructuredTimelineInvalidation({
    required this.revision,
    this.entryIds = const <Object>{},
    this.range,
  });

  final int revision;
  final Set<Object> entryIds;
  final TimelineDateRange? range;
}

/// Host-owned controller for the advanced Structured timeline.
///
/// It coordinates navigation, selection, zoom, keyboard nudge requests, and
/// targeted invalidation. It never persists application data.
class StructuredTimelineController<T> extends ChangeNotifier {
  StructuredTimelineController({
    Object? selectedId,
    Object? focusedId,
    double zoom = 1,
    TimelineDateRange? visibleRange,
  }) : _selectedId = selectedId,
       _focusedId = focusedId,
       _zoom = _normalizeZoom(zoom),
       _visibleRange = visibleRange;

  Object? _selectedId;
  Object? _focusedId;
  Object? _draggingId;
  double _zoom;
  TimelineDateRange? _visibleRange;
  StructuredTimelineNavigationRequest? _navigationRequest;
  StructuredTimelineNudgeRequest? _nudgeRequest;
  StructuredTimelineInvalidation? _invalidation;
  int _revision = 0;

  Object? get selectedId => _selectedId;
  Object? get focusedId => _focusedId;
  Object? get draggingId => _draggingId;
  double get zoom => _zoom;
  TimelineDateRange? get visibleRange => _visibleRange;
  StructuredTimelineNavigationRequest? get navigationRequest =>
      _navigationRequest;
  StructuredTimelineNudgeRequest? get nudgeRequest => _nudgeRequest;
  StructuredTimelineInvalidation? get invalidation => _invalidation;

  bool isSelected(Object id) => id == _selectedId;
  bool isFocused(Object id) => id == _focusedId;
  bool isDragging(Object id) => id == _draggingId;

  void selectEntry(Object id, {bool focus = true}) {
    if (_selectedId == id && (!focus || _focusedId == id)) return;
    _selectedId = id;
    if (focus) _focusedId = id;
    notifyListeners();
  }

  void clearSelection() {
    if (_selectedId == null && _focusedId == null) return;
    _selectedId = null;
    _focusedId = null;
    notifyListeners();
  }

  void setFocusedEntry(Object? id) {
    if (_focusedId == id) return;
    _focusedId = id;
    notifyListeners();
  }

  void beginDrag(Object id) {
    if (_draggingId == id && _selectedId == id && _focusedId == id) return;
    _draggingId = id;
    _selectedId = id;
    _focusedId = id;
    notifyListeners();
  }

  void cancelDrag() {
    if (_draggingId == null) return;
    _draggingId = null;
    notifyListeners();
  }

  void endDrag() => cancelDrag();

  void jumpToNow({bool animated = true}) {
    _navigationRequest = StructuredTimelineNavigationRequest(
      revision: ++_revision,
      kind: StructuredTimelineNavigationKind.now,
      animated: animated,
    );
    notifyListeners();
  }

  void jumpToEntry(Object id, {bool animated = true}) {
    _navigationRequest = StructuredTimelineNavigationRequest(
      revision: ++_revision,
      kind: StructuredTimelineNavigationKind.entry,
      entryId: id,
      animated: animated,
    );
    notifyListeners();
  }

  void ensureEntryVisible(Object id, {bool animated = true}) {
    _navigationRequest = StructuredTimelineNavigationRequest(
      revision: ++_revision,
      kind: StructuredTimelineNavigationKind.ensureVisible,
      entryId: id,
      animated: animated,
    );
    notifyListeners();
  }

  void moveSelectionBy(Duration delta) {
    final id = _selectedId;
    if (id == null || delta == Duration.zero) return;
    _nudgeRequest = StructuredTimelineNudgeRequest(
      revision: ++_revision,
      entryId: id,
      delta: delta,
    );
    notifyListeners();
  }

  void setZoom(double value) {
    final next = _normalizeZoom(value);
    if (next == _zoom) return;
    _zoom = next;
    notifyListeners();
  }

  void zoomIn([double factor = 1.15]) {
    if (!factor.isFinite || factor <= 0) return;
    setZoom(_zoom * factor);
  }

  void zoomOut([double factor = 1.15]) {
    if (!factor.isFinite || factor <= 0) return;
    setZoom(_zoom / factor);
  }

  void resetZoom() => setZoom(1);

  void setVisibleRange(TimelineDateRange? range) {
    if (_visibleRange == range) return;
    _visibleRange = range;
    notifyListeners();
  }

  void invalidateEntry(Object id) {
    _invalidation = StructuredTimelineInvalidation(
      revision: ++_revision,
      entryIds: <Object>{id},
    );
    notifyListeners();
  }

  void invalidateEntries(Iterable<Object> ids) {
    final values = Set<Object>.of(ids);
    if (values.isEmpty) return;
    _invalidation = StructuredTimelineInvalidation(
      revision: ++_revision,
      entryIds: Set<Object>.unmodifiable(values),
    );
    notifyListeners();
  }

  void invalidateRange(TimelineDateRange range) {
    _invalidation = StructuredTimelineInvalidation(
      revision: ++_revision,
      range: range,
    );
    notifyListeners();
  }

  static double _normalizeZoom(double value) {
    if (!value.isFinite) return 1;
    return value.clamp(0.5, 3.0).toDouble();
  }
}
