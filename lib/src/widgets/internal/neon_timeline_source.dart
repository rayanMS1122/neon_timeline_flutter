import 'package:flutter/material.dart';

import '../../models/neon_timeline_item.dart';
import '../../models/neon_timeline_types.dart';
import '../../theme/neon_timeline_theme.dart';
import '../../utils/neon_timeline_duration.dart';
import '../neon_timeline_tile.dart';

/// Internal immutable adapter shared by box and sliver timelines.
@immutable
class NeonTimelineSource {
  const NeonTimelineSource.items(this.items)
      : itemCount = null,
        contentBuilder = null,
        oppositeContentBuilder = null,
        indicatorBuilder = null,
        statusBuilder = null,
        semanticLabelBuilder = null,
        onItemTap = null,
        connectorStyleBuilder = null,
        keyBuilder = null;

  const NeonTimelineSource.builder({
    required int this.itemCount,
    required this.contentBuilder,
    this.oppositeContentBuilder,
    this.indicatorBuilder,
    this.statusBuilder,
    this.semanticLabelBuilder,
    this.onItemTap,
    this.connectorStyleBuilder,
    this.keyBuilder,
  })  : assert(itemCount >= 0),
        items = null;

  final List<NeonTimelineItem>? items;
  final int? itemCount;
  final NeonTimelineContentBuilder? contentBuilder;
  final NeonTimelineContentBuilder? oppositeContentBuilder;
  final NeonTimelineContentBuilder? indicatorBuilder;
  final NeonTimelineStatusBuilder? statusBuilder;
  final NeonTimelineSemanticLabelBuilder? semanticLabelBuilder;
  final NeonTimelineItemCallback? onItemTap;
  final NeonTimelineConnectorStyleBuilder? connectorStyleBuilder;
  final NeonTimelineKeyBuilder? keyBuilder;

  int get length => items?.length ?? itemCount!;

  NeonTimelineStatus statusAt(int index) {
    return items?[index].status ??
        statusBuilder?.call(index) ??
        NeonTimelineStatus.pending;
  }

  Widget buildTile(
    BuildContext context,
    int index, {
    required Axis axis,
    required NeonTimelineLayout layout,
    required NeonTimelineThemeData theme,
    required bool animate,
    Set<int> animatedIndexes = const <int>{},
    double? itemExtent,
    double indicatorPosition = 0.5,
  }) {
    final status = statusAt(index);
    final details = NeonTimelineItemDetails(
      index: index,
      itemCount: length,
      axis: axis,
      layout: layout,
      textDirection: Directionality.of(context),
      status: status,
      previousStatus: index == 0 ? null : statusAt(index - 1),
      nextStatus: index == length - 1 ? null : statusAt(index + 1),
    );
    final item = items?[index];
    final baseConnectorStyle = item?.connectorStyle ??
        connectorStyleBuilder?.call(context, details) ??
        theme.connectorStyle;
    final currentColor = theme.colorForStatus(status);
    final beforeColor = theme.colorForStatus(
      details.previousStatus ?? status,
    );
    final afterColor = theme.colorForStatus(details.nextStatus ?? status);

    final itemKey = _resolveKey(context, details, item);
    final tile = NeonTimelineTile(
      content: item?.content ?? contentBuilder!(context, details),
      oppositeContent: item?.oppositeContent ??
          oppositeContentBuilder?.call(context, details),
      indicator: item?.indicator ?? indicatorBuilder?.call(context, details),
      axis: axis,
      layout: layout,
      status: status,
      isFirst: details.isFirst,
      isLast: details.isLast,
      alternate: !details.isEven,
      beforeConnectorStyle: baseConnectorStyle.copyWith(
        color: beforeColor,
        endColor: currentColor,
        phaseOffset: (index * 0.137) % 1,
        animated: baseConnectorStyle.animated &&
            (animatedIndexes.contains(index) ||
                animatedIndexes.contains(index - 1)),
      ),
      afterConnectorStyle: baseConnectorStyle.copyWith(
        color: currentColor,
        endColor: afterColor,
        phaseOffset: ((index + 0.5) * 0.137) % 1,
        animated: baseConnectorStyle.animated &&
            (animatedIndexes.contains(index) ||
                animatedIndexes.contains(index + 1)),
      ),
      indicatorPosition: indicatorPosition,
      animateIndicator: animatedIndexes.contains(index),
      extent: itemExtent,
      semanticLabel: item?.semanticLabel ??
          semanticLabelBuilder?.call(context, details) ??
          _defaultSemanticLabel(details),
      semanticIndex: index,
      onTap: item?.onTap ??
          (onItemTap == null ? null : () => onItemTap!(context, details)),
    );
    return KeyedSubtree(
      key: itemKey,
      child: _TimelineReveal(
        axis: axis,
        animate: animate,
        theme: theme,
        child: tile,
      ),
    );
  }

  Key _resolveKey(
    BuildContext context,
    NeonTimelineItemDetails details,
    NeonTimelineItem? item,
  ) {
    final customKey = keyBuilder?.call(context, details);
    if (customKey != null) return customKey;
    if (item?.id != null) return ValueKey<Object>(item!.id!);
    if (item != null) return ObjectKey(item);
    return ValueKey<int>(details.index);
  }

  String _defaultSemanticLabel(NeonTimelineItemDetails details) {
    return 'Timeline item ${details.index + 1} of ${details.itemCount}, '
        '${details.status.name}';
  }
}

class _TimelineReveal extends StatefulWidget {
  const _TimelineReveal({
    required this.axis,
    required this.animate,
    required this.theme,
    required this.child,
  });

  final Axis axis;
  final bool animate;
  final NeonTimelineThemeData theme;
  final Widget child;

  @override
  State<_TimelineReveal> createState() => _TimelineRevealState();
}

class _TimelineRevealState extends State<_TimelineReveal> {
  bool _reduceMotion = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _reduceMotion =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.animate || _reduceMotion) return widget.child;

    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: 1),
      duration: neonNonNegativeDuration(
        widget.theme.animationDuration,
        debugLabel: 'NeonTimelineThemeData.animationDuration',
      ),
      curve: widget.theme.animationCurve,
      child: widget.child,
      builder: (context, value, child) {
        final offset = 12 * (1 - value);
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: widget.axis == Axis.vertical
                ? Offset(0, offset)
                : Offset(offset, 0),
            child: child,
          ),
        );
      },
    );
  }
}
