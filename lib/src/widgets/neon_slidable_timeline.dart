import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import '../theme/neon_timeline_theme.dart';

/// Motion used by the underlying `flutter_slidable` action pane.
enum NeonSlidableMotion {
  /// Actions stay behind the moving child.
  behind,

  /// Actions open like a drawer.
  drawer,

  /// Actions move together with the child.
  scroll,

  /// Actions stretch while the child moves.
  stretch,
}

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
  /// Creates a timeline slide action.
  const NeonTimelineAction({
    required this.icon,
    required this.label,
    required this.onPressed,
    required this.color,
    this.foregroundColor = Colors.white,
    this.flex = 1,
    this.autoClose = true,
    this.semanticLabel,
    this.child,
  }) : assert(flex > 0);

  /// Action icon.
  final IconData icon;

  /// Short visible label.
  final String label;

  /// Action callback.
  final NeonTimelineActionCallback onPressed;

  /// Primary action color.
  final Color color;

  /// Icon and text color.
  final Color foregroundColor;

  /// Relative action width.
  final int flex;

  /// Whether the pane closes after activation.
  final bool autoClose;

  /// Optional screen-reader label.
  final String? semanticLabel;

  /// Optional fully custom action content.
  ///
  /// The package still paints the neon action surface and semantics.
  final Widget? child;
}

/// A publication-ready facade over `flutter_slidable` for timeline content.
///
/// The wrapper deliberately exposes package-owned action models instead of
/// leaking `flutter_slidable` widgets throughout an application's domain UI.
class NeonSlidableTimeline extends StatelessWidget {
  /// Creates a slidable timeline surface.
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
    this.dragDismissible = true,
    super.key,
  })  : assert(startExtentRatio > 0 && startExtentRatio <= 1),
        assert(endExtentRatio > 0 && endExtentRatio <= 1),
        assert(openThreshold >= 0 && openThreshold <= 1),
        assert(closeThreshold >= 0 && closeThreshold <= 1);

  /// Closed-state content.
  final Widget child;

  /// Stable key forwarded to the underlying slidable.
  ///
  /// Supply this when full-swipe dismissal is enabled. When omitted, the
  /// child's key is used if available.
  final Key? slidableKey;

  /// Actions revealed from the logical start side.
  final List<NeonTimelineAction> startActions;

  /// Actions revealed from the logical end side.
  final List<NeonTimelineAction> endActions;

  /// Action-pane motion.
  final NeonSlidableMotion motion;

  /// Maximum start-pane share of the child extent.
  final double startExtentRatio;

  /// Maximum end-pane share of the child extent.
  final double endExtentRatio;

  /// Drag fraction required to settle open.
  final double openThreshold;

  /// Drag fraction below which the pane settles closed.
  final double closeThreshold;

  /// Whether slide interaction is enabled.
  final bool enabled;

  /// Whether scrolling the nearest scroll view closes the pane.
  final bool closeOnScroll;

  /// Optional tag used by `flutter_slidable` auto-close groups.
  final Object? groupTag;

  /// Clipping radius shared by the card and action background.
  final BorderRadius borderRadius;

  /// Optional full-swipe callback from the logical start side.
  final NeonTimelineDismissCallback? onStartDismissed;

  /// Optional full-swipe callback from the logical end side.
  final NeonTimelineDismissCallback? onEndDismissed;

  /// Optional guarded-operation error callback.
  final NeonTimelineAsyncErrorCallback? onError;

  /// Whether a configured dismissible pane accepts drag dismissal.
  final bool dragDismissible;

  @override
  Widget build(BuildContext context) {
    if (startActions.isEmpty && endActions.isEmpty) return child;

    return ClipRRect(
      borderRadius: borderRadius,
      clipBehavior: Clip.hardEdge,
      child: Slidable(
        key: slidableKey ?? child.key,
        enabled: enabled,
        closeOnScroll: closeOnScroll,
        groupTag: groupTag,
        startActionPane: startActions.isEmpty
            ? null
            : _buildPane(
                actions: startActions,
                extentRatio: startExtentRatio,
                onDismissed: onStartDismissed,
              ),
        endActionPane: endActions.isEmpty
            ? null
            : _buildPane(
                actions: endActions,
                extentRatio: endExtentRatio,
                onDismissed: onEndDismissed,
              ),
        child: child,
      ),
    );
  }

  ActionPane _buildPane({
    required List<NeonTimelineAction> actions,
    required double extentRatio,
    required NeonTimelineDismissCallback? onDismissed,
  }) {
    final safeExtentRatio = extentRatio.clamp(0.05, 1.0).toDouble();
    final safeOpenThreshold = openThreshold.clamp(0.0, 1.0).toDouble();
    final safeCloseThreshold = closeThreshold
        .clamp(0.0, safeOpenThreshold)
        .toDouble();
    return ActionPane(
      motion: _motionWidget(),
      extentRatio: safeExtentRatio,
      openThreshold: safeOpenThreshold,
      closeThreshold: safeCloseThreshold,
      dragDismissible: dragDismissible && onDismissed != null,
      dismissible: onDismissed == null
          ? null
          : DismissiblePane(
              onDismissed: () {
                unawaited(_runGuarded(onDismissed));
              },
            ),
      children: actions
          .map((action) => _NeonSlidableAction(
                action: action,
                borderRadius: borderRadius,
                onError: onError,
              ))
          .toList(growable: false),
    );
  }

  Future<void> _runGuarded(FutureOr<void> Function() callback) async {
    try {
      await Future<void>.sync(callback);
    } catch (error, stackTrace) {
      final handler = onError;
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
  }

  Widget _motionWidget() {
    return switch (motion) {
      NeonSlidableMotion.behind => const BehindMotion(),
      NeonSlidableMotion.drawer => const DrawerMotion(),
      NeonSlidableMotion.scroll => const ScrollMotion(),
      NeonSlidableMotion.stretch => const StretchMotion(),
    };
  }
}

class _NeonSlidableAction extends StatefulWidget {
  const _NeonSlidableAction({
    required this.action,
    required this.borderRadius,
    required this.onError,
  });

  final NeonTimelineAction action;
  final BorderRadius borderRadius;
  final NeonTimelineAsyncErrorCallback? onError;

  @override
  State<_NeonSlidableAction> createState() => _NeonSlidableActionState();
}

class _NeonSlidableActionState extends State<_NeonSlidableAction> {
  bool _busy = false;

  Future<void> _runGuarded(BuildContext context) async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      await Future<void>.sync(() => widget.action.onPressed(context));
    } catch (error, stackTrace) {
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
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final timelineTheme = NeonTimelineTheme.of(context);
    final action = widget.action;
    final color = action.color;

    return CustomSlidableAction(
      flex: action.flex.clamp(1, 1000).toInt(),
      autoClose: action.autoClose,
      padding: EdgeInsets.zero,
      backgroundColor: Colors.transparent,
      foregroundColor: action.foregroundColor,
      onPressed: (actionContext) {
        if (!_busy) unawaited(_runGuarded(actionContext));
      },
      child: RepaintBoundary(
        child: Semantics(
          button: true,
          enabled: !_busy,
          label: action.semanticLabel ?? action.label,
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
              borderRadius: widget.borderRadius,
              border: Border.all(
                color: Colors.white.withOpacity(0.13),
              ),
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: color.withOpacity(0.30),
                  blurRadius: 22,
                  spreadRadius: -8,
                ),
              ],
            ),
            child: IgnorePointer(
              ignoring: _busy,
              child: action.child ??
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 10,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
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
                  ),
            ),
          ),
        ),
      ),
    );
  }
}
