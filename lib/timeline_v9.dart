/// Production Structured timeline composition and public component APIs (version 9.x).
///
/// Adds the production-grade structured timeline with segmentation, zoom, and rail.
///
/// Import this if you want to use only the V9 API (includes V4–V8):
/// ```dart
/// import 'package:neon_timeline_flutter/timeline_v9.dart';
/// ```
library;

import 'src/v4/core/timeline_performance_config.dart';
import 'src/v7/models/structured_timeline_style.dart';
import 'src/v9/widgets/production_structured_timeline.dart';
import 'src/v9/widgets/structured_timeline_header_components.dart';

// V9-specific core
export 'src/v9/core/structured_timeline_segmenter.dart';

// V9-specific models
export 'src/v9/models/structured_timeline_component_details.dart';
export 'src/v9/models/structured_timeline_entry_segment.dart';
export 'src/v9/models/structured_timeline_entry_style.dart';
export 'src/v9/models/structured_timeline_gap_layout.dart';
export 'src/v9/models/structured_timeline_zoom.dart';

// V9-specific widgets
export 'src/v9/widgets/production_structured_timeline.dart';
export 'src/v9/widgets/structured_timeline_entry_components.dart';
export 'src/v9/widgets/structured_timeline_gap_components.dart';
export 'src/v9/widgets/structured_timeline_header_components.dart';
export 'src/v9/widgets/structured_timeline_rail.dart';
export 'src/v9/widgets/structured_timeline_scaffold.dart';
export 'src/v9/widgets/structured_timeline_states.dart';
export 'src/v9/widgets/structured_timeline_viewport.dart';

// All V8 APIs (and V4–V7) are included
export 'timeline_v8.dart';

// Convenience type aliases for migration
typedef StructuredTimeline<T> = ProductionStructuredTimeline<T>;
typedef StructuredTimelinePerformanceConfig = TimelinePerformanceConfig;
typedef StructuredTimelineTheme = StructuredTimelineStyle;
typedef StructuredTimelineDayNavigator = StructuredTimelineDateNavigator;
