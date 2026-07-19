/// Structured-style planner UI, styled views and drag interactions (version 7.x).
///
/// Adds the structured timeline widgets and style system on top of V6.
///
/// Import this if you want to use only the V7 API (includes V4–V6):
/// ```dart
/// import 'package:neon_timeline_flutter/timeline_v7.dart';
/// ```
library;

// V7-specific models
export 'src/v7/models/structured_timeline_details.dart';
export 'src/v7/models/structured_timeline_style.dart';

// V7-specific widgets
export 'src/v7/widgets/structured_timeline_planner.dart';
export 'src/v7/widgets/structured_timeline_view.dart';

// All V6 APIs (and V4–V5) are included
export 'timeline_v6.dart';
