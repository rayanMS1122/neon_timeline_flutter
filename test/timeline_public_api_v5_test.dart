import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:neon_timeline_flutter/neon_timeline_flutter.dart';

void main() {
  test('palette and reversible command APIs do not collide', () {
    final paletteCommand = TimelinePaletteCommand(
      id: 'open',
      label: 'Open',
      onSelected: () {},
    );
    final TimelineCommand reversibleCommand = _TestCommand();

    expect(paletteCommand.label, 'Open');
    expect(reversibleCommand.label, 'Test');
  });
}

class _TestCommand implements TimelineCommand {
  @override
  String get label => 'Test';

  @override
  FutureOr<void> execute() {}

  @override
  FutureOr<void> undo() {}
}
