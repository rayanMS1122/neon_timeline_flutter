import 'package:flutter/widgets.dart';

@immutable
class TimelineDiagnosticsSnapshot {
  const TimelineDiagnosticsSnapshot({
    this.totalEntries = 0,
    this.visibleEntries = 0,
    this.conflictGroups = 0,
    this.activeMotionListeners = 0,
    this.renderPlanBuilds = 0,
    this.builderCalls = 0,
    this.cacheHits = 0,
    this.cacheMisses = 0,
  });

  final int totalEntries;
  final int visibleEntries;
  final int conflictGroups;
  final int activeMotionListeners;
  final int renderPlanBuilds;
  final int builderCalls;
  final int cacheHits;
  final int cacheMisses;
}

/// Opt-in snapshot delivery. It creates no timer and no continuous work.
class TimelineDiagnostics extends StatefulWidget {
  const TimelineDiagnostics({
    required this.snapshot,
    required this.child,
    this.onSnapshot,
    super.key,
  });

  final TimelineDiagnosticsSnapshot snapshot;
  final ValueChanged<TimelineDiagnosticsSnapshot>? onSnapshot;
  final Widget child;

  @override
  State<TimelineDiagnostics> createState() => _TimelineDiagnosticsState();
}

class _TimelineDiagnosticsState extends State<TimelineDiagnostics> {
  @override
  void initState() {
    super.initState();
    _emit();
  }

  @override
  void didUpdateWidget(covariant TimelineDiagnostics oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.snapshot != widget.snapshot) _emit();
  }

  void _emit() {
    final callback = widget.onSnapshot;
    if (callback == null) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) callback(widget.snapshot);
    });
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
