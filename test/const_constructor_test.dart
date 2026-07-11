import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:neon_timeline_flutter/neon_timeline_flutter.dart';

void main() {
  test('public duration-bearing constructors remain const-evaluable', () {
    const connectorStyle = NeonTimelineConnectorStyle();
    const theme = NeonTimelineThemeData();
    const motionScope = NeonTimelineMotionScope(child: SizedBox());
    const card = NeonTimelineCard(child: SizedBox());

    expect(connectorStyle.animationDuration, isNot(Duration.zero));
    expect(theme.motionDuration, isNot(Duration.zero));
    expect(motionScope.duration, isNot(Duration.zero));
    expect(card.animationDuration.isNegative, isFalse);
  });
}
