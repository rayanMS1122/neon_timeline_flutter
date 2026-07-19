import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../v10/models/structured_timeline_experience.dart';
import '../../api/ultra_timeline_config.dart';
import '../../api/ultra_timeline_controller.dart';
import '../../domain/ultra_time_range.dart';
import '../../presentation/ultra_timeline_presentation.dart';
import '../../theme/ultra_timeline_theme.dart';
import '../controls/ultra_time_range_slider.dart';
import 'ultra_command_island.dart';
import 'ultra_control_dock.dart';
import 'ultra_drag_status_bar.dart';
import 'ultra_metric_strip.dart';

class UltraPlannerWorkspace<T> extends StatelessWidget {
  const UltraPlannerWorkspace({
    required this.title,
    required this.dateLabel,
    required this.controller,
    required this.config,
    required this.dragStateListenable,
    required this.child,
    this.subtitle,
    this.metrics = const <UltraTimelineMetric>[],
    this.actions = const <UltraTimelineAction>[],
    this.onPreviousDate,
    this.onNextDate,
    this.onToday,
    this.onSearch,
    this.onCreate,
    this.onSettings,
    this.onCancelDrag,
    this.onRangePreview,
    this.onRangeCommit,
    this.avatar,
    super.key,
  });

  final String title;
  final String? subtitle;
  final String dateLabel;
  final UltraTimelineController controller;
  final UltraTimelineConfig config;
  final ValueListenable<StructuredTimelineDragState<T>> dragStateListenable;
  final Widget child;
  final List<UltraTimelineMetric> metrics;
  final List<UltraTimelineAction> actions;
  final VoidCallback? onPreviousDate;
  final VoidCallback? onNextDate;
  final VoidCallback? onToday;
  final VoidCallback? onSearch;
  final VoidCallback? onCreate;
  final VoidCallback? onSettings;
  final VoidCallback? onCancelDrag;
  final ValueChanged<UltraTimeRange>? onRangePreview;
  final ValueChanged<UltraTimeRange>? onRangeCommit;
  final Widget? avatar;

  @override
  Widget build(BuildContext context) {
    final theme = UltraTimelineTheme.of(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        final textScale = MediaQuery.textScalerOf(context).scale(1);
        final compact = constraints.maxWidth < 720 || textScale > 1.35;
        final boundedHeight = constraints.hasBoundedHeight;
        final body = ColoredBox(
          color: theme.background,
          child: SafeArea(
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                compact ? 8 : 14,
                compact ? 8 : 12,
                compact ? 8 : 14,
                8,
              ),
              child: Column(
                children: [
                  UltraCommandIsland(
                    title: title,
                    subtitle: subtitle,
                    dateLabel: dateLabel,
                    onPreviousDate: onPreviousDate,
                    onNextDate: onNextDate,
                    onToday: onToday,
                    onSearch: onSearch,
                    onCreate: onCreate,
                    onSettings: onSettings,
                    actions: actions,
                    avatar: avatar,
                    compact: compact,
                  ),
                  if (config.showMetrics && metrics.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    UltraMetricStrip(metrics: metrics),
                  ],
                  const SizedBox(height: 8),
                  Expanded(
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              color: theme.canvas,
                              borderRadius: BorderRadius.circular(
                                compact ? theme.radiusLarge : theme.radiusPanel,
                              ),
                              border: Border.all(color: theme.outline),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(
                                compact ? theme.radiusLarge : theme.radiusPanel,
                              ),
                              child: child,
                            ),
                          ),
                        ),
                        PositionedDirectional(
                          start: 12,
                          end: 12,
                          bottom: 10,
                          child: Align(
                            alignment: AlignmentDirectional.bottomCenter,
                            child: UltraControlDock(
                              controller: controller,
                              config: config,
                              compact: compact,
                              onNow: onToday,
                              onFit: controller.resetZoom,
                            ),
                          ),
                        ),
                        PositionedDirectional(
                          start: 12,
                          end: 12,
                          bottom: compact ? 74 : 78,
                          child: Align(
                            alignment: AlignmentDirectional.bottomCenter,
                            child: UltraDragStatusBar<T>(
                              stateListenable: dragStateListenable,
                              onCancel: onCancelDrag,
                            ),
                          ),
                        ),
                        PositionedDirectional(
                          start: compact ? 8 : 24,
                          end: compact ? 8 : 24,
                          bottom: compact ? 76 : 82,
                          child: _RangeEditorOverlay(
                            controller: controller,
                            config: config,
                            onPreview: onRangePreview,
                            onCommit: onRangeCommit,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
        if (boundedHeight) return body;
        return SizedBox(height: 780, child: body);
      },
    );
  }
}

class _RangeEditorOverlay extends StatelessWidget {
  const _RangeEditorOverlay({
    required this.controller,
    required this.config,
    this.onPreview,
    this.onCommit,
  });

  final UltraTimelineController controller;
  final UltraTimelineConfig config;
  final ValueChanged<UltraTimeRange>? onPreview;
  final ValueChanged<UltraTimeRange>? onCommit;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<UltraTimeRangeEditorState>(
      valueListenable: controller.rangeEditor,
      builder: (context, state, _) {
        final visible = config.enableRangeEditor &&
            state.visible &&
            state.range != null &&
            state.bounds != null;
        return AnimatedSwitcher(
          duration: config.reducedMotion ||
                  (MediaQuery.maybeOf(context)?.disableAnimations ?? false)
              ? Duration.zero
              : const Duration(milliseconds: 190),
          switchInCurve: Curves.easeOutCubic,
          switchOutCurve: Curves.easeInCubic,
          transitionBuilder: (child, animation) {
            return FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0.08),
                  end: Offset.zero,
                ).animate(animation),
                child: child,
              ),
            );
          },
          child: visible
              ? ConstrainedBox(
                  key: const ValueKey<String>('range-editor-visible'),
                  constraints: const BoxConstraints(maxWidth: 760),
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      UltraTimeRangeSlider(
                        range: state.range!,
                        bounds: state.bounds!,
                        blockedRanges: state.blockedRanges,
                        minimumDuration: config.minimumDuration,
                        step: config.snapInterval,
                        onChanged: (range) {
                          controller.updateTimeRange(range);
                          onPreview?.call(range);
                        },
                        onChangeEnd: onCommit,
                      ),
                      PositionedDirectional(
                        end: 8,
                        top: -8,
                        child: IconButton.filledTonal(
                          tooltip: 'Close time editor',
                          onPressed: controller.hideTimeRangeEditor,
                          icon: const Icon(Icons.close_rounded),
                        ),
                      ),
                    ],
                  ),
                )
              : const SizedBox.shrink(
                  key: ValueKey<String>('range-editor-hidden'),
                ),
        );
      },
    );
  }
}
