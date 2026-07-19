import 'package:flutter_test/flutter_test.dart';
import 'package:neon_timeline_flutter/timeline_core.dart';

void main() {
  test('controller owns selection and clamps zoom', () {
    final controller = TimelineController<String>();
    var notifications = 0;
    controller.addListener(() => notifications++);

    controller.select('a');
    expect(controller.selectedIds, <Object>{'a'});

    controller.select('b', mode: TimelineSelectionMode.multiple);
    expect(controller.selectedIds, <Object>{'a', 'b'});

    controller.toggle('a');
    expect(controller.selectedIds, <Object>{'b'});

    controller.setZoom(99);
    expect(controller.zoom, 8);
    expect(notifications, 4);

    controller.dispose();
  });
}
