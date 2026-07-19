import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:neon_timeline_flutter/timeline_v11.dart';

class _Operation implements StructuredTimelineOperation {
  _Operation(this.value);
  final List<int> value;
  @override
  Object get id => 'op';
  @override
  FutureOr<void> apply() {
    value.add(1);
  }

  @override
  FutureOr<void> revert() {
    value.removeLast();
  }
}

void main() {
  test('history executes, undoes and redoes', () async {
    final values = <int>[];
    final history = StructuredTimelineInteractionHistory();
    await history.execute(_Operation(values));
    expect(values, [1]);
    await history.undo();
    expect(values, isEmpty);
    await history.redo();
    expect(values, [1]);
    history.dispose();
  });
}
