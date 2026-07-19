import 'package:flutter/foundation.dart' show setEquals;
import 'package:flutter/material.dart';

import '../core/timeline_controller.dart';
import '../core/timeline_planning.dart';
import '../models/timeline_entry.dart';
import '../models/timeline_types.dart';
import '../theme/timeline_theme.dart';

@immutable
class TimelineDependencyNodeDetails<T> {
  const TimelineDependencyNodeDetails({
    required this.entryDetails,
    required this.depth,
    required this.onCriticalPath,
    required this.latestStart,
    required this.slack,
    required this.hasGraphIssue,
  });

  final TimelineEntryDetails<T> entryDetails;
  final int depth;
  final bool onCriticalPath;
  final DateTime? latestStart;
  final Duration? slack;
  final bool hasGraphIssue;
}

typedef TimelineDependencyNodeBuilder<T> =
    Widget Function(
      BuildContext context,
      TimelineDependencyNodeDetails<T> details,
    );

/// Interactive dependency map with deterministic topological layers.
///
/// The view uses one static connector painter and regular positioned widgets.
/// It creates no ticker and remains idle until data or selection changes.
class DependencyTimelineView<T> extends StatelessWidget {
  const DependencyTimelineView({
    required this.entries,
    required this.dependencies,
    required this.itemBuilder,
    this.timelineController,
    this.onEntryTap,
    this.theme,
    this.nodeWidth = 260,
    this.nodeHeight = 126,
    this.horizontalGap = 92,
    this.verticalGap = 24,
    this.padding = const EdgeInsets.all(28),
    this.minScale = 0.45,
    this.maxScale = 2.4,
    this.panEnabled = true,
    this.scaleEnabled = true,
    super.key,
  }) : assert(nodeWidth >= 120),
       assert(nodeHeight >= 64),
       assert(horizontalGap >= 24),
       assert(verticalGap >= 0),
       assert(minScale > 0),
       assert(maxScale >= minScale);

  final List<TimelineEntry<T>> entries;
  final List<TimelineDependency> dependencies;
  final TimelineDependencyNodeBuilder<T> itemBuilder;
  final TimelineController<T>? timelineController;
  final TimelineEntryCallback<T>? onEntryTap;
  final TimelineThemeData? theme;
  final double nodeWidth;
  final double nodeHeight;
  final double horizontalGap;
  final double verticalGap;
  final EdgeInsets padding;
  final double minScale;
  final double maxScale;
  final bool panEnabled;
  final bool scaleEnabled;

  @override
  Widget build(BuildContext context) {
    final resolvedTheme = theme ?? TimelineTheme.of(context);
    final analysis = TimelineDependencyEngine.analyze<T>(
      entries: entries,
      dependencies: dependencies,
    );
    final layout = _DependencyLayout.build<T>(
      entries: entries,
      dependencies: dependencies,
      analysis: analysis,
      nodeWidth: nodeWidth,
      nodeHeight: nodeHeight,
      horizontalGap: horizontalGap,
      verticalGap: verticalGap,
      padding: padding,
    );

    Widget buildGraph() {
      return InteractiveViewer(
        constrained: false,
        boundaryMargin: const EdgeInsets.all(160),
        minScale: minScale,
        maxScale: maxScale,
        panEnabled: panEnabled,
        scaleEnabled: scaleEnabled,
        child: SizedBox(
          width: layout.size.width,
          height: layout.size.height,
          child: Stack(
            clipBehavior: Clip.none,
            children: <Widget>[
              Positioned.fill(
                child: RepaintBoundary(
                  child: CustomPaint(
                    painter: _DependencyConnectorPainter<T>(
                      theme: resolvedTheme,
                      nodes: layout.nodes,
                      dependencies: dependencies,
                      issueIds: layout.issueIds,
                      criticalIds: layout.criticalIds,
                      criticalDependencyIds: layout.criticalDependencyIds,
                    ),
                  ),
                ),
              ),
              for (var index = 0; index < layout.nodes.length; index++)
                _buildNode(context, layout, index, analysis, resolvedTheme),
            ],
          ),
        ),
      );
    }

    final controller = timelineController;
    return TimelineTheme(
      data: resolvedTheme,
      child: ColoredBox(
        color: resolvedTheme.backgroundColor,
        child: controller == null
            ? buildGraph()
            : AnimatedBuilder(
                animation: controller,
                builder: (_, __) => buildGraph(),
              ),
      ),
    );
  }

