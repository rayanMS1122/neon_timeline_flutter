import '../../v10/core/timeline_magnetic_reschedule.dart';
import '../../v4/core/timeline_controller.dart';
import '../../v4/models/timeline_entry.dart';
import '../../v6/core/timeline_reschedule.dart';

/// Keeps a drag stable while the host delivers live data updates.
class TimelineLiveDragSession<T> {
  TimelineLiveDragSession({
    required this.entry,
    required this.bounds,
    required Iterable<TimelineEntry<T>> candidates,
    this.policy = const TimelineReschedulePolicy(),
    this.magnetDistance = const Duration(minutes: 8),
    this.hysteresis = const Duration(minutes: 2),
  }) : _candidates = List<TimelineEntry<T>>.unmodifiable(candidates) {
    _rebuild();
  }

  final TimelineEntry<T> entry;
  final TimelineDateRange bounds;
  final TimelineReschedulePolicy policy;
  final Duration magnetDistance;
  final Duration hysteresis;
  List<TimelineEntry<T>> _candidates;
  late TimelineMagneticRescheduleEngine<T> _engine;
  TimelineMagneticPreview<T>? _last;

  TimelineMagneticPreview<T> preview(Duration delta) {
    final next = _engine.previewForDelta(delta);
    final last = _last;
    if (last != null && last.magnetized && next.magnetized) {
      final drift = next.preview.start.difference(last.preview.start).abs();
      if (drift <= hysteresis &&
          next.preview.conflicts.length >= last.preview.conflicts.length) {
        return last;
      }
    }
    _last = next;
    return next;
  }

  void updateCandidates(Iterable<TimelineEntry<T>> candidates) {
    _candidates = List<TimelineEntry<T>>.unmodifiable(candidates);
    _rebuild();
  }

  void _rebuild() {
    _engine = TimelineMagneticRescheduleEngine<T>(
      entry: entry,
      bounds: bounds,
      candidates: _candidates,
      policy: policy,
      magnetDistance: magnetDistance,
    );
  }
}
