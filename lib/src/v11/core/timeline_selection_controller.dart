import 'package:flutter/foundation.dart';

/// Controlled single/multi/range selection without coupling to application
/// models or persistence.
class StructuredTimelineSelectionController extends ChangeNotifier {
  StructuredTimelineSelectionController({Iterable<Object> selected = const []})
    : _selected = <Object>{...selected};

  final Set<Object> _selected;
  Object? _anchor;
  bool _disposed = false;

  Set<Object> get selected => Set<Object>.unmodifiable(_selected);
  Object? get anchor => _anchor;
  bool isSelected(Object id) => _selected.contains(id);

  void select(Object id, {bool additive = false}) {
    if (!additive) _selected.clear();
    _selected.add(id);
    _anchor = id;
    _emit();
  }

  void toggle(Object id) {
    _selected.contains(id) ? _selected.remove(id) : _selected.add(id);
    _anchor = id;
    _emit();
  }

  void selectRange(List<Object> orderedIds, Object endId) {
    final anchor = _anchor;
    if (anchor == null) {
      select(endId);
      return;
    }
    final a = orderedIds.indexOf(anchor);
    final b = orderedIds.indexOf(endId);
    if (a < 0 || b < 0) return;
    final low = a < b ? a : b;
    final high = a > b ? a : b;
    _selected
      ..clear()
      ..addAll(orderedIds.sublist(low, high + 1));
    _emit();
  }

  void clear() {
    if (_selected.isEmpty) return;
    _selected.clear();
    _anchor = null;
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
