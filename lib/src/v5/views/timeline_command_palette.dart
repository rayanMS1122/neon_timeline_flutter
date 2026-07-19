import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../v4/theme/timeline_theme.dart';

@immutable
class TimelinePaletteCommand {
  const TimelinePaletteCommand({
    required this.id,
    required this.label,
    required this.onSelected,
    this.description,
    this.icon,
    this.shortcut,
    this.keywords = const <String>[],
    this.enabled = true,
  });

  final Object id;
  final String label;
  final String? description;
  final IconData? icon;
  final String? shortcut;
  final List<String> keywords;
  final bool enabled;
  final FutureOr<void> Function() onSelected;
}

Future<void> showTimelineCommandPalette({
  required BuildContext context,
  required List<TimelinePaletteCommand> commands,
  String title = 'Command palette',
  String hintText = 'Search commands',
}) {
  return showDialog<void>(
    context: context,
    barrierColor: Colors.black.withAlpha(110),
    builder: (context) => Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
      backgroundColor: Colors.transparent,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 680, maxHeight: 620),
        child: TimelineCommandPalette(
          commands: commands,
          title: title,
          hintText: hintText,
          onClose: () => Navigator.of(context).pop(),
        ),
      ),
    ),
  );
}

class TimelineCommandPalette extends StatefulWidget {
  const TimelineCommandPalette({
    required this.commands,
    this.title = 'Command palette',
    this.hintText = 'Search commands',
    this.onClose,
    super.key,
  });

  final List<TimelinePaletteCommand> commands;
  final String title;
  final String hintText;
  final VoidCallback? onClose;

  @override
  State<TimelineCommandPalette> createState() => _TimelineCommandPaletteState();
}

class _TimelineCommandPaletteState extends State<TimelineCommandPalette> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  int _highlighted = 0;
  bool _executing = false;

  List<TimelinePaletteCommand> get _filtered {
    final query = _controller.text.trim().toLowerCase();
    if (query.isEmpty) return widget.commands;
    return widget.commands
        .where((command) {
          final haystack = <String>[
            command.label,
            command.description ?? '',
            ...command.keywords,
          ].join(' ').toLowerCase();
          return haystack.contains(query);
        })
        .toList(growable: false);
  }

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onQueryChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _controller
      ..removeListener(_onQueryChanged)
      ..dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onQueryChanged() => setState(() => _highlighted = 0);

  Future<void> _execute(TimelinePaletteCommand command) async {
    if (_executing || !command.enabled) return;
    setState(() => _executing = true);
    try {
      await command.onSelected();
      widget.onClose?.call();
    } finally {
      if (mounted) setState(() => _executing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = TimelineTheme.of(context);
    final filtered = _filtered;
    if (_highlighted >= filtered.length) _highlighted = 0;

    return Material(
      color: theme.surfaceColor,
      elevation: 24,
      borderRadius: BorderRadius.circular(theme.cardRadius + 6),
      clipBehavior: Clip.antiAlias,
      child: Shortcuts(
        shortcuts: const <ShortcutActivator, Intent>{
          SingleActivator(LogicalKeyboardKey.arrowDown): DirectionalFocusIntent(
            TraversalDirection.down,
          ),
          SingleActivator(LogicalKeyboardKey.arrowUp): DirectionalFocusIntent(
            TraversalDirection.up,
          ),
        },
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 14, 10, 10),
              child: Row(
                children: <Widget>[
                  Icon(Icons.bolt_rounded, color: theme.primaryColor),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      widget.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: theme.textColor,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: 'Close',
                    onPressed: widget.onClose,
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 12),
              child: TextField(
                controller: _controller,
                focusNode: _focusNode,
                textInputAction: TextInputAction.search,
                onSubmitted: (_) {
                  if (filtered.isNotEmpty) _execute(filtered[_highlighted]);
                },
                decoration: InputDecoration(
                  hintText: widget.hintText,
                  prefixIcon: const Icon(Icons.search_rounded),
                  suffixIcon: _executing
                      ? const Padding(
                          padding: EdgeInsets.all(14),
                          child: SizedBox.square(
                            dimension: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        )
                      : null,
                  filled: true,
                  fillColor: theme.surfaceVariantColor,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            Divider(height: 1, color: theme.dividerColor),
            Expanded(
              child: filtered.isEmpty
                  ? Center(
                      child: Text(
                        'No command found',
                        style: TextStyle(color: theme.mutedTextColor),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(8),
                      itemCount: filtered.length,
                      itemBuilder: (context, index) {
                        final command = filtered[index];
                        final highlighted = index == _highlighted;
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 3),
                          child: ListTile(
                            selected: highlighted,
                            enabled: command.enabled && !_executing,
                            selectedTileColor: theme.selectionColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            leading: Icon(
                              command.icon ?? Icons.play_arrow_rounded,
                              color: highlighted
                                  ? theme.primaryColor
                                  : theme.mutedTextColor,
                            ),
                            title: Text(
                              command.label,
                              style: TextStyle(
                                color: theme.textColor,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            subtitle: command.description == null
                                ? null
                                : Text(
                                    command.description!,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                            trailing: command.shortcut == null
                                ? null
                                : DecoratedBox(
                                    decoration: BoxDecoration(
                                      color: theme.surfaceVariantColor,
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: theme.dividerColor,
                                      ),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      child: Text(
                                        command.shortcut!,
                                        style: Theme.of(context)
                                            .textTheme
                                            .labelSmall
                                            ?.copyWith(
                                              color: theme.mutedTextColor,
                                              fontWeight: FontWeight.w800,
                                            ),
                                      ),
                                    ),
                                  ),
                            onTap: () => _execute(command),
                            onFocusChange: (focused) {
                              if (focused) setState(() => _highlighted = index);
                            },
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
