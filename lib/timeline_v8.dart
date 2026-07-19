/// Advanced structured timeline, mutation coordinator, resize, and slot suggestions (version 8.x).
///
/// Adds advanced structured widgets, mutation coordination, and viewport indexing.
///
/// Import this if you want to use only the V8 API (includes V4–V7):
/// ```dart
/// import 'package:neon_timeline_flutter/timeline_v8.dart';
/// ```
library;

// V8-specific core
export 'src/v8/core/structured_timeline_controller.dart';
export 'src/v8/core/timeline_mutation_coordinator.dart';
export 'src/v8/core/timeline_resize.dart';
export 'src/v8/core/timeline_slot_suggestions.dart';
export 'src/v8/core/timeline_viewport_index.dart';

// V8-specific models
export 'src/v8/models/advanced_structured_timeline_details.dart';
export 'src/v8/models/structured_timeline_layout.dart';

// V8-specific widgets
export 'src/v8/widgets/advanced_structured_timeline.dart';
export 'src/v8/widgets/advanced_structured_timeline_planner.dart';

// All V7 APIs (and V4–V6) are included
export 'timeline_v7.dart';