  Widget _buildNode(
    BuildContext context,
    _DependencyLayout<T> layout,
    int index,
    TimelineDependencyAnalysis<T> analysis,
    TimelineThemeData theme,
  ) {
    final node = layout.nodes[index];
    final previous = index > 0 ? layout.nodes[index - 1].entry : null;
    final next = index + 1 < layout.nodes.length
        ? layout.nodes[index + 1].entry
        : null;
    final details = TimelineEntryDetails<T>(
      entry: node.entry,
      index: index,
      itemCount: layout.nodes.length,
      displayStart:
          analysis.earliestStartById[node.entry.id] ?? node.entry.start,
      displayEnd:
          (analysis.earliestStartById[node.entry.id] ?? node.entry.start).add(
            node.entry.hasValidRange
                ? node.entry.rawDuration
                : const Duration(minutes: 1),
          ),
      previousEntry: previous,
      nextEntry: next,
      isCurrent: false,
      hasConflict: layout.issueIds.contains(node.entry.id),
      conflictType: layout.issueIds.contains(node.entry.id)
          ? TimelineConflictType.dependencyConflict
          : TimelineConflictType.none,
    );
    final selected = timelineController?.isSelected(node.entry.id) ?? false;

    return Positioned.fromRect(
      rect: node.rect,
      child: RepaintBoundary(
        child: Semantics(
          selected: selected,
          button: timelineController != null || onEntryTap != null,
          label: node.entry.semanticLabel,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(theme.cardRadius),
              onTap: timelineController == null && onEntryTap == null
                  ? null
                  : () {
                      timelineController?.selectOnly(node.entry.id);
                      onEntryTap?.call(context, details);
                    },
              child: itemBuilder(
                context,
                TimelineDependencyNodeDetails<T>(
                  entryDetails: details,
                  depth: node.depth,
                  onCriticalPath: layout.criticalIds.contains(node.entry.id),
                  latestStart: analysis.latestStartById[node.entry.id],
                  slack: analysis.slackById[node.entry.id],
                  hasGraphIssue: layout.issueIds.contains(node.entry.id),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

@immutable
class _DependencyNode<T> {
  const _DependencyNode({
    required this.entry,
    required this.depth,
    required this.rect,
  });

  final TimelineEntry<T> entry;
  final int depth;
  final Rect rect;
}

@immutable
class _DependencyLayout<T> {
  const _DependencyLayout({
    required this.nodes,
    required this.size,
    required this.criticalIds,
    required this.criticalDependencyIds,
    required this.issueIds,
  });

  final List<_DependencyNode<T>> nodes;
  final Size size;
  final Set<Object> criticalIds;
  final Set<Object> criticalDependencyIds;
  final Set<Object> issueIds;

  static _DependencyLayout<T> build<T>({
    required List<TimelineEntry<T>> entries,
    required List<TimelineDependency> dependencies,
    required TimelineDependencyAnalysis<T> analysis,
    required double nodeWidth,
    required double nodeHeight,
    required double horizontalGap,
    required double verticalGap,
    required EdgeInsets padding,
  }) {
    final byId = <Object, TimelineEntry<T>>{
      for (final entry in entries) entry.id: entry,
    };
    final depthById = <Object, int>{for (final entry in entries) entry.id: 0};
    final outgoing = <Object, List<TimelineDependency>>{};
    for (final dependency in dependencies) {
      if (!byId.containsKey(dependency.predecessorId) ||
          !byId.containsKey(dependency.successorId)) {
        continue;
      }
      outgoing
          .putIfAbsent(dependency.predecessorId, () => <TimelineDependency>[])
          .add(dependency);
    }
    for (final entry in analysis.topologicalEntries) {
      final depth = depthById[entry.id] ?? 0;
      for (final dependency
          in outgoing[entry.id] ?? const <TimelineDependency>[]) {
        final nextDepth = depth + 1;
        final current = depthById[dependency.successorId] ?? 0;
        if (nextDepth > current) {
          depthById[dependency.successorId] = nextDepth;
        }
      }
    }

    final issueIds = <Object>{};
    for (final issue in analysis.issues) {
      issueIds.addAll(issue.entryIds);
    }
    final criticalIds = analysis.criticalEntryIds.isNotEmpty
        ? analysis.criticalEntryIds
        : <Object>{for (final entry in analysis.criticalPath) entry.id};
    final topologicalIds = <Object>{
      for (final entry in analysis.topologicalEntries) entry.id,
    };
    final ordered = <TimelineEntry<T>>[
      ...analysis.topologicalEntries,
      ...entries.where((entry) => !topologicalIds.contains(entry.id)),
    ];
    final layers = <int, List<TimelineEntry<T>>>{};
    for (final entry in ordered) {
      final depth = depthById[entry.id] ?? 0;
      layers.putIfAbsent(depth, () => <TimelineEntry<T>>[]).add(entry);
    }

    final nodes = <_DependencyNode<T>>[];
    var maxRows = 1;
    var maxDepth = 0;
    for (final layer in layers.entries) {
      if (layer.value.length > maxRows) maxRows = layer.value.length;
      if (layer.key > maxDepth) maxDepth = layer.key;
      for (var row = 0; row < layer.value.length; row++) {
        final left = padding.left + layer.key * (nodeWidth + horizontalGap);
        final top = padding.top + row * (nodeHeight + verticalGap);
        nodes.add(
          _DependencyNode<T>(
            entry: layer.value[row],
            depth: layer.key,
            rect: Rect.fromLTWH(left, top, nodeWidth, nodeHeight),
          ),
        );
      }
    }

    final width =
        padding.horizontal +
        (maxDepth + 1) * nodeWidth +
        maxDepth * horizontalGap;
    final height =
        padding.vertical + maxRows * nodeHeight + (maxRows - 1) * verticalGap;
    return _DependencyLayout<T>(
      nodes: List<_DependencyNode<T>>.unmodifiable(nodes),
      size: Size(width, height),
      criticalIds: Set<Object>.unmodifiable(criticalIds),
      criticalDependencyIds: Set<Object>.unmodifiable(
        analysis.criticalDependencyIds,
      ),
      issueIds: Set<Object>.unmodifiable(issueIds),
    );
  }
}

class _DependencyConnectorPainter<T> extends CustomPainter {
  const _DependencyConnectorPainter({
    required this.theme,
    required this.nodes,
    required this.dependencies,
    required this.issueIds,
    required this.criticalIds,
    required this.criticalDependencyIds,
  });

  final TimelineThemeData theme;
  final List<_DependencyNode<T>> nodes;
  final List<TimelineDependency> dependencies;
  final Set<Object> issueIds;
  final Set<Object> criticalIds;
  final Set<Object> criticalDependencyIds;

  @override
  void paint(Canvas canvas, Size size) {
    final rectById = <Object, Rect>{
      for (final node in nodes) node.entry.id: node.rect,
    };
    for (final dependency in dependencies) {
      final from = rectById[dependency.predecessorId];
      final to = rectById[dependency.successorId];
      if (from == null || to == null) continue;
      final issue =
          issueIds.contains(dependency.predecessorId) ||
          issueIds.contains(dependency.successorId);
      final critical = criticalDependencyIds.contains(dependency.id);
      final color = issue
          ? theme.errorColor
          : critical
          ? theme.warningColor
          : theme.primaryColor.withAlpha(150);
      final paint = Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = critical ? 2.5 : 1.5
        ..strokeCap = StrokeCap.round;
      final start = Offset(from.right, from.center.dy);
      final end = Offset(to.left, to.center.dy);
      final bend = (end.dx - start.dx).abs().clamp(36.0, 120.0).toDouble();
      final path = Path()
        ..moveTo(start.dx, start.dy)
        ..cubicTo(
          start.dx + bend,
          start.dy,
          end.dx - bend,
          end.dy,
          end.dx,
          end.dy,
        );
      canvas.drawPath(path, paint);
      final arrow = Path()
        ..moveTo(end.dx, end.dy)
        ..lineTo(end.dx - 8, end.dy - 5)
        ..moveTo(end.dx, end.dy)
        ..lineTo(end.dx - 8, end.dy + 5);
      canvas.drawPath(arrow, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _DependencyConnectorPainter<T> oldDelegate) {
    return oldDelegate.theme != theme ||
        !identical(oldDelegate.nodes, nodes) ||
        !identical(oldDelegate.dependencies, dependencies) ||
        !setEquals(oldDelegate.issueIds, issueIds) ||
        !setEquals(oldDelegate.criticalIds, criticalIds) ||
        !setEquals(oldDelegate.criticalDependencyIds, criticalDependencyIds);
  }
}
