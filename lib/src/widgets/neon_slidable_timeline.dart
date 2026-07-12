import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import '../theme/neon_timeline_theme.dart';

/// Motion used by the underlying `flutter_slidable` action pane.
enum NeonSlidableMotion { behind, drawer, scroll, stretch }

/// Async-capable callback used by a slide action.
typedef NeonTimelineActionCallback = FutureOr<void> Function(
  BuildContext context,
);

/// Async-capable full-swipe callback.
typedef NeonTimelineDismissCallback = FutureOr<void> Function();

/// Receives an asynchronous slide-action or dismissal failure.
typedef NeonTimelineAsyncErrorCallback = void Function(
  Object error,
  StackTrace stackTrace,
);

/// Immutable action description for [NeonSlidableTimeline].
@immutable
class NeonTimelineAction {
  const NeonTimelineAction({
    required this.icon,
    required this.label,
    required this.onPressed,
    required this.color,
    this.foregroundColor = Colors.white,
    this.flex = 1,
    this.autoClose = true,
    this.enabled = true,
    this.showProgressIndicator = true,
    this.semanticLabel,
    this.tooltip,
    this.child,
  }) : assert(flex > 0);

  final IconData icon;
  final String label;
  final NeonTimelineActionCallback onPressed;
  final Color color;
  final Color foregroundColor;
  final int flex;
  final bool autoClose;

  /// Whether this action accepts interaction.
  final bool enabled;

  /// Whether a compact busy indicator replaces the icon during async work.
  final bool showProgressIndicator;

  final String? semanticLabel;
  final String? tooltip;

  /// Optional fully custom action content.
  final Widget? child;
}

/// A publication-ready facade over `flutter_slidable` for timeline content.
///
/// A single operation lock covers every action and full-swipe callback of one
/// row. This prevents duplicate writes when users tap or swipe repeatedly.
class NeonSlidableTimeline extends StatefulWidget {
  const NeonSlidableTimeline({
    required this.child,
    this.slidableKey,
    this.startActions = const <NeonTimelineAction>[],
    this.endActions = const <NeonTimelineAction>[],
    this.motion = NeonSlidableMotion.scroll,
    this.startExtentRatio = 0.28,
    this.endExtentRatio = 0.28,
    this.openThreshold = 0.34,
    this.closeThreshold = 0.22,
    this.enabled = true,
    this.closeOnScroll = true,
    this.groupTag,
    this.borderRadius = const BorderRadius.all(Radius.circular(22)),
    this.onStartDismissed,
    this.onEndDismissed,
    this.onError,
    this.onBusyChanged,
    this.dragDismissible = true,
    super.key,
  })  : assert(startExtentRatio > 0 && startExtentRatio <= 1),
        assert(endExtentRatio > 0 && endExtentRatio <= 1),
        assert(openThreshold >= 0 && openThreshold <= 1),
        assert(closeThreshold >= 0 && closeThreshold <= 1);

  final Widget child;
  final Key? slidableKey;
  final List<NeonTimelineAction> startActions;
  final List<NeonTimelineAction> endActions;
  final NeonSlidableMotion motion;
  final double startExtentRatio;
  final double endExtentRatio;
  final double openThreshold;
  final double closeThreshold;
  final bool enabled;
  final bool closeOnScroll;
  final Object? groupTag;
  final BorderRadius borderRadius;
  final NeonTimelineDismissCallback? onStartDismissed;
  final NeonTimelineDismissCallback? onEndDismissed;
  final NeonTimelineAsyncErrorCallback? onError;
  final ValueChanged<bool>? onBusyChanged;
  final bool dragDismissible;

  @override
  State<NeonSlidableTimeline> createState() =>
      _NeonSlidableTimelineState();
}

class _NeonSlidableTimelineState extends State<NeonSlidableTimeline> {
  bool _busy = false;
  NeonTimelineAction? _busyAction;
  int _operationGeneration = 0;

  Future<void> _runGuarded(
    FutureOr<void> Function() callback, {
    NeonTimelineAction? action,
  }) async {
    if (_busy || !widget.enabled) return;
    final generation = ++_operationGeneration;
    if (mounted) {
      setState(() {
        _busy = true;
        _busyAction = action;
      });
      _notifyBusyChanged(true);
    }
    try {
      await Future<void>.sync(callback);
    } catch (error, stackTrace) {
      _reportError(error, stackTrace);
    } finally {
      if (generation == _operationGeneration && mounted) {
        setState(() {
          _busy = false;
          _busyAction = null;
        });
        _notifyBusyChanged(false);
      }
    }
  }


  void _notifyBusyChanged(bool value) {
    final callback = widget.onBusyChanged;
    if (callback == null) return;
    try {
      callback(value);
    } catch (error, stackTrace) {
      _reportError(error, stackTrace);
    }
  }

  void _reportError(Object error, StackTrace stackTrace) {
    final handler = widget.onError;
    if (handler != null) {
      try {
        handler(error, stackTrace);
        return;
      } catch (handlerError, handlerStackTrace) {
        FlutterError.reportError(FlutterErrorDetails(
          exception: handlerError,
          stack: handlerStackTrace,
          library: 'neon_timeline_flutter',
          context: ErrorDescription('while reporting a slidable error'),
          informationCollector: () sync* {
            yield ErrorDescription('Original error: $error');
          },
        ));
        return;
      }
    }
    FlutterError.reportError(FlutterErrorDetails(
      exception: error,
      stack: stackTrace,
      library: 'neon_timeline_flutter',
      context: ErrorDescription('while running a slidable timeline action'),
    ));
  }

