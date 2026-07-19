/// Headless planner engine, conflict solver, series, and scheduling APIs (version 6.x).
///
/// Adds the planning engine, conflict resolution, and series management on top of V5.
///
/// Import this if you want to use only the V6 API (includes V4 + V5):
/// ```dart
/// import 'package:neon_timeline_flutter/timeline_v6.dart';
/// ```
library;

// V6-specific core
export 'src/v6/core/timeline_activity_index.dart';
export 'src/v6/core/timeline_conflict_solver.dart';
export 'src/v6/core/timeline_day_plan.dart';
export 'src/v6/core/timeline_entry_adapter.dart';
export 'src/v6/core/timeline_planner_engine.dart';
export 'src/v6/core/timeline_planner_window.dart';
export 'src/v6/core/timeline_reschedule.dart';
export 'src/v6/core/timeline_series.dart';
export 'src/v6/core/timeline_week_plan.dart';

// V6-specific widgets
export 'src/v6/widgets/timeline_planner_day_builder.dart';
export 'src/v6/widgets/timeline_planner_window_builder.dart';

// All V5 APIs (and V4) are included
export 'timeline_v5.dart';
