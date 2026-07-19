// ignore_for_file: invalid_use_of_protected_member
part of 'day_timeline_view.dart';

extension _DayTimelineUndo<T> on _NeonPlannerDayTimelineState<T> {
  void _showUndoForMove(
    NeonPlannerMoveProposal<T> proposal,
    String message,
  ) {
    if (!widget.showBuiltInUndo || widget.onUndoMove == null) {
      return;
    }
    _undoTimer?.cancel();
    if (mounted) {
      setState(() {
        _pendingUndo = _PendingUndo<T>(proposal: proposal, message: message);
      });
    }
    if (widget.undoWindow > Duration.zero) {
      _undoTimer = Timer(widget.undoWindow, _dismissUndo);
    }
  }

  Future<void> _handleUndo() async {
    final pending = _pendingUndo;
    final callback = widget.onUndoMove;
    if (pending == null || callback == null || _committing) {
      return;
    }
    _undoTimer?.cancel();
    _committing = true;
    try {
      final result = await Future<NeonPlannerMutationResult>.sync(
        () => callback(pending.proposal),
      );
      if (result.accepted) {
        HapticFeedback.lightImpact();
        _dismissUndo();
      } else {
        HapticFeedback.heavyImpact();
      }
      if (result.message != null) {
        widget.onFeedback?.call(result.message!);
      }
    } catch (error) {
      HapticFeedback.heavyImpact();
      widget.onFeedback?.call('Rückgängig fehlgeschlagen: $error');
    } finally {
      _committing = false;
    }
  }

  void _dismissUndo() {
    _undoTimer?.cancel();
    _undoTimer = null;
    if (mounted && _pendingUndo != null) {
      setState(() => _pendingUndo = null);
    }
  }
}

@immutable
class _PendingUndo<T> {
  const _PendingUndo({required this.proposal, required this.message});

  final NeonPlannerMoveProposal<T> proposal;
  final String message;
}

class _UndoBar extends StatelessWidget {
  const _UndoBar({
    required this.message,
    required this.theme,
    required this.layout,
    required this.onUndo,
    required this.onDismiss,
  });

  final String message;
  final NeonPlannerTimelineThemeData theme;
  final _DayLayoutMetrics layout;
  final VoidCallback onUndo;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: theme.primaryTextColor.withValues(alpha: 0.96),
          borderRadius: BorderRadius.circular(layout.isRegular ? 20 : 14),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: theme.shadowColor.withValues(alpha: 0.9),
              blurRadius: layout.isRegular ? 24 : 10,
              offset: Offset(0, layout.isRegular ? 12 : 4),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            layout.isRegular ? 16 : 10,
            layout.isRegular ? 10 : 6,
            layout.isRegular ? 8 : 4,
            layout.isRegular ? 10 : 6,
          ),
          child: Row(
            children: <Widget>[
              Icon(
                Icons.check_circle_rounded,
                color: theme.successColor,
                size: layout.isRegular ? 21 : 16,
              ),
              SizedBox(width: layout.isRegular ? 10 : 6),
              Expanded(
                child: Text(
                  message,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.metadataStyle.copyWith(
                    color: theme.surfaceColor,
                    fontSize: layout.isRegular ? 13 : layout.metadataFontSize,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              TextButton(
                style: layout.isRegular
                    ? null
                    : TextButton.styleFrom(
                        minimumSize: const Size(44, 44),
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        textStyle: const TextStyle(fontSize: 11),
                      ),
                onPressed: onUndo,
                child: const Text('Rückgängig'),
              ),
              IconButton(
                constraints: BoxConstraints.tightFor(
                  width: layout.isRegular ? 48 : 44,
                  height: layout.isRegular ? 48 : 44,
                ),
                padding: EdgeInsets.zero,
                tooltip: 'Schließen',
                onPressed: onDismiss,
                icon: Icon(
                  Icons.close_rounded,
                  color: theme.surfaceColor.withValues(alpha: 0.8),
                  size: layout.isRegular ? 19 : 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
