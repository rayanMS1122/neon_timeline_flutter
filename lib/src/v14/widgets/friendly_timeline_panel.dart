import 'package:flutter/material.dart';

import '../theme/friendly_timeline_ui_theme.dart';

/// Elevated surface shared by version 14 workspace components.
class FriendlyTimelinePanel extends StatelessWidget {
  const FriendlyTimelinePanel({
    required this.child,
    this.padding = const EdgeInsets.all(14),
    super.key,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final theme = FriendlyTimelineUiTheme.of(context);
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: theme.panelStrong.withValues(alpha: 0.96),
        borderRadius: BorderRadius.circular(theme.panelRadius),
        border: Border.all(color: theme.outline),
        boxShadow: [
          BoxShadow(
            color: theme.shadow,
            blurRadius: 28,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: child,
    );
  }
}

/// Decorative, pointer-transparent ambient background for the workspace.
class FriendlyTimelineAmbientBackground extends StatelessWidget {
  const FriendlyTimelineAmbientBackground({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = FriendlyTimelineUiTheme.of(context);
    return IgnorePointer(
      child: Stack(
        children: [
          Positioned(
            left: -110,
            top: -90,
            child: _GlowOrb(color: theme.lavenderSoft, size: 300),
          ),
          Positioned(
            right: -90,
            top: 120,
            child: _GlowOrb(color: theme.mintSoft, size: 250),
          ),
          Positioned(
            left: 260,
            bottom: -170,
            child: _GlowOrb(color: theme.coralSoft, size: 350),
          ),
        ],
      ),
    );
  }
}

class _GlowOrb extends StatelessWidget {
  const _GlowOrb({required this.color, required this.size});

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [color.withValues(alpha: 0.72), color.withValues(alpha: 0)],
        ),
      ),
    );
  }
}