  @override
  Widget build(BuildContext context) {
    if (widget.startActions.isEmpty && widget.endActions.isEmpty) {
      return widget.child;
    }

    return ClipRRect(
      borderRadius: widget.borderRadius,
      clipBehavior: Clip.hardEdge,
      child: Slidable(
        key: widget.slidableKey ?? widget.child.key,
        enabled: widget.enabled && !_busy,
        closeOnScroll: widget.closeOnScroll,
        groupTag: widget.groupTag,
        startActionPane: widget.startActions.isEmpty
            ? null
            : _buildPane(
                actions: widget.startActions,
                extentRatio: widget.startExtentRatio,
                onDismissed: widget.onStartDismissed,
              ),
        endActionPane: widget.endActions.isEmpty
            ? null
            : _buildPane(
                actions: widget.endActions,
                extentRatio: widget.endExtentRatio,
                onDismissed: widget.onEndDismissed,
              ),
        child: widget.child,
      ),
    );
  }

  ActionPane _buildPane({
    required List<NeonTimelineAction> actions,
    required double extentRatio,
    required NeonTimelineDismissCallback? onDismissed,
  }) {
    final safeExtentRatio = extentRatio.clamp(0.05, 1.0).toDouble();
    final safeOpenThreshold = widget.openThreshold.clamp(0.0, 1.0).toDouble();
    final safeCloseThreshold = widget.closeThreshold
        .clamp(0.0, safeOpenThreshold)
        .toDouble();

    return ActionPane(
      motion: _motionWidget(),
      extentRatio: safeExtentRatio,
      openThreshold: safeOpenThreshold,
      closeThreshold: safeCloseThreshold,
      dragDismissible:
          widget.dragDismissible && onDismissed != null && !_busy,
      dismissible: onDismissed == null
          ? null
          : DismissiblePane(
              onDismissed: () {
                if (!_busy) unawaited(_runGuarded(onDismissed));
              },
            ),
      children: actions
          .map(
            (action) => _NeonSlidableAction(
              action: action,
              borderRadius: widget.borderRadius,
              busy: identical(_busyAction, action),
              blocked: _busy,
              onPressed: (context) {
                if (action.enabled && !_busy) {
                  unawaited(
                    _runGuarded(
                      () => action.onPressed(context),
                      action: action,
                    ),
                  );
                }
              },
            ),
          )
          .toList(growable: false),
    );
  }

  Widget _motionWidget() {
    return switch (widget.motion) {
      NeonSlidableMotion.behind => const BehindMotion(),
      NeonSlidableMotion.drawer => const DrawerMotion(),
      NeonSlidableMotion.scroll => const ScrollMotion(),
      NeonSlidableMotion.stretch => const StretchMotion(),
    };
  }
}

class _NeonSlidableAction extends StatelessWidget {
  const _NeonSlidableAction({
    required this.action,
    required this.borderRadius,
    required this.busy,
    required this.blocked,
    required this.onPressed,
  });

  final NeonTimelineAction action;
  final BorderRadius borderRadius;
  final bool busy;
  final bool blocked;
  final ValueChanged<BuildContext> onPressed;

  @override
  Widget build(BuildContext context) {
    final timelineTheme = NeonTimelineTheme.of(context);
    final color = action.color;
    final enabled = action.enabled && !blocked;

    Widget content = action.child ??
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              if (busy && action.showProgressIndicator)
                SizedBox.square(
                  dimension: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: action.foregroundColor,
                  ),
                )
              else
                Icon(
                  action.icon,
                  color: action.foregroundColor,
                  size: 22,
                ),
              const SizedBox(height: 5),
              Text(
                action.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: action.foregroundColor,
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.45,
                ),
              ),
            ],
          ),
        );

    if (action.tooltip != null) {
      content = Tooltip(message: action.tooltip!, child: content);
    }

    return CustomSlidableAction(
      flex: action.flex.clamp(1, 1000).toInt(),
      autoClose: action.autoClose,
      padding: EdgeInsets.zero,
      backgroundColor: Colors.transparent,
      foregroundColor: action.foregroundColor,
      onPressed: enabled ? onPressed : null,
      child: RepaintBoundary(
        child: Semantics(
          button: true,
          enabled: enabled,
          label: action.semanticLabel ?? action.label,
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 120),
            opacity: enabled ? 1 : 0.68,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: <Color>[
                    color.withOpacity(0.96),
                    Color.lerp(color, timelineTheme.surfaceColor, 0.28)!
                        .withOpacity(0.98),
                  ],
                ),
                borderRadius: borderRadius,
                border: Border.all(color: Colors.white.withOpacity(0.13)),
                boxShadow: <BoxShadow>[
                  BoxShadow(
                    color: color.withOpacity(0.30),
                    blurRadius: 22,
                    spreadRadius: -8,
                  ),
                ],
              ),
              child: IgnorePointer(ignoring: !enabled, child: content),
            ),
          ),
        ),
      ),
    );
  }
}
